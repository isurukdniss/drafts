# Technical Specification: Database X (A, B) → Database Y (C) Data Synchronization

**Status:** Approved — Hash-Gated Differential Sync selected
**Author:** [fill in]
**Date:** [fill in]

---

## 1. Overview

This document specifies the design for synchronizing data from tables `A` and `B` (database `X`) into table `C` (database `Y`), where `B` is a 1:1 extension of `A` and one column on `B` stores a file as binary data (`VARBINARY(MAX)`). Three architectural approaches were evaluated. **Hash-Gated Differential Sync is the selected solution.**

## 2. Background and Requirements

### 2.1 Functional requirements
- Table `C` must reflect the current combined state of `A` and `B` (joined on their shared key).
- Sync runs **quarterly, or on demand** — not near real time.
- `C` is **read-only** from every consumer's perspective except the sync process itself; it is queried only by a downstream BI/reporting tool.
- File content on `B` **can be replaced/updated** on existing rows, not just set once.
- Non-binary metadata (including the file's display name) **can change independently of the binary file itself** (e.g., a rename that doesn't touch the file bytes) and must be reflected in `C`.

### 2.2 Constraints
- `X` and `Y` may reside on different SQL Server instances → a linked server is required.
- The file column represents the dominant cost driver: current volume is **~30 GB**, with **1M+ source rows** anticipated at scale.
- **The system that writes to `A`/`B` is a legacy application that cannot be modified.**
- **No schema changes are permitted on the source tables** (`A`, `B`) — no added columns, no persisted computed columns.
- Whether `CREATE TRIGGER` against `A`/`B` is permissible is **unresolved** at time of writing (see §8, Open Items). This was treated as a risk factor rather than assumed safe.
- Solution must be implementable entirely in T-SQL (SQL Agent, linked server, stored procedures) — no external ETL tooling.

## 3. Options Considered

### 3.1 Option A — Trigger-Based Change Capture (audit table + watermark)
Triggers on `A` and `B` write every insert/update/delete to an audit table in `X`; a stored procedure reads unprocessed audit rows since the last watermark and applies only the delta to `C`.

| Pros | Cons |
|---|---|
| Captures changes incrementally as they happen; minimal data moved per sync if run frequently | Requires attaching triggers to the legacy system's live tables — a direct, permanent change to their write path |
| No need to re-scan/re-hash unchanged data at sync time | `TRUNCATE TABLE` and some bulk-load paths bypass triggers entirely — silent, undetected drift |
| Well suited to near-real-time cadence | Ongoing overhead on every write to `A`/`B`, 24/7, in service of a sync that only runs quarterly |
| | Highest build complexity: audit table, watermark table, trigger logic, log table |
| | Recovery from a gap in the audit trail (e.g., a bypassed trigger, or a purge job removing unprocessed rows) is difficult to detect and fix |

**Assessment:** This architecture is designed for high-frequency, near-real-time sync. At quarterly/on-demand cadence, its cost (permanent footprint on a legacy write path) is paid every day for a capability the business doesn't use. It also carries the highest risk of exactly the kind of legacy-system modification the constraints in §2.2 are meant to avoid.

### 3.2 Option B — Replace-All (Full Snapshot Rebuild)
Every run rebuilds `C` from scratch: join `A`+`B`, load the full result into a staging table (or batches), and swap it in (via `sp_rename`) or apply as a batched full reload.

| Pros | Cons |
|---|---|
| Simplest to build and reason about — no change-detection logic at all | Re-transfers the entire ~30 GB file volume across the linked server on **every single run**, regardless of how little actually changed |
| Self-healing by construction: every run is a full reconciliation, so drift cannot accumulate | Cost grows linearly with total data volume, not with actual change volume — does not scale as file data grows |
| Trivial to validate ("does C match A+B right now?") | No incremental efficiency gain ever, even once volumes grow well past current levels |
| Zero-blocking reads achievable via staging + rename swap | |

**Assessment: Rejected by leadership.** Not carried forward as a candidate despite its simplicity.

### 3.3 Option C — Hash-Gated Differential Sync (SELECTED)
Every run computes `HASHBYTES('SHA2_256', FileData)` for each current source row, compares it against the hash already stored in `C`, and transfers actual file bytes across the linked server **only** for rows that are new or whose file content changed. Non-binary metadata (including filename) is refreshed unconditionally every run, since it is cheap regardless of change status.

| Pros | Cons |
|---|---|
| **Never modifies the legacy system** — operates as pure `SELECT` reads against `A`/`B`; zero footprint on the source write path | More complex than replace-all: hash comparison, change-set derivation, atomicity handling between hash and data |
| Only the actually-changed file bytes cross the network — the expensive resource (linked-server transfer of binary data) scales with real change volume, not total volume | Without a persisted hash column (disallowed by the no-schema-change constraint), every run must read the **full** binary content of every source row to compute a comparison hash — an unavoidable full local scan on the legacy server |
| Self-healing/idempotent: a failed or interrupted run is simply safe to re-run, since the diff is recomputed fresh each time | First run has no baseline to compare against, so it behaves like a full replace-all once (all rows appear "changed") |
| Filename-only changes are handled correctly and cheaply by design, independent of file-hash comparison | Requires care to avoid a subtle correctness bug: hash and binary data must be updated **atomically together** (see §6.4) |
| No staging table or swap needed once operating on a true diff — direct `INSERT`/`UPDATE`/`DELETE` inside one transaction gives equivalent all-or-nothing guarantees for the row set actually touched | |
| Auto-batches the file-transfer step when the diff is unusually large (e.g., cold start), avoiding one oversized transaction | |

## 4. Decision

**Hash-Gated Differential Sync (Option C) is the final solution.**

Rationale, given the specific constraints discovered during design:
1. Replace-all was explicitly rejected by leadership.
2. Between the remaining two, the deciding factor is the legacy-system constraint: **hash-gating touches the source system exactly the same way ordinary reporting queries do — read-only, no schema changes, no code injected into its write path.** Trigger-based sync, by contrast, requires permanently attaching new code (`CREATE TRIGGER`) to a system leadership has already restricted from modification, and whose permissibility is unconfirmed (§8).
3. Hash-gating's remaining weakness — a full local read/hash pass over source data each run, since a persisted hash column isn't allowed — is a **local, read-only cost on X**, not a cross-network cost. It is manageable operationally (scheduling, isolation level) in a way that a permanent trigger footprint or a 30 GB+ network transfer are not.
4. The cadence (quarterly/on-demand) does not justify paying for always-on change capture; it's well matched to a design that does its work entirely within the sync window.

## 5. Solution Architecture

### 5.1 Data flow
1. **X (source, read-only access):** compute a manifest of every current `A`⋈`B` row: shared key, metadata columns (including filename), and `HASHBYTES('SHA2_256', FileData)`. No binary data is moved yet.
2. **Y (via linked server, cheap):** pull `(ID, FileHash)` currently stored in `C` for comparison.
3. **X:** derive the change set — rows with no matching hash in `C`, or a differing hash (new or changed files).
4. **Structural sync (one transaction):** insert brand-new rows (metadata only, `FileHash = NULL` until file lands), refresh metadata for existing rows (filename, other attributes — unconditional, cheap), delete rows removed from `A`.
5. **File transfer:** for the change set only, read the actual file bytes locally on X, then update `FileData` **and** `FileHash` together in `C`, in one statement (small diff) or in ID-range batches (large diff, auto-selected by threshold).
6. **Post-run validation:** re-pull `C`'s current hashes and compare against the manifest snapshot taken in step 1 (not a fresh live re-query of `A`/`B`, which would produce false mismatches from ordinary concurrent writes). Log row counts, mismatch count, and a `Passed`/`Mismatch` verdict.
7. **Logging:** every run's outcome, counts, and validation result are written to `SyncLog`.

### 5.2 Components
| Component | Location | Purpose |
|---|---|---|
| `C` | Database Y | Target table; adds `FileHash BINARY(32)` alongside the existing/expected columns |
| `SyncLog` | Database X | One row per run: counts, batch-mode flag, validation results, status |
| `LINKSRV_Y` | Linked server on X | Enables cross-server reads/writes to `C` |
| `usp_Sync_A_B_to_C` | Database X | Orchestrates the full flow described in §5.1 |
| SQL Agent job `Sync_A_B_to_C` | X's instance | Quarterly schedule + supports on-demand execution |

No changes are required to `A` or `B` — this design's core property is that the source tables are only ever read.

### 5.3 Key design decisions
- **No staging table / rename swap.** Since only the true diff is touched (not a full rebuild), wrapping the `INSERT`/`UPDATE`/`DELETE` statements in one transaction gives the same "readers never see partial state" guarantee a swap would, via ordinary transaction isolation. Enabling Read Committed Snapshot Isolation on Y removes even the brief row-level blocking this implies.
- **Auto-batched file transfer.** Parameters `@FileBatchThreshold` (default 2000 changed rows) and `@FileBatchSize` (default 500) control an automatic fallback: below threshold, all changed files transfer in one statement/transaction; above it, transfer proceeds in chunks, each its own transaction. This matters primarily for the first run (no baseline hash exists, so everything looks changed) and any future bulk file replacement event.
- **Filename handled independently of file-hash gating.** Metadata columns (including filename) are refreshed unconditionally every run regardless of whether the file hash changed, so a rename-only change is captured correctly without triggering an unnecessary file transfer.

### 5.4 Atomicity fix (critical correctness requirement)
`FileHash` must **only ever be updated in the same statement as `FileData`**. An earlier draft of this design updated `FileHash` during the metadata-refresh step, independently of the file-transfer step; if a failure occurred in between, `C` could end up with a hash claiming a file was current while the bytes were stale or missing — and because the next run's change detection is hash-based, that row would be silently and **permanently** skipped from then on. New rows are inserted with `FileHash = NULL` until their file bytes are confirmed written; existing rows retain their prior (still-correct) hash until an actual change is applied.

### 5.5 Post-run validation
`SyncLog` records `SourceRowCount`, `TargetRowCount`, `MismatchCount`, and `ValidationStatus` (`Passed`/`Mismatch`) for every run, computed against the same snapshot used for the run itself. This distinguishes "the stored procedure completed without a T-SQL error" (`Status`) from "the target actually converged to match the source" (`ValidationStatus`) — a run can succeed in the first sense and still fail the second if, for example, a batch silently affected fewer rows than expected.

## 6. Operational Considerations

### 6.1 Prerequisites
- MSDTC (Distributed Transaction Coordinator) running, with Network DTC Access and inbound/outbound access enabled, on both the X and Y instances — required for any write through a linked server.
- A SQL login on Y with `SELECT`, `INSERT`, `UPDATE`, `DELETE` rights on `dbo.C`.
- SQL Server 2016 or later (required for `HASHBYTES` with `SHA2_256` over inputs larger than 8000 bytes).

### 6.2 Scheduling
- SQL Agent job scheduled quarterly (monthly frequency type, recurrence factor 3).
- Supports ad hoc execution at any time via `EXEC dbo.usp_Sync_A_B_to_C;` or "Start Job at Step" in SSMS.

### 6.3 Performance and legacy-system impact
Because no schema change (and therefore no persisted hash column) is permitted on the source, **every run performs a full read of all binary file content on X** to compute comparison hashes — this cost is unavoidable given current constraints. It is local I/O/CPU on X and never crosses the network, but at 1M+ rows / 30 GB+ it is a non-trivial read load against a live legacy production table. Recommended mitigations:
- Schedule runs during off-hours where possible, particularly the first run (which behaves like a full transfer).
- Consider `READ UNCOMMITTED` isolation (or `WITH (NOLOCK)`) for the read-only hashing pass to minimize lock contention with the legacy application, since any transient inconsistency is self-corrected on the next run.
- If a natural last-modified timestamp or `rowversion` column is confirmed to already exist on the source (§8), it can be used to pre-filter which rows need hashing at all, without requiring any schema change.

### 6.4 Monitoring
```sql
-- Recent run history
SELECT TOP 20 * FROM DatabaseX.dbo.SyncLog ORDER BY LogID DESC;

-- Runs that completed without error but didn't actually converge
SELECT * FROM DatabaseX.dbo.SyncLog
WHERE Status = 'Success' AND ValidationStatus = 'Mismatch'
ORDER BY LogID DESC;

-- Runs that failed outright
SELECT * FROM DatabaseX.dbo.SyncLog WHERE Status = 'Failed' ORDER BY LogID DESC;
```
No automated alerting (e.g., email on failure) is included in the current scope; `SyncLog` must be checked manually after each run, or alerting can be added later as a follow-up enhancement.

### 6.5 Failure handling
- Structural changes (insert/update/delete of rows) run in a single transaction — fully atomic.
- File transfer runs in one transaction (small diff) or per-batch transactions (large diff). A failure mid-batch leaves already-committed batches in place; this is safe, because the change-set is recomputed from current hashes on every run, so already-synced rows are simply not re-selected.
- SQL Agent job step is configured with automatic retry (2 attempts, 5-minute interval) for transient failures.

## 7. Reference Implementation

The T-SQL implementing this specification is provided in `sync_A_B_to_C_hash_gated_validated.sql`, covering:
- `C` table definition (database Y)
- `SyncLog` table (database X)
- Linked server setup (commented template)
- `usp_Sync_A_B_to_C` (full logic per §5.1–§5.5)
- SQL Agent job and quarterly schedule

**Before deploying:** replace placeholder column names (`Col1`, `Col2`, `ExtCol1`, `FileData`) with the actual source schema, and confirm the filename column is included among the metadata columns refreshed in the structural update step.

## 8. Open Items Requiring Confirmation

| # | Item | Why it matters |
|---|---|---|
| 1 | Does the "cannot modify the legacy system" constraint also prohibit `CREATE TRIGGER` on `A`/`B`, or only column/schema changes? | Confirms that trigger-based sync (Option A) was correctly excluded as infeasible, not just undesirable — relevant if requirements change later |
| 2 | Do `A` or `B` already have an existing last-modified timestamp or `rowversion` column? | Could reduce the scope of the full-scan hashing pass in §6.3 without requiring any schema change |
| 3 | Real column names for `Col1`, `Col2`, `ExtCol1`, `FileData` in the reference script | Required before deployment |
| 4 | Should Read Committed Snapshot Isolation be enabled on database Y? | Removes reader blocking during sync entirely; recommended but not yet confirmed as approved |
| 5 | Should automated failure alerting (e.g., email via Database Mail) be added? | Currently out of scope; `SyncLog` requires manual review after each run |
