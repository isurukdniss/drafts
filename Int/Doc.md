Absolutely. This JD is essentially a **Senior Full-Stack / Backend Engineer** role spanning **modern .NET + legacy .NET + Java/Quarkus + AWS + microservices + event-driven architecture + enterprise Windows/IIS/Oracle**.

# Senior Full-Stack Engineer — Interview Cheat Sheet

## 1. .NET / C# Core

### .NET 8 architecture

Know the difference:

| Concept              | Key point                                          |
| -------------------- | -------------------------------------------------- |
| .NET 8               | Modern cross-platform runtime                      |
| ASP.NET Core         | Web/API framework                                  |
| Kestrel              | Cross-platform web server                          |
| Middleware           | Request/response pipeline                          |
| Dependency Injection | Built into ASP.NET Core                            |
| Configuration        | `appsettings.json`, environment variables, secrets |
| Options Pattern      | Strongly typed configuration                       |
| Minimal APIs         | Lightweight HTTP APIs                              |
| Controllers          | MVC/Web API pattern                                |
| Hosted Service       | Background processing                              |
| `IHttpClientFactory` | Managed HTTP clients                               |

Typical request pipeline:

```text
Client
  ↓
Kestrel
  ↓
Middleware
  ├── Exception handling
  ├── HTTPS
  ├── Authentication
  ├── Authorization
  ├── Logging
  └── Routing
  ↓
Controller / Minimal API
  ↓
Application
  ↓
Domain
  ↓
Infrastructure
  ↓
Database / External Services
```

### C# topics to know

Be comfortable explaining:

* `async` / `await`
* `Task` vs `ValueTask`
* `IEnumerable` vs `IQueryable`
* `record` vs `class`
* `struct`
* Generics
* Delegates
* Events
* LINQ
* Dependency Injection
* SOLID
* Garbage collection
* `IDisposable` / `IAsyncDisposable`
* Thread safety
* `lock`
* `CancellationToken`
* Exception handling
* Pattern matching
* Nullable reference types

### Async

```csharp
public async Task<Order> GetOrderAsync(
    int id,
    CancellationToken cancellationToken)
{
    return await db.Orders
        .FirstAsync(x => x.Id == id, cancellationToken);
}
```

Remember:

> `async/await` does not automatically create a new thread.

For I/O-bound work, it allows the thread to be released while waiting.

---

# 2. ASP.NET Core

### Middleware vs Filters

**Middleware**

```text
HTTP Request
    ↓
Middleware
    ↓
Middleware
    ↓
Controller
```

Applies broadly to the HTTP pipeline.

**Filters**

Typically MVC/controller-specific:

* Authorization filter
* Resource filter
* Action filter
* Exception filter
* Result filter

### Dependency Injection lifetimes

```text
Singleton
   ↓
One instance for application lifetime

Scoped
   ↓
One instance per HTTP request

Transient
   ↓
New instance each resolution
```

Typical:

```text
DbContext → Scoped
Service   → Scoped
Stateless utility → Singleton/Transient
```

Never inject a scoped service into a singleton without understanding the lifetime implications.

---

# 3. Clean Architecture

Know this architecture:

```text
                ┌─────────────────────┐
                │     Presentation    │
                │ API / Controllers   │
                └──────────┬──────────┘
                           ↓
                ┌─────────────────────┐
                │     Application     │
                │ Use Cases / CQRS     │
                └──────────┬──────────┘
                           ↓
                ┌─────────────────────┐
                │       Domain        │
                │ Entities / Rules    │
                └─────────────────────┘
                           ↑
                ┌──────────┴──────────┐
                │   Infrastructure    │
                │ EF / AWS / APIs     │
                └─────────────────────┘
```

Dependency direction:

```text
Presentation → Application → Domain
Infrastructure ───────────→ Application/Domain
```

The key principle:

> Business logic should not depend on infrastructure details.

---

# 4. Entity Framework Core

### DbContext

```csharp
public class AppDbContext : DbContext
{
    public DbSet<Order> Orders => Set<Order>();
}
```

### Tracking vs No Tracking

```csharp
context.Orders
    .AsNoTracking()
    .ToListAsync();
```

Use `AsNoTracking()` for read-only queries.

### Loading strategies

```text
Eager      → Include()
Explicit   → Load()
Lazy       → Automatically loads navigation property
```

Know the **N+1 query problem**.

Bad:

```text
Get customers
   ↓
For each customer
   ↓
Query orders
```

Better:

```csharp
context.Customers
    .Include(c => c.Orders)
```

or project directly:

```csharp
.Select(x => new CustomerDto
{
    Id = x.Id,
    OrderCount = x.Orders.Count()
})
```

### EF performance

Know:

* Proper indexes
* Projection
* `AsNoTracking`
* Pagination
* Avoid unnecessary `Include`
* Avoid N+1
* Compiled queries when appropriate
* Batch operations
* Query execution plans
* Connection pooling

---

# 5. DDD — Domain-Driven Design

Know these concepts:

### Entity

Has identity.

```text
CustomerId = 123
```

### Value Object

Defined by its values rather than identity.

```text
Money
Address
EmailAddress
```

### Aggregate

Consistency boundary.

```text
Order
 ├── OrderItems
 └── ShippingAddress
```

`Order` could be the **Aggregate Root**.

External code should interact through:

```text
Order.AddItem()
Order.Cancel()
Order.Pay()
```

rather than directly modifying internal state.

### Other DDD concepts

Know:

* Entity
* Value Object
* Aggregate
* Aggregate Root
* Repository
* Domain Service
* Application Service
* Domain Event
* Bounded Context
* Ubiquitous Language
* Anti-Corruption Layer

### Bounded Context

Example:

```text
Customer Context
       │
       │
Order Context
       │
       │
Payment Context
```

Don't necessarily create one giant shared domain model.

---

# 6. Microservices Architecture

Know how to explain:

```text
                  API Gateway
                      │
        ┌─────────────┼─────────────┐
        ↓             ↓             ↓
    Order Service  Payment       Customer
        │          Service        Service
        ↓             ↓             ↓
    Order DB      Payment DB    Customer DB
```

Important principles:

* Independent deployment
* Independent scaling
* Loose coupling
* Service ownership
* Failure isolation
* API contracts
* Observability
* Event-driven communication
* Database-per-service where appropriate

### Synchronous vs asynchronous

```text
REST/gRPC
Service A ─────────→ Service B
```

vs.

```text
Service A
    │
    ↓
Message Broker
    │
    ↓
Service B
```

Use asynchronous communication when you want:

* Loose coupling
* Better resilience
* Buffering
* Independent processing
* Event-driven workflows

---

# 7. Event-Driven Architecture

Know:

```text
Producer
   ↓
Event / Message
   ↓
Broker
   ↓
Consumer
```

Examples:

* Kafka
* RabbitMQ
* Amazon SQS
* Amazon SNS
* EventBridge

### Event vs Command

**Command**

> "Do this."

```text
CreateOrder
```

**Event**

> "This happened."

```text
OrderCreated
```

### Important concepts

Know:

* Pub/Sub
* Consumer groups
* Partitioning
* Ordering
* At-least-once delivery
* Idempotency
* Retry
* Dead-letter queue
* Poison messages
* Eventual consistency
* Duplicate messages
* Outbox pattern

### Idempotency

If the same event arrives twice:

```text
OrderCreated
OrderCreated
```

Your consumer should not create two orders.

Use:

```text
EventId
   ↓
Check processed events
   ↓
Already processed?
   ├── Yes → Ignore
   └── No  → Process
```

---

# 8. OAuth / Authentication / Authorization

This is a likely interview area.

### Authentication vs Authorization

```text
Authentication
"Who are you?"

Authorization
"What are you allowed to do?"
```

### OAuth 2.0

OAuth is primarily an **authorization framework**.

Typical flow:

```text
User
 ↓
Client Application
 ↓
Authorization Server
 ↓
Access Token
 ↓
API
```

### OpenID Connect

Know:

> OAuth 2.0 + identity layer = OpenID Connect.

OIDC provides an **ID Token** containing identity information.

### JWT

Typical:

```text
Header.Payload.Signature
```

Payload might contain:

```json
{
  "sub": "123",
  "aud": "orders-api",
  "iss": "auth-server",
  "exp": 1780000000,
  "scope": "orders.read"
}
```

Never trust arbitrary client-provided claims without validating the token.

Validate:

* Signature
* Issuer
* Audience
* Expiration
* Not-before
* Scopes/roles

---

# 9. Backend Security

Memorize:

```text
Authentication
Authorization
Input Validation
Output Encoding
TLS
Secrets Management
Least Privilege
Audit Logging
Rate Limiting
Secure Headers
Dependency Security
```

### Common attacks

Know:

* SQL Injection
* XSS
* CSRF
* SSRF
* Broken access control
* Authentication attacks
* Sensitive data exposure
* Deserialization vulnerabilities
* Path traversal

### SQL Injection

Bad:

```csharp
$"SELECT * FROM Users WHERE Name = '{name}'"
```

Good:

```csharp
context.Users
    .Where(x => x.Name == name)
```

EF parameterizes queries.

---

# 10. Docker

Know the difference:

```text
Docker Image
    ↓
Container
```

### Image

Immutable package containing:

```text
Application
Runtime
Dependencies
Configuration defaults
```

### Container

Running instance of an image.

Example:

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app

COPY . .

ENTRYPOINT ["dotnet", "MyApp.dll"]
```

### Important Docker concepts

Know:

* Dockerfile
* Image
* Container
* Registry
* Volume
* Network
* Multi-stage builds
* Environment variables
* Health checks
* Container security

### Multi-stage build

```text
SDK image
   ↓
Build
   ↓
Publish
   ↓
Runtime image
```

Produces a smaller production image.

---

# 11. AWS

This JD specifically mentions:

```text
S3
Lambda
API Gateway
RDS
```

Know these deeply.

### API Gateway

```text
Client
  ↓
API Gateway
  ↓
Lambda / ECS / other backend
```

Know:

* REST API
* HTTP API
* Authentication
* Authorization
* Throttling
* CORS
* Stages
* Custom domains
* Integration
* Logging

### Lambda

Serverless compute.

Important:

```text
Event
 ↓
Lambda
 ↓
Response
```

Know:

* Cold starts
* Timeout
* Memory
* Concurrency
* Reserved concurrency
* Environment variables
* IAM role
* Layers
* Dead-letter handling
* CloudWatch logs

### S3

Object storage.

Know:

* Bucket
* Object
* Versioning
* Lifecycle
* Encryption
* IAM policies
* Bucket policies
* Presigned URLs
* Event notifications

### RDS

Managed relational database.

Know:

* Multi-AZ
* Read replicas
* Backups
* Snapshots
* Encryption
* Security groups
* Parameter groups
* Connection pooling

Supported engines include:

```text
SQL Server
PostgreSQL
MySQL
MariaDB
Oracle
Db2
```

---

# 12. AWS Architecture Question

Be able to design:

```text
                   Internet
                      │
                      ↓
                API Gateway
                      │
                      ↓
                  Lambda
                      │
             ┌────────┴────────┐
             ↓                 ↓
            S3                RDS
```

For containerized .NET:

```text
Internet
   ↓
ALB
   ↓
ECS / EKS
   ↓
.NET Microservices
   ↓
RDS / DynamoDB
```

---

# 13. Legacy .NET Framework 4.x

This JD explicitly wants legacy modernization experience.

Know differences:

| .NET Framework        | Modern .NET            |
| --------------------- | ---------------------- |
| Windows-focused       | Cross-platform         |
| IIS                   | Kestrel + IIS possible |
| `web.config`          | `appsettings.json`     |
| System.Web            | ASP.NET Core           |
| WebForms              | MVC/Razor/Blazor/etc.  |
| .NET Framework 4.x    | .NET 8                 |
| Often tightly coupled | Better modularity      |

### Incremental modernization

Don't necessarily rewrite everything.

Example:

```text
Legacy WebForms
      ↓
Extract business logic
      ↓
Create API
      ↓
ASP.NET Core service
      ↓
Move functionality gradually
      ↓
Retire legacy modules
```

Patterns worth knowing:

* Strangler Fig Pattern
* Anti-Corruption Layer
* Branch by abstraction
* Feature flags
* API façade
* Incremental migration

---

# 14. ASP.NET WebForms

Know basic concepts:

```text
.aspx
.aspx.cs
```

Important concepts:

* Page lifecycle
* ViewState
* PostBack
* Server controls
* Session
* Application state
* Master Pages
* User Controls
* Web.config

### WebForms lifecycle

Simplified:

```text
Init
 ↓
Load ViewState
 ↓
Load PostData
 ↓
Load
 ↓
PostBack Events
 ↓
PreRender
 ↓
Render
 ↓
Unload
```

A common interview question is:

> Why is ViewState problematic?

Because it can create large page payloads and increase response size/performance overhead.

---

# 15. IIS / Windows Server

Know:

```text
Internet
   ↓
IIS
   ↓
Application Pool
   ↓
ASP.NET Application
```

### IIS concepts

Know:

* Sites
* Bindings
* Application Pools
* Worker Process (`w3wp.exe`)
* Application Pool identity
* HTTPS certificates
* Authentication
* Authorization
* Logging
* Recycling
* Windows Authentication
* Reverse proxy

### Application Pool

Controls:

* Worker process
* Identity
* Runtime configuration
* Recycling
* Memory limits

---

# 16. Web.config Transformations

Know environment-specific configuration.

Example:

```text
Web.config
Web.Debug.config
Web.Release.config
```

Transform:

```xml
<connectionStrings>
```

can be changed during deployment.

Typical:

```text
Development
     ↓
Web.config

Staging
     ↓
Web.Staging.config

Production
     ↓
Web.Production.config
```

Know XML transformation syntax:

```xml
xdt:Transform
xdt:Locator
```

---

# 17. Oracle Database

This is another area where they may go deep.

Know:

### SQL

* Joins
* Subqueries
* CTE
* Window functions
* Aggregation
* Indexes
* Transactions
* Views
* Stored procedures
* Functions
* Packages

### Oracle-specific

Know:

* `ROWNUM`
* `ROW_NUMBER()`
* `MERGE`
* Sequences
* Synonyms
* PL/SQL
* Cursors
* Tablespaces
* Explain Plan

### Query optimization

Think:

```text
Slow query
   ↓
Execution Plan
   ↓
Full table scan?
   ↓
Missing/wrong index?
   ↓
Bad join?
   ↓
Too much data?
   ↓
Statistics?
```

Don't blindly add indexes.

Indexes improve reads but can hurt:

```text
INSERT
UPDATE
DELETE
```

---

# 18. Oracle + .NET

Know common approaches:

```text
.NET
  ↓
Oracle Managed Data Access
  ↓
Oracle Database
```

EF Core can also be used with Oracle through Oracle's provider.

Understand:

* Connection strings
* Connection pooling
* Transactions
* Parameterized queries
* Mapping
* Oracle data types
* Stored procedures

---

# 19. Java

The JD mentions both Java and Quarkus.

You should know Java backend fundamentals:

```text
JVM
JDK
JRE
```

Important:

* OOP
* Interfaces
* Abstract classes
* Collections
* Streams
* Lambdas
* Generics
* Exceptions
* Concurrency
* CompletableFuture
* Dependency injection
* REST
* Maven/Gradle

### C# vs Java

| C#               | Java                   |
| ---------------- | ---------------------- |
| .NET CLR         | JVM                    |
| `async/await`    | `CompletableFuture`    |
| LINQ             | Streams                |
| NuGet            | Maven/Gradle           |
| ASP.NET Core     | Quarkus/Spring         |
| `Task<T>`        | `CompletableFuture<T>` |
| Entity Framework | JPA/Hibernate          |

---

# 20. Quarkus

Important because it's specifically listed.

Quarkus is designed for **cloud-native Java**.

Typical:

```text
HTTP
 ↓
Quarkus REST API
 ↓
Service
 ↓
Hibernate ORM
 ↓
Database
```

Know:

* RESTEasy Reactive / Quarkus REST
* CDI
* Hibernate ORM
* Panache
* Configuration
* Maven
* Native executable
* Kubernetes
* Container deployment
* Health checks
* OpenTelemetry

### Why Quarkus?

Key selling points:

```text
Fast startup
Low memory consumption
Container/Kubernetes friendly
Cloud-native
Native compilation
```

---

# 21. OpenTelemetry

Very important for this JD.

Purpose:

> Standardized collection of telemetry data.

Three pillars:

```text
Logs
Metrics
Traces
```

Distributed tracing:

```text
Request
 │
 ↓
API Gateway
 │ Trace ID: abc
 ↓
Order Service
 │ Trace ID: abc
 ↓
Payment Service
 │ Trace ID: abc
 ↓
Database
```

A **trace** represents the entire request.

A **span** represents one operation within the trace.

```text
Trace
 ├── API span
 ├── Order service span
 ├── Payment service span
 └── DB span
```

Know:

* Trace ID
* Span ID
* Context propagation
* Instrumentation
* OTLP
* Collector
* Jaeger
* AWS X-Ray integration concepts

---

# 22. Unit Testing

.NET:

```text
xUnit
NUnit
MSTest
```

Typical:

```csharp
[Fact]
public void Add_ShouldIncreaseTotal()
{
    // Arrange
    // Act
    // Assert
}
```

### AAA

```text
Arrange
   ↓
Act
   ↓
Assert
```

Know:

* Unit vs integration tests
* Mocking
* Test doubles
* Dependency isolation
* Test coverage
* Parameterized tests
* Test naming

### What should NOT be heavily mocked?

Pure domain logic.

Ideally:

```text
Domain
   ↓
Pure unit tests
```

Infrastructure:

```text
Repository
   ↓
Integration tests
```

---

# 23. Storybook / Design System

Storybook allows frontend teams to develop UI components independently.

```text
Button
Input
Modal
Table
Dropdown
Card
```

Example:

```text
Design System
     │
     ├── Button
     ├── Input
     ├── Form
     ├── Modal
     └── Table
```

Know:

* Components
* Stories
* Props
* Controls
* Documentation
* Visual regression testing
* Accessibility testing

---

# 24. Frontend — HTML/CSS/JavaScript

### HTML

Know:

* Semantic HTML
* Forms
* Accessibility
* DOM
* Attributes

### CSS

Know:

* Flexbox
* Grid
* Positioning
* Responsive design
* Media queries
* Specificity
* Box model

### JavaScript

Know:

* `let` / `const`
* Closures
* Promises
* `async/await`
* Event loop
* Event delegation
* Modules
* Destructuring
* Spread/rest
* Array methods
* DOM
* Fetch API

### Event loop

Important interview concept:

```text
Call Stack
    ↓
Web APIs
    ↓
Callback Queue
    ↓
Event Loop
    ↓
Call Stack
```

---

# 25. React / SPA

Preferred qualification mentions React.

Know:

```text
Component
   ↓
Props
   ↓
State
   ↓
Event
   ↓
State update
   ↓
Re-render
```

Important:

* Components
* Props
* State
* Hooks
* `useState`
* `useEffect`
* `useMemo`
* `useCallback`
* Context
* React Router
* Forms
* API calls
* Error handling
* Loading states

Understand when **not** to use `useEffect`.

---

# 26. Node.js

Know the basic architecture:

```text
JavaScript
    ↓
Node.js
    ↓
V8 Engine
    ↓
Event Loop
    ↓
Non-blocking I/O
```

Important:

* npm
* package.json
* Express/Fastify
* Middleware
* REST APIs
* Streams
* EventEmitter
* Async programming
* Environment variables
* Error handling

Node is particularly suitable for:

> I/O-heavy workloads where non-blocking asynchronous processing is beneficial.

---

# 27. CI/CD + DevOps

Know:

```text
Developer
   ↓
Git
   ↓
Build
   ↓
Unit Tests
   ↓
Security Scan
   ↓
Package
   ↓
Docker Image
   ↓
Registry
   ↓
Deploy
   ↓
Smoke Tests
```

Examples:

* GitHub Actions
* GitLab CI
* Azure DevOps
* Jenkins
* AWS CodePipeline/CodeBuild

### Deployment strategies

Know:

```text
Rolling
Blue/Green
Canary
Feature Flag
```

### Blue/Green

```text
Production
   ↓
Blue → Current

Green → New Version

Switch traffic
   ↓
Green
```

---

# 28. Generative AI + Spec-Driven Development

This is a **modern and potentially important differentiator** in the JD.

Understand the idea:

```text
Business Requirement
       ↓
Specification
       ↓
Acceptance Criteria
       ↓
AI-assisted Implementation
       ↓
Automated Tests
       ↓
AI Code Review
       ↓
Human Review
       ↓
Production
```

### SDD

The important idea is:

> **Specification becomes the source of truth before implementation.**

Example:

```text
Requirement:

Customer can cancel an order
within 30 minutes of creation.
```

Turn into:

```text
Given:
Order created 10 minutes ago

When:
Customer cancels order

Then:
Order status = CANCELLED
```

Then AI can help generate:

```text
Domain model
API
Tests
Database changes
Documentation
```

### AI coding workflow

Good interview answer:

```text
Human defines requirement
        ↓
Create technical specification
        ↓
AI generates implementation
        ↓
AI generates tests
        ↓
Run compiler/tests/static analysis
        ↓
Human reviews
        ↓
Security review
        ↓
Merge
```

Important:

> AI-generated code still requires human validation, especially for security, correctness, performance, and business rules.

---

# 29. Microservices + AI Example

Be able to explain an end-to-end design:

```text
                    React
                      │
                      ↓
                API Gateway
                      │
          ┌───────────┼───────────┐
          ↓           ↓           ↓
       Order       Customer     Payment
      Service      Service      Service
        │             │            │
        ↓             ↓            ↓
      RDS           RDS          RDS
        │
        ↓
      Event
        │
        ↓
   EventBridge/SQS/Kafka
        │
        ├──────────────→ Notification
        │
        └──────────────→ Analytics
```

Observability:

```text
OpenTelemetry
      ↓
Trace / Metrics / Logs
      ↓
Observability platform
```

Security:

```text
OAuth/OIDC
   ↓
JWT
   ↓
API Gateway
   ↓
Services
```

---

# 30. Unix vs Windows

### Windows

Know:

```text
IIS
Windows Services
PowerShell
Event Viewer
Windows Server
NTFS permissions
Active Directory
```

### Linux/Unix

Know:

```bash
ps
top
grep
curl
netstat/ss
chmod
chown
systemctl
journalctl
tail
```

Containers are commonly Linux-based even when your development background is .NET/Windows.

---

# 31. Agile

Know the terminology:

```text
Product Backlog
     ↓
Sprint Planning
     ↓
Development
     ↓
Daily Scrum
     ↓
Review
     ↓
Retrospective
```

Know:

* User stories
* Acceptance criteria
* Definition of Done
* Sprint
* Backlog
* Estimation
* Refinement
* Scrum/Kanban

For senior-level interviews, emphasize:

> Breaking ambiguous requirements into smaller deliverable increments.

---

# 32. High-Probability System Design Questions

Prepare these particularly well:

### Q1. Design a .NET microservices application

Discuss:

```text
API Gateway
Microservices
Database
Messaging
Caching
Authentication
Observability
Deployment
```

### Q2. How would you migrate .NET Framework 4.x to .NET 8?

Answer:

```text
Assess
 ↓
Characterize existing behavior
 ↓
Extract business logic
 ↓
Introduce APIs/interfaces
 ↓
Strangler pattern
 ↓
Incremental migration
 ↓
Feature flags
 ↓
Testing
 ↓
Production migration
 ↓
Remove legacy
```

### Q3. How do you make an event consumer reliable?

Discuss:

* Idempotency
* Retries
* Exponential backoff
* DLQ
* Transaction boundaries
* Outbox pattern
* Monitoring
* Poison messages

### Q4. API security?

```text
HTTPS
 ↓
OAuth/OIDC
 ↓
JWT validation
 ↓
Authorization
 ↓
Input validation
 ↓
Rate limiting
 ↓
Audit logging
 ↓
Secrets management
```

### Q5. Production API is slow. What do you investigate?

Use this sequence:

```text
Client
 ↓
API Gateway
 ↓
Application
 ↓
External APIs
 ↓
Database
 ↓
Infrastructure
```

Check:

* Distributed traces
* Logs
* Metrics
* CPU
* Memory
* GC
* Thread pool
* DB execution plans
* Connection pool
* Network latency
* External API latency
* N+1 queries
* Cache hit rate

---

# 33. Must-Know Comparison Table

| Topic         | Remember                               |
| ------------- | -------------------------------------- |
| .NET 8        | Modern cross-platform runtime          |
| ASP.NET Core  | Web/API framework                      |
| EF Core       | ORM                                    |
| DDD           | Model business domain                  |
| Aggregate     | Consistency boundary                   |
| OAuth         | Authorization framework                |
| OIDC          | Authentication/identity layer on OAuth |
| JWT           | Token format                           |
| Docker        | Containerization                       |
| S3            | Object storage                         |
| Lambda        | Serverless compute                     |
| API Gateway   | API entry point                        |
| RDS           | Managed relational DB                  |
| SQS           | Queue                                  |
| SNS           | Pub/sub notification                   |
| EventBridge   | Event bus                              |
| Kafka         | Distributed event streaming            |
| OpenTelemetry | Telemetry standard                     |
| Quarkus       | Cloud-native Java framework            |
| IIS           | Windows web server                     |
| WebForms      | Legacy ASP.NET UI framework            |
| Oracle        | Enterprise RDBMS                       |
| Storybook     | UI component development/documentation |
| React         | SPA UI library                         |
| Node.js       | JS server runtime                      |
| CI/CD         | Automated build/test/deploy            |
| DDD           | Domain modeling                        |
| SDD           | Specification-first development        |

---

# 34. 15 Questions I Would Expect From This JD

You should be able to answer these **without notes**:

1. **What's new/different about .NET 8 compared with .NET Framework 4.x?**
2. **Explain ASP.NET Core middleware pipeline.**
3. **Explain Singleton, Scoped and Transient DI lifetimes.**
4. **How do you optimize an EF Core query?**
5. **What is the N+1 problem?**
6. **Explain DDD Aggregate and Aggregate Root.**
7. **How would you design communication between microservices?**
8. **How do you guarantee an event consumer doesn't process a message twice?**
9. **OAuth vs OIDC vs JWT — what's the difference?**
10. **How would you secure a .NET REST API?**
11. **Design a .NET 8 application on AWS.**
12. **How would you incrementally migrate a .NET Framework 4.x WebForms application to .NET 8?**
13. **How would you troubleshoot a slow Oracle query?**
14. **Explain Quarkus and OpenTelemetry.**
15. **How would you use GenAI + Spec-Driven Development to build and review a feature?**

---

# 35. Your Highest-Priority Study Areas

Given the breadth of this JD, I would structure your preparation like this:

```text
                 ★★★★★
             .NET 8 / C#
                  │
        ┌─────────┼─────────┐
        ↓         ↓         ↓
      EF Core   Microservices  AWS
        │         │            │
        ↓         ↓            ↓
       DDD     Event Driven   Lambda
        │         │          S3/RDS
        │         │        API Gateway
        └─────────┼────────────┘
                  ↓
             Security/OAuth
                  │
        ┌─────────┼─────────┐
        ↓         ↓         ↓
    Legacy .NET  Oracle   Quarkus
       /IIS       DB     + OpenTelemetry
        │
        ↓
     Frontend
 React/JS/HTML/CSS
        │
        ↓
     Testing
        │
        ↓
   CI/CD + Docker
        │
        ↓
    GenAI + SDD
```

### If the interview is soon, prioritize:

**Tier 1 — absolutely master**

* C# / .NET 8
* ASP.NET Core
* EF Core
* REST APIs
* Microservices
* Event-driven architecture
* OAuth/OIDC/JWT
* AWS fundamentals
* Docker
* Unit testing
* System design

**Tier 2 — be interview-ready**

* DDD
* Legacy .NET Framework/WebForms
* IIS/Windows Server
* Oracle optimization
* React/JavaScript
* CI/CD
* Node.js

**Tier 3 — understand and be able to discuss**

* Java
* Quarkus
* OpenTelemetry
* Storybook
* GenAI + SDD

The **interesting part of this JD** is that it isn't simply a ".NET developer" position. It combines **modern .NET 8 + legacy modernization + AWS + Java/Quarkus + enterprise Windows/Oracle + frontend + GenAI development practices**. For a senior interview, I'd expect architecture and production-troubleshooting questions to matter almost as much as syntax.
