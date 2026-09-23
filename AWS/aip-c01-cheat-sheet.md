# AWS Certified Generative AI Developer – Professional (AIP-C01) — Field Guide

Condensed from the official AIP-C01 exam guide, current as of September 2026. Non-exhaustive and subject to change — confirm details against [AWS's official exam guide](https://docs.aws.amazon.com/aws-certification/latest/ai-professional-01/ai-professional-01.html) before test day.

## Exam at a glance

- **75 questions** (65 scored + 10 unscored, unmarked)
- **180 minutes**
- **Pass score:** 750 / 1000
- **Cost:** $300 USD
- **Format:** multiple choice / multiple response
- **Languages:** English, Japanese, Korean, Simplified Chinese

### Domain weighting

| # | Domain | Weight |
|---|---|---|
| 1 | Foundation Model Integration, Data Management & Compliance | 31% |
| 2 | Implementation & Integration | 26% |
| 3 | AI Safety, Security & Governance | 20% |
| 4 | Operational Efficiency & Optimization for GenAI | 12% |
| 5 | Testing, Validation & Troubleshooting | 11% |

---

## Domain 1: Foundation Model Integration, Data Management & Compliance (31%)

### 1.1 Analyze requirements & design GenAI solutions
- **Architect to the brief** — pick FMs, integration pattern, and deployment strategy for the stated constraints.
- **Prove it first** — validate feasibility with a `Bedrock` proof-of-concept before full build-out.
- **Standardize** — reusable patterns via the `AWS Well-Architected Framework` and the `WA Tool GenAI Lens`.

### 1.2 Select & configure FMs
- **Choose the model** — compare benchmarks, capabilities, and limitations against the use case.
- **Design for swap-ability** — dynamic model/provider switching with no code changes via `Lambda`, `API Gateway`, `AppConfig`.
- **Build in resilience** — `Step Functions` circuit breakers, `Bedrock Cross-Region Inference`, cross-Region deployment, graceful degradation.
- **Manage the customization lifecycle** — fine-tune on `SageMaker AI` (LoRA / adapters), version in `Model Registry`, automate rollout, rollback, retirement.

### 1.3 Data validation & processing pipelines
- **Gate data quality** — `Glue Data Quality`, `SageMaker Data Wrangler`, Lambda checks, CloudWatch metrics.
- **Handle every modality** — text, image, audio, tabular via `Bedrock` multimodal models, `SageMaker Processing`, `Transcribe`.
- **Format for the model** — JSON for `Bedrock` API calls, structured payloads for `SageMaker` endpoints, conversation formatting for chat.
- **Clean before you send** — reformat with `Bedrock`, extract entities with `Comprehend`, normalize with Lambda.

### 1.4 Vector store solutions
- **Pick the architecture** — `Bedrock Knowledge Bases`, `OpenSearch` + Neural plugin, `RDS` + S3, or `DynamoDB` for metadata/embeddings.
- **Design metadata** — S3 object metadata, custom attributes, tagging for classification.
- **Scale search** — OpenSearch sharding, multi-index, hierarchical indexing.
- **Connect external knowledge** — document systems, internal wikis, existing knowledge bases.
- **Keep it fresh** — incremental updates, change detection, scheduled sync/refresh pipelines.

### 1.5 Retrieval mechanisms for FM augmentation
- **Chunk deliberately** — `Bedrock` built-in chunking, Lambda fixed-size, custom hierarchical.
- **Choose embeddings** — `Titan Embeddings` by dimensionality/domain fit; evaluate `Bedrock` embedding models.
- **Deploy vector search** — `OpenSearch Service`, `Aurora` + pgvector, `Bedrock Knowledge Bases` managed store.
- **Improve relevance** — hybrid keyword + vector search, `Bedrock reranker` models.
- **Handle the query, not just the doc** — `Bedrock` query expansion, Lambda decomposition, Step Functions transformation.
- **Standardize access** — function-calling interfaces, `MCP` clients for vector queries.

### 1.6 Prompt engineering strategies & governance
- **Control behavior** — `Bedrock Prompt Management` roles, `Bedrock Guardrails`, response templates.
- **Hold context** — Step Functions clarification flows, Comprehend intent recognition, DynamoDB conversation history.
- **Govern prompts like code** — parameterized templates + approvals in `Prompt Management`, S3 template repos, CloudTrail + CloudWatch Logs tracking.
- **QA the prompt** — Lambda output checks, Step Functions edge cases, CloudWatch regression tracking.
- **Refine beyond basics** — structured inputs, output-format specs, chain-of-thought, feedback loops.
- **Chain complex prompts** — `Bedrock Prompt Flows`: sequential chains, conditional branching, reusable components.

---

## Domain 2: Implementation & Integration (26%)

### 2.1 Agentic AI solutions & tool integrations
- **Give agents memory & state** — `Strands Agents`, `AWS Agent Squad` for multi-agent systems, `MCP` for agent–tool interaction.
- **Structure reasoning** — `Step Functions` ReAct patterns, chain-of-thought.
- **Bound the agent** — Step Functions stopping conditions, Lambda timeouts, IAM boundaries, circuit breakers.
- **Coordinate multiple models** — specialized FMs per task, ensemble aggregation, model-selection frameworks.
- **Keep a human in the loop** — Step Functions review/approval, API Gateway feedback capture.
- **Wire up tools reliably** — `Strands API` custom behaviors, standardized function defs, Lambda error handling/validation.
- **Extend via MCP servers** — Lambda for lightweight/stateless servers, `ECS` for complex tool servers.

### 2.2 Model deployment strategies
- **Match deployment to demand** — Lambda on-demand, `Bedrock provisioned throughput`, `SageMaker` endpoints for hybrid.
- **Respect LLM-specific constraints** — container patterns for memory/GPU/token capacity, specialized model loading.
- **Balance cost vs. capability** — smaller task-specific models, API-based model cascading for routine queries.

### 2.3 Enterprise integration architectures
- **Connect to legacy** — API integrations, event-driven loose coupling, data sync patterns.
- **Bolt GenAI onto existing apps** — API Gateway microservices, Lambda webhooks, EventBridge.
- **Secure the access path** — identity federation, RBAC, least-privilege API access to FMs.
- **Respect data residency** — `AWS Outposts` (on-prem), `Wavelength` (edge), secure hybrid routing.
- **Ship it safely** — CI/CD via `CodePipeline`/`CodeBuild` with security scans + rollback; a centralized GenAI gateway for observability and control.

### 2.4 FM API integrations
- **Pick the interaction model** — `Bedrock` sync APIs, SDK + `SQS` for async, API Gateway for validation.
- **Stream for responsiveness** — `Bedrock streaming APIs`, WebSockets/SSE, chunked transfer encoding.
- **Design for failure** — SDK exponential backoff, API Gateway rate limiting, fallback mechanisms, `X-Ray` tracing.
- **Route intelligently** — static config, Step Functions content-based routing, metric-based model routing.

### 2.5 Application integration patterns & dev tools
- **Build FM-ready APIs** — streaming support, token-limit management, retry strategies for timeouts.
- **Lower the barrier to entry** — `Amplify` UI components, OpenAPI-first design, `Bedrock Prompt Flows` no-code builder.
- **Enhance business systems** — Lambda CRM logic, Step Functions document workflows, `Bedrock Data Automation`.
- **Speed up developers** — `Amazon Q Developer` for code gen, refactors, testing.
- **Orchestrate advanced agents** — `Strands Agents`/`Agent Squad`, Step Functions agent patterns, Bedrock prompt chaining.
- **Debug faster** — CloudWatch Logs Insights, X-Ray traces, Q Developer error-pattern recognition.

---

## Domain 3: AI Safety, Security & Governance (20%)

### 3.1 Input & output safety controls
- **Filter what comes in** — `Bedrock Guardrails`, Step Functions/Lambda moderation workflows, real-time validation.
- **Filter what goes out** — `Bedrock Guardrails` response filtering, toxicity evals, deterministic text-to-SQL.
- **Fight hallucination** — `Bedrock Knowledge Base` grounding, confidence scoring, semantic similarity checks, JSON Schema structured outputs.
- **Layer your defenses** — Comprehend pre-filters, Bedrock model-based guardrails, Lambda post-processing, API Gateway response filtering.
- **Catch adversarial input** — prompt-injection/jailbreak detection, input sanitization, safety classifiers, adversarial testing.

### 3.2 Data security & privacy controls
- **Isolate & lock down** — VPC endpoints, IAM access policies, `Lake Formation` granular access, CloudWatch monitoring.
- **Protect sensitive data** — `Comprehend`/`Macie` PII detection, Bedrock native privacy features, S3 Lifecycle retention policies.
- **Preserve utility with privacy** — data masking, PII anonymization, `Bedrock Guardrails`.

### 3.3 AI governance & compliance mechanisms
- **Document for compliance** — SageMaker model cards, Glue-tracked data lineage, metadata tagging, CloudWatch Logs decision trails.
- **Track provenance** — Glue Data Catalog registration, source-attribution tagging, CloudTrail audit logs.
- **Govern consistently** — org-wide frameworks aligned to policy, regulation, and responsible AI principles.
- **Monitor continuously** — automated misuse/drift/policy-violation detection, bias-drift monitoring, token-level redaction, output policy filters.

### 3.4 Responsible AI principles
- **Show your work** — reasoning displays, CloudWatch confidence metrics, source attribution, `Bedrock agent tracing`.
- **Check for bias** — CloudWatch fairness metrics, Prompt Management/Flows A/B testing, `Bedrock LLM-as-judge`.
- **Enforce policy** — Bedrock Guardrails per policy, model cards documenting limitations, Lambda compliance checks.

---

## Domain 4: Operational Efficiency & Optimization for GenAI (12%)

### 4.1 Cost optimization & resource efficiency
- **Spend tokens wisely** — usage tracking, context-window optimization, prompt compression/pruning, response-size limits.
- **Right-size the model** — cost-capability tradeoffs, tiered usage by query complexity, price-to-performance measurement.
- **Maximize throughput** — batching, capacity planning, auto-scaling, provisioned-throughput tuning.
- **Cache to save** — semantic caching, deterministic request hashing, `Bedrock prompt caching`, edge caching.

### 4.2 Optimize application performance
- **Cut perceived latency** — pre-computation, `Bedrock latency-optimized` models, response streaming, parallel requests.
- **Speed up retrieval** — index optimization, query preprocessing, hybrid search with custom scoring.
- **Push throughput** — token-processing optimization, batch inference, concurrent invocation management.
- **Tune generation** — model-specific params, A/B testing, temperature/top-k/top-p selection.
- **Plan capacity** — token-based capacity planning, GenAI-aware auto-scaling.
- **Profile the system** — API call profiling, vector DB query optimization, LLM-specific latency reduction.

### 4.3 Monitoring systems for GenAI applications
- **See the whole system** — operational metrics, FM interaction tracing, business-impact dashboards.
- **Watch GenAI-specific signals** — CloudWatch token usage / hallucination rate / response drift, `Bedrock Model Invocation Logs`, cost anomaly detection.
- **Turn data into action** — dashboards, compliance monitoring, forensic audit logging.
- **Track tool & agent use** — call-pattern tracking, tool-calling observability, multi-agent coordination tracking.
- **Keep vector stores healthy** — performance monitoring, automated index optimization, data-quality validation.
- **Hunt GenAI-specific bugs** — golden datasets for hallucination detection, output diffing, reasoning-path tracing.

---

## Domain 5: Testing, Validation & Troubleshooting (11%)

### 5.1 Evaluation systems for GenAI
- **Measure beyond accuracy** — relevance, factual accuracy, consistency, fluency.
- **Compare systematically** — `Bedrock Model Evaluations`, A/B & canary testing, cost-performance analysis.
- **Loop in users** — feedback interfaces, rating systems, annotation workflows.
- **Automate QA** — continuous evaluation, regression testing, automated quality gates.
- **Judge from multiple angles** — RAG evaluation, `LLM-as-judge`, human feedback.
- **Test retrieval itself** — relevance scoring, context-match verification, latency measurement.
- **Evaluate agents** — task-completion rate, tool-usage effectiveness, `Bedrock Agent evaluations`.
- **Report it clearly** — visualizations, automated reports, model-comparison views.
- **Validate before/after deploys** — synthetic workflows, hallucination-rate & semantic-drift checks.

### 5.2 Troubleshoot GenAI applications
- **Fix content overflow** — context-window diagnostics, dynamic chunking, truncation analysis.
- **Debug integration** — error logging, request validation, response analysis.
- **Fix the prompt, not just the model** — testing frameworks, version comparison, systematic refinement.
- **Fix retrieval** — relevance analysis, embedding diagnostics, drift monitoring, chunking/vectorization remediation.
- **Maintain prompts over time** — CloudWatch Logs + X-Ray observability, schema validation, refinement workflows.

---

## Bedrock feature glossary

| Feature | What it does | Reach for it when… |
|---|---|---|
| Knowledge Bases | Managed RAG — ingestion, chunking, embeddings, vector store, retrieval API | Building RAG without running your own vector infra |
| Guardrails | Content filters, denied topics, PII redaction, contextual grounding checks | Enforcing safety and compliance on input and output |
| AgentCore | Managed agent orchestration — reasoning loop, action groups, memory | Multi-step autonomous tasks that call tools |
| Prompt Management | Versioned, parameterized prompt templates with approvals | Governing prompts that change across teams |
| Prompt Flows | Visual chaining of prompts, logic, and Lambda steps | Multi-step workflows with branching |
| Cross-Region Inference | Routes inference across Regions for capacity/availability | Regional throttling or limited model availability |
| Provisioned Throughput | Reserved capacity for consistent, high-volume inference | Predictable, high-throughput production traffic |
| Custom Model Import | Bring a model customized outside Bedrock (e.g. on SageMaker) | Domain-specific customization beyond prompting |
| Model Evaluation | Built-in automatic and human evaluation jobs | Comparing FMs or prompt variants systematically |
| Data Automation | Managed multimodal extraction/processing pipeline | Structuring docs, images, or video for FM input |
| Model Invocation Logging | Full request/response logs to S3 & CloudWatch | Auditing, debugging, compliance trails |
| Streaming API | Token-by-token response delivery | Low perceived latency in chat UIs |
| Reranker models | Re-score retrieved chunks for relevance | Improving RAG precision after first-pass retrieval |
| Latency-optimized inference | Reduced-latency serving mode for select models | Time-sensitive, interactive applications |

---

## In-scope AWS services (non-exhaustive)

**Machine learning** — Bedrock, Bedrock AgentCore, Bedrock Knowledge Bases, Bedrock Prompt Management, Bedrock Prompt Flows, SageMaker AI, SageMaker Clarify, SageMaker Data Wrangler, SageMaker Ground Truth, SageMaker JumpStart, SageMaker Model Monitor, SageMaker Model Registry, SageMaker Neo, SageMaker Processing, SageMaker Unified Studio, Comprehend, Kendra, Lex, Q Business, Q Developer, Rekognition, Textract, Titan, Transcribe, Augmented AI

**Compute & containers** — Lambda, Lambda@Edge, EC2, App Runner, Outposts, Wavelength, ECS, EKS, ECR, Fargate

**Database & analytics** — Aurora, DynamoDB, DynamoDB Streams, RDS, DocumentDB, Neptune, ElastiCache, OpenSearch Service, Athena, EMR, Glue, Kinesis, MSK, QuickSight

**Application & network integration** — API Gateway, AppSync, EventBridge, SNS, SQS, Step Functions, AppFlow, AppConfig, CloudFront, ELB, Global Accelerator, PrivateLink, Route 53, VPC

**Security, identity & compliance** — IAM, IAM Access Analyzer, IAM Identity Center, Cognito, KMS, Encryption SDK, Macie, Secrets Manager, WAF

**Dev tools, storage & ops** — CDK, CLI, CloudFormation, CodeArtifact, CodeBuild, CodeDeploy, CodePipeline, Amplify, Kiro, X-Ray, S3, S3 Intelligent-Tiering, S3 Lifecycle, S3 Cross-Region Replication, EBS, EFS, CloudWatch, CloudWatch Logs, CloudTrail, Cost Explorer, Cost Anomaly Detection, Managed Grafana, Well-Architected Tool, Systems Manager, Auto Scaling

---

## Exam-day tactics

- **Compensatory scoring** — no domain minimum, just clear 750/1000 overall.
- **Unscored questions are hidden** — 10 of the 75 don't count and aren't marked. Give every question full effort.
- **No penalty for guessing** — never leave a question blank.
- **Watch the deciding qualifier** — "LEAST operational overhead," "MOST cost-effective," "HIGHEST availability" usually separates two technically-correct answers.
- **Read every option fully** — professional-level questions often have 2+ plausible answers; the wrong one usually violates one hidden constraint (cost, residency, latency, compliance).
- **Deterministic vs. non-deterministic** — know when to reach for Lambda/Step Functions vs. an LLM or agent. This tradeoff recurs across every domain.
- **Pace yourself** — 180 minutes / 75 questions ≈ 2.4 min each. Flag long scenarios and come back.
- **Data residency shows up often** — know exactly when Cross-Region Inference helps, and when residency requirements mean you should avoid it.
