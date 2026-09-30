# AWS Certified Cloud Practitioner — CLF-C02

## 4-Page A4 Comprehensive Cheat Sheet

> **Source:** your uploaded CLF-C02 slide deck. This version is deliberately denser than the previous one and includes the major services/topics covered throughout the deck, including several lower-frequency services. 

---

# PAGE 1 — CLOUD, IAM, COMPUTE & STORAGE

## 1. ☁️ Cloud Fundamentals

### Cloud advantages

* **Pay-as-you-go** → no large upfront infrastructure investment
* **Economies of scale** → AWS's large scale reduces costs
* **Stop guessing capacity** → provision resources as needed
* **Elasticity** → automatically increase/decrease resources
* **Agility** → rapidly experiment and deploy
* **Global reach** → deploy close to customers
* **High availability** → redundant infrastructure
* **Managed services** → AWS handles infrastructure operations

### Scalability

* **Vertical scaling** → bigger machine
* **Horizontal scaling** → more machines
* **Elasticity** → automatically scale according to demand

### CAPEX vs OPEX

| CAPEX                    | OPEX                       |
| ------------------------ | -------------------------- |
| Buy hardware             | Pay for usage              |
| Large upfront investment | Variable cost              |
| Hardware maintenance     | AWS manages infrastructure |

### Cloud models

**Public** → AWS/cloud provider owns infrastructure
**Private** → dedicated infrastructure
**Hybrid** → combination of on-premises + cloud

### Service models

**IaaS** → EC2
**PaaS** → Elastic Beanstalk
**SaaS** → complete application

---

# 2. 🌎 AWS Global Infrastructure

**Region** → geographic area containing multiple AZs

**Availability Zone**

* One or more datacenters
* Separate power/networking
* Designed for isolation

**Edge Location**

* CloudFront content cache
* Located close to users

**Local Zones**

* AWS infrastructure close to specific metropolitan areas
* Low-latency workloads

**Wavelength**

* AWS infrastructure inside/near 5G networks

**Outposts**

* AWS infrastructure installed in customer's datacenter

### Remember

```text
Region
 ├── AZ
 ├── AZ
 └── AZ

Users
  ↓
Edge Location
  ↓
CloudFront
  ↓
AWS Region
```

---

# 3. 🔐 IAM

### Components

| Component | Meaning                   |
| --------- | ------------------------- |
| User      | Individual identity       |
| Group     | Collection of users       |
| Role      | Temporary permissions     |
| Policy    | JSON permissions          |
| MFA       | Additional authentication |

**IAM is global.**

### Policy

```text
{
  Version,
  Statement: [{
    Effect,
    Principal,
    Action,
    Resource,
    Condition
  }]
}
```

### Policy evaluation

```text
Explicit Deny
     ↓
   DENY

No Allow
     ↓
Implicit DENY

Allow + No Explicit Deny
     ↓
   ALLOW
```

**Explicit Deny always wins.**

### IAM best practices

* Don't use root for everyday work
* Enable MFA
* Least privilege
* Use roles/temporary credentials
* Don't create unnecessary long-lived access keys
* Use IAM Access Analyzer

### Root user

Complete account access.

Root-only examples in the deck:

* Change account settings
* Close account
* Change/cancel Support plan
* Certain tax invoices
* Enable certain S3 MFA functionality
* Sign up for GovCloud

---

# 4. 🖥️ EC2

**EC2 = Infrastructure as a Service / virtual server**

### EC2 components

* AMI
* Instance type
* EBS
* Security Group
* User Data
* Key pair
* Elastic IP

### Instance families

| Family            | Workload      |
| ----------------- | ------------- |
| General Purpose   | Balanced      |
| Compute Optimized | CPU-intensive |
| Memory Optimized  | Large memory  |
| Storage Optimized | High disk I/O |
| Accelerated       | GPU/FPGA/ML   |

### User Data

Script executed when instance launches.

### Security Group

* Instance-level firewall
* **Stateful**
* ALLOW rules
* Inbound denied by default
* Outbound allowed by default

### Ports

`22 SSH`
`21 FTP`
`80 HTTP`
`443 HTTPS`
`3389 RDP`

---

## 5. 💰 EC2 Pricing

| Option                   | Key idea                        |
| ------------------------ | ------------------------------- |
| **On-Demand**            | Flexible, no commitment         |
| **Reserved Instance**    | 1/3-year commitment             |
| **Convertible RI**       | Change instance attributes      |
| **Savings Plans**        | Commit to $/hour usage          |
| **Spot**                 | Very cheap, can be interrupted  |
| **Dedicated Host**       | Entire physical server          |
| **Dedicated Instance**   | Hardware dedicated to you       |
| **Capacity Reservation** | Reserve capacity in specific AZ |

### Spot

Best for:

* Batch
* Data analysis
* Image processing
* Fault-tolerant workloads

**Not suitable for critical workloads that cannot tolerate interruption.**

---

# 6. 💾 EC2 Storage

### EBS

**Block storage attached to EC2**

* Persistent
* Usually tied to an AZ
* Snapshots stored in S3
* Can copy snapshots across AZ/Region

### EBS Snapshot

Point-in-time backup of EBS.

### AMI

**Amazon Machine Image**

* OS + software + configuration
* Used to launch EC2 instances
* Region-specific but can be copied

### Instance Store

* Physical disk attached to host
* Very high performance
* **Ephemeral** → data lost when instance stops/terminates

### EFS

Managed shared file system.

```text
EC2 ─┐
EC2 ─┼── EFS
EC2 ─┘
```

---

# 7. ⚖️ ELB + Auto Scaling

### Load Balancers

**ALB**

* Layer 7
* HTTP/HTTPS
* Path/host-based routing

**NLB**

* Layer 4
* TCP/UDP/TLS
* Very high performance

**GWLB**

* Network/security appliances

### Auto Scaling Group

```text
Minimum ← Desired → Maximum
```

Can:

* Scale out/in
* Replace unhealthy instances
* Distribute across AZs
* Use scaling policies

---

# PAGE 2 — S3, DATABASES, SERVERLESS & NETWORKING

# 8. 🪣 Amazon S3

**S3 = Object Storage**

```text
Bucket
 └── Object
      ├── Key
      ├── Data
      └── Metadata
```

### S3 durability

**99.999999999% = 11 nines**

### Storage Classes

| Class                      | Think                            |
| -------------------------- | -------------------------------- |
| Standard                   | Frequent access                  |
| Intelligent-Tiering        | Unknown/changing access          |
| Standard-IA                | Infrequent                       |
| One Zone-IA                | Infrequent + one AZ              |
| Glacier Instant Retrieval  | Archive + instant                |
| Glacier Flexible Retrieval | Archive                          |
| Glacier Deep Archive       | Cheapest long-term archive       |
| S3 Express One Zone        | Very high performance, single AZ |

### Important S3 features

**Versioning**
→ protects against accidental overwrite/deletion

**Lifecycle**
→ automatically transition/delete objects

**CRR**
→ Cross-Region Replication

**SRR**
→ Same-Region Replication

**Presigned URL**
→ temporary access to private object

**Multipart Upload**
→ upload large files in parts

**Transfer Acceleration**
→ faster global uploads/downloads

**Object Lock**
→ WORM / prevent object modification/deletion

**Static Website Hosting**
→ host static website from S3

---

# 9. 🗄️ Database Services

### RDS

Managed relational databases.

Supported engines include:

* MySQL
* PostgreSQL
* MariaDB
* Oracle
* SQL Server

### RDS Multi-AZ

**High availability + automatic failover**

### RDS Read Replica

**Read scaling**

> **Multi-AZ = HA**
> **Read Replica = performance/read scaling**

### Aurora

AWS-built relational database compatible with MySQL/PostgreSQL.

---

### DynamoDB

**Managed NoSQL key-value/document database**

* Serverless
* Massive scale
* Single-digit millisecond performance
* Highly available
* Auto scaling

**Global Tables**
→ Multi-Region active-active read/write.

**DAX**
→ in-memory cache specifically for DynamoDB.

### ElastiCache

Managed:

* Redis
* Memcached

Use for:

* Caching
* Reducing DB load
* Low-latency access

> **DAX → DynamoDB only**
> **ElastiCache → broader database/application caching**

---

# 10. 📊 Analytics

### Redshift

**Data warehouse / OLAP**

* Analytics
* PB-scale
* Columnar storage
* SQL
* BI/reporting

### Athena

**Serverless SQL query on S3**

```text
S3 data
   ↓
Athena
   ↓
SQL query
```

### EMR

Big-data processing:

* Hadoop
* Spark
* HBase
* Presto
* Flink

### QuickSight

Business intelligence / dashboards / visualization.

---

# 11. ⚡ Serverless & Containers

### Lambda

**Serverless Function-as-a-Service**

* Event driven
* Automatically scales
* Pay for execution
* Maximum execution time **15 minutes**

Examples:

* S3 upload → Lambda
* API Gateway → Lambda
* Scheduled jobs

### API Gateway

Create/manage HTTP APIs.

### ECS

AWS container orchestration.

### EKS

Managed Kubernetes.

### Fargate

Run containers **without managing EC2 servers**.

### ECR

Private container image registry.

### AWS Batch

Batch computing jobs.

> **Lambda → function**
> **Fargate → containers**
> **Batch → long-running/batch workloads**

### Lightsail

Simple:

* VPS
* Storage
* Database
* Networking

Predictable pricing and simpler than EC2/RDS/etc.

### Elastic Beanstalk

Deploy applications while AWS manages infrastructure.

---

# 12. 📨 Application Integration

### SQS

**Queue / decoupling**

```text
Producer → SQS → Consumer
```

### SNS

**Pub/Sub / fan-out**

```text
              → Consumer 1
Publisher → SNS → Consumer 2
              → Consumer 3
```

### Kinesis

Real-time data streaming.

### Amazon MQ

Managed traditional message brokers.

### Step Functions

Serverless workflow orchestration:

* Sequential
* Parallel
* Conditions
* Retry/error handling
* Human approval workflows

---

# 13. 🌐 VPC

**VPC = private virtual network**

### Components

**Subnet**
→ partition of VPC; associated with an AZ

**Route Table**
→ determines traffic path

**Internet Gateway**
→ internet connectivity

**NAT Gateway**
→ private subnet → outbound internet

**VPC Endpoint**
→ private access to AWS services

### Public vs Private

```text
PUBLIC SUBNET
EC2 → Route Table → IGW → Internet

PRIVATE SUBNET
EC2 → NAT Gateway → IGW → Internet
```

Private instances remain inaccessible directly from internet.

---

## Security Group vs NACL

| Security Group                       | NACL                                      |
| ------------------------------------ | ----------------------------------------- |
| Instance level                       | Subnet level                              |
| Stateful                             | Stateless                                 |
| ALLOW only                           | ALLOW + DENY                              |
| References IP/SG                     | IP-based rules                            |
| Return traffic automatically allowed | Return traffic must be explicitly allowed |

### VPC Flow Logs

Capture network traffic metadata.

---

# PAGE 3 — NETWORKING, SECURITY, MONITORING & GOVERNANCE

# 14. 🔗 VPC Connectivity

### VPC Peering

Connect two VPCs.

### Transit Gateway

Central hub connecting:

* Multiple VPCs
* VPN
* Direct Connect

### Site-to-Site VPN

Encrypted connection over internet.

### Direct Connect

Dedicated private network connection from on-premises to AWS.

> **VPN = internet + encryption**
> **Direct Connect = dedicated connection**

### VPC Endpoint

Access AWS services privately without traversing public internet.

---

# 15. 🌍 Route 53

**Managed DNS**

### Records

* A → IPv4
* AAAA → IPv6
* CNAME → hostname → hostname
* Alias → AWS resource

### Routing Policies

| Policy       | Purpose                  |
| ------------ | ------------------------ |
| Simple       | Basic routing            |
| Weighted     | Percentage distribution  |
| Latency      | Lowest latency           |
| Failover     | Primary/secondary        |
| Geolocation  | User location            |
| Geoproximity | Geographic distance      |
| Multivalue   | Multiple healthy records |

**Route 53 = DNS**

---

# 16. 🚀 CloudFront & Global Accelerator

### CloudFront

**CDN**

```text
User
 ↓
Nearest Edge Location
 ↓
Cache / Origin
```

Use for:

* Lower latency
* Cached content
* Global distribution
* Static/dynamic content

Integrates with:

* S3
* ALB
* EC2
* API Gateway
* WAF
* Shield

### Global Accelerator

Improves global application availability/performance using AWS global network.

### S3 Transfer Acceleration

Accelerates transfers **to/from S3** over AWS edge network.

---

# 17. 🔒 Security

### KMS

**Encryption key management**

Used with:

* S3
* EBS
* RDS
* Redshift
* EFS

### CloudHSM

Dedicated hardware security module.

> **KMS → AWS-managed key infrastructure**
> **CloudHSM → dedicated HSM; customer controls keys**

### ACM

AWS Certificate Manager:

* SSL/TLS certificates
* HTTPS
* Automatic renewal

### Secrets Manager

Store/rotate secrets such as passwords.

### Parameter Store

Configuration parameters and secrets.

---

# 18. 🛡️ Security Protection

### WAF

**Web Application Firewall — Layer 7**

Protects against:

* SQL injection
* XSS
* Malicious HTTP requests
* IP/geo restrictions
* Rate-based attacks

Used with:

* CloudFront
* ALB
* API Gateway

### Shield

**DDoS protection**

### Network Firewall

Protects VPC traffic from Layer 3–7 attacks.

### Firewall Manager

Central management of security rules across AWS Organization.

---

# 19. 🔍 Threat Detection & Compliance

| Service                 | Purpose                           |
| ----------------------- | --------------------------------- |
| **GuardDuty**           | Threat detection                  |
| **Inspector**           | Vulnerability management          |
| **Macie**               | Sensitive data discovery in S3    |
| **Security Hub**        | Central security findings         |
| **IAM Access Analyzer** | External resource access          |
| **Artifact**            | Compliance reports                |
| **Config**              | Resource configuration/compliance |

### GuardDuty

Analyzes signals such as:

* VPC/DNS activity
* CloudTrail
* threat intelligence

### Inspector

Finds vulnerabilities in:

* EC2
* ECR images
* Lambda

### Macie

Discovers/protects sensitive data in S3.

---

# 20. 👥 Organizations & Access

### AWS Organizations

Manage multiple AWS accounts.

Features:

* Organizational Units
* Consolidated billing
* Service Control Policies

### SCP

**Service Control Policy**

Defines maximum permissions available to accounts/OUs.

> SCP **doesn't grant permissions**.
> IAM policies grant permissions.

### IAM Identity Center

Central workforce:

* SSO
* Access to multiple AWS accounts/applications

### STS

Temporary security credentials.

### Cognito

Authentication/authorization for **application users**.

> **IAM → AWS resources**
> **Cognito → application customers/users**

---

# 21. 📊 Monitoring

### CloudWatch

* Metrics
* Logs
* Alarms
* Dashboards
* Events/EventBridge
* Billing metrics

### CloudTrail

**API auditing**

Answers:

> Who did what, when, from where?

### Config

Tracks resource configuration/compliance.

### X-Ray

Distributed application tracing:

* Bottlenecks
* Dependencies
* Errors
* Latency

### Health Dashboard

**Service Health**
→ overall AWS service status

**Account Health**
→ AWS events affecting your account/resources

---

# 22. 🧰 Management & Developer Tools

### CloudFormation

Infrastructure as Code.

```text
Template
   ↓
CloudFormation
   ↓
AWS Resources
```

### CDK

Define infrastructure using programming languages → generates CloudFormation.

### Systems Manager

Manage EC2/on-premises servers:

* Run commands
* Patch
* Parameters
* Session Manager

### Developer tools

**CodeCommit** → source control
**CodeBuild** → build/test
**CodeDeploy** → deployment
**CodePipeline** → CI/CD pipeline
**CodeArtifact** → package repository

---

# 23. 🔄 Event & Workflow Services

**EventBridge**
→ event bus / scheduled events

**Step Functions**
→ workflow orchestration

**SNS**
→ notifications/fan-out

**SQS**
→ buffering/decoupling

**Kinesis**
→ streaming

### Easy distinction

```text
Event happens       → EventBridge
Need workflow       → Step Functions
Need queue          → SQS
Need notification   → SNS
Need streaming      → Kinesis
```

---

# PAGE 4 — MIGRATION, BILLING, ARCHITECTURE, AI & EXAM TRAPS

# 24. 🚚 Migration Services

| Requirement                 | Service                                 |
| --------------------------- | --------------------------------------- |
| Database migration          | **DMS**                                 |
| Server lift-and-shift       | **Application Migration Service (MGN)** |
| Discover on-prem systems    | **Application Discovery Service**       |
| Migration planning/tracking | **Migration Hub**                       |
| Migration business case     | **Migration Evaluator**                 |
| Online data transfer        | **DataSync**                            |
| Hybrid storage              | **Storage Gateway**                     |
| Massive offline data        | **Snow Family**                         |

### DMS

Migrate databases with minimal downtime.

### MGN

**Rehost / lift-and-shift** servers.

### DataSync

Transfer data between:

* On-premises
* AWS storage

### Storage Gateway

| Mode           | Purpose           |
| -------------- | ----------------- |
| File Gateway   | S3 file interface |
| Volume Gateway | Block storage     |
| Tape Gateway   | Virtual tapes     |

---

# 25. 📦 Snow Family

**Snowcone**
→ small/portable

**Snowball Edge**
→ large-scale data transfer + edge compute

**Snowmobile**
→ extremely large data migration

> **Huge amount of data + poor network connectivity → Snow Family**

---

# 26. 💰 Billing & Cost Management

### Cost Explorer

Analyze historical/current costs.

### AWS Budgets

Set:

* Cost budgets
* Usage budgets
* Alerts

### Cost & Usage Report

Detailed billing dataset.

### Pricing Calculator

Estimate future AWS costs.

### Cost Allocation Tags

Categorize costs by:

* Project
* Department
* Environment

### Consolidated Billing

AWS Organizations combines account billing.

---

# 27. 🏆 Trusted Advisor

Provides recommendations around:

* Cost optimization
* Performance
* Security
* Fault tolerance
* Service limits
* Operational excellence

Think:

> **"What can I improve in my AWS account?"**

---

# 28. 🆘 AWS Support

Know the progression:

**Basic**
→ account/billing help + documentation

**Developer**
→ development assistance

**Business**
→ production workload support

**Enterprise**
→ higher-level support / designated guidance

The deck also covers newer **Business Support+** and **Unified Operations** offerings.

> Exam questions generally test **which support level provides the required type of technical/account assistance**, rather than memorizing every price.

---

# 29. 🏗️ Well-Architected Framework

### Six Pillars

```text
O S R P C S

Operational Excellence
Security
Reliability
Performance Efficiency
Cost Optimization
Sustainability
```

### Key principles

**Operational Excellence**

* Operations as code
* Frequent/reversible changes
* Learn from failures
* Observability

**Security**

* Strong identity foundation
* Least privilege
* Traceability
* Security at every layer
* Encrypt data
* Prepare for security events

**Reliability**

* Automatically recover
* Test recovery
* Scale horizontally
* Stop guessing capacity
* Manage change

**Performance Efficiency**

* Use advanced technologies
* Go global
* Use serverless
* Experiment
* Monitor performance

**Cost Optimization**

* Pay only for what you need
* Right-size
* Use managed services
* Track expenditure
* Optimize over time

**Sustainability**

* Maximize utilization
* Use efficient hardware/software
* Managed services
* Lifecycle data
* Reduce downstream resource consumption

---

# 30. 💥 Disaster Recovery

### Backup & Restore

Lowest cost / slowest recovery.

```text
Backup → Disaster → Restore
```

### Pilot Light

Minimal core environment always running.

### Warm Standby

Scaled-down working environment ready to increase capacity.

### Multi-Site / Active-Active

Full environments running simultaneously.

### Remember

```text
Cost ↓                           Cost ↑
Recovery slower ←────────────→ Recovery faster

Backup → Pilot Light → Warm Standby → Active-Active
```

---

# 31. 🧩 AWS CAF

**Cloud Adoption Framework**

Six perspectives:

1. **Business**
2. **People**
3. **Governance**
4. **Platform**
5. **Security**
6. **Operations**

> CAF = **organizational/cloud transformation**
> Well-Architected = **workload architecture**

---

# 32. 🤖 AI / ML Services

| Requirement                 | Service         |
| --------------------------- | --------------- |
| Build/train ML models       | **SageMaker**   |
| Foundation models / GenAI   | **Bedrock**     |
| Image/video analysis        | **Rekognition** |
| Extract text from documents | **Textract**    |
| NLP/sentiment               | **Comprehend**  |
| Speech → text               | **Transcribe**  |
| Text → speech               | **Polly**       |
| Translation                 | **Translate**   |
| Chatbot/conversation        | **Lex**         |
| Enterprise search           | **Kendra**      |

### Memory

```text
See image       → Rekognition
Read document   → Textract
Understand text → Comprehend
Hear speech     → Transcribe
Speak           → Polly
Translate       → Translate
Chatbot         → Lex
GenAI/LLM       → Bedrock
Build ML        → SageMaker
Search          → Kendra
```

---

# 33. 🌱 Sustainability

Relevant services/concepts from the deck:

* EC2 Auto Scaling
* Lambda
* Fargate
* Graviton
* Spot Instances
* S3 Glacier
* S3 Intelligent-Tiering
* EFS-IA
* EBS Cold HDD
* Lifecycle policies
* Data Lifecycle Manager
* Customer Carbon Footprint Tool

Core idea:

> **Right-size + maximize utilization + use efficient/managed services + lifecycle inactive data**



---

# 34. 🧪 Specialized Services to Recognize

These are easier to miss but appear in the deck:

| Service                        | Recognition                         |
| ------------------------------ | ----------------------------------- |
| **FIS**                        | Fault injection / chaos engineering |
| **Ground Station**             | Satellite communications/data       |
| **Pinpoint**                   | Targeted marketing campaigns        |
| **QuickSight**                 | BI/visualization                    |
| **AppFlow**                    | SaaS ↔ AWS data integration         |
| **Data Exchange**              | Third-party datasets                |
| **Glue**                       | ETL/data integration                |
| **Lake Formation**             | Data lake management                |
| **OpenSearch**                 | Search/log analytics                |
| **Neptune**                    | Graph database                      |
| **DocumentDB**                 | MongoDB-compatible document DB      |
| **FSx**                        | Managed file systems                |
| **Backup**                     | Centralized backup                  |
| **Control Tower**              | Multi-account governance            |
| **Service Catalog**            | Approved IT products                |
| **Resource Groups/Tag Editor** | Organize resources                  |
| **Launch Wizard**              | Guided application deployment       |

---

# 35. 🔥 MOST IMPORTANT SERVICE COMPARISONS

| If question says...         | Think...                |
| --------------------------- | ----------------------- |
| Virtual server              | **EC2**                 |
| Serverless function         | **Lambda**              |
| Serverless container        | **Fargate**             |
| Kubernetes                  | **EKS**                 |
| Docker orchestration        | **ECS**                 |
| Object storage              | **S3**                  |
| Block storage               | **EBS**                 |
| Shared file storage         | **EFS**                 |
| Relational DB               | **RDS**                 |
| AWS relational DB           | **Aurora**              |
| NoSQL                       | **DynamoDB**            |
| DynamoDB cache              | **DAX**                 |
| Database cache              | **ElastiCache**         |
| Data warehouse              | **Redshift**            |
| SQL on S3                   | **Athena**              |
| Big data                    | **EMR**                 |
| Queue                       | **SQS**                 |
| Pub/sub                     | **SNS**                 |
| Streaming                   | **Kinesis**             |
| API                         | **API Gateway**         |
| DNS                         | **Route 53**            |
| CDN                         | **CloudFront**          |
| Global network acceleration | **Global Accelerator**  |
| Web attack                  | **WAF**                 |
| DDoS                        | **Shield**              |
| Threat detection            | **GuardDuty**           |
| Vulnerability               | **Inspector**           |
| Sensitive S3 data           | **Macie**               |
| Encryption keys             | **KMS**                 |
| TLS certificates            | **ACM**                 |
| Password/secrets            | **Secrets Manager**     |
| API auditing                | **CloudTrail**          |
| Metrics/logs/alarms         | **CloudWatch**          |
| Configuration compliance    | **Config**              |
| Distributed tracing         | **X-Ray**               |
| IaC                         | **CloudFormation**      |
| Multi-account               | **Organizations**       |
| Account permission ceiling  | **SCP**                 |
| Workforce SSO               | **IAM Identity Center** |
| App users                   | **Cognito**             |
| Database migration          | **DMS**                 |
| Server migration            | **MGN**                 |
| Online file transfer        | **DataSync**            |
| Offline huge data           | **Snowball/Snowmobile** |
| Hybrid storage              | **Storage Gateway**     |
| ML platform                 | **SageMaker**           |
| Foundation models           | **Bedrock**             |

---

# 36. ⚠️ FINAL EXAM TRAPS

### Storage

**S3 ≠ EBS ≠ EFS**

```text
S3  → Object
EBS → Block
EFS → File
```

### Database

```text
Multi-AZ     → HA
Read Replica → Read scaling
```

### Monitoring

```text
CloudWatch → What is happening?
CloudTrail  → Who did what?
Config      → Is configuration compliant?
X-Ray       → Where is request slow?
```

### Security

```text
WAF        → Web attacks
Shield     → DDoS
GuardDuty  → Threats
Inspector  → Vulnerabilities
Macie      → Sensitive S3 data
Security Hub → Central findings
```

### Identity

```text
IAM        → AWS identities/access
Cognito    → Application users
Identity Center → Workforce SSO
SCP        → Maximum account permissions
STS        → Temporary credentials
```

### Networking

```text
IGW → Internet
NAT → Private subnet outbound internet
VPC Endpoint → Private AWS service access
VPN → Encrypted internet connection
DX → Dedicated connection
Peering → VPC ↔ VPC
Transit Gateway → Many networks
```

### Application integration

```text
SQS       → Queue
SNS       → Fan-out
Kinesis   → Streaming
EventBridge → Events
Step Functions → Workflow
```

---

# 🚨 37. NUMBERS & FACTS WORTH MEMORIZING

| Fact                 | Remember                     |
| -------------------- | ---------------------------- |
| S3 durability        | **11 nines — 99.999999999%** |
| Lambda max execution | **15 minutes**               |
| SSH                  | **22**                       |
| HTTP                 | **80**                       |
| HTTPS                | **443**                      |
| RDP                  | **3389**                     |
| FTP                  | **21**                       |
| EC2 Reserved         | **1 or 3 years**             |
| Spot                 | **Interruptible**            |
| IAM                  | **Global service**           |
| VPC                  | **Regional**                 |
| Subnet               | **AZ-level**                 |
| S3                   | **Object storage**           |
| EBS                  | **Block storage**            |
| EFS                  | **File storage**             |

---

# 🧠 LAST-MINUTE MEMORY MAP

```text
                    AWS
                     │
       ┌─────────────┼─────────────┐
       │             │             │
    COMPUTE       STORAGE       DATABASE
       │             │             │
 EC2/Lambda       S3/EBS/EFS    RDS/Aurora
 ECS/EKS          FSx           DynamoDB
 Fargate                         Redshift
                                 Athena
       │             │             │
       └─────────────┼─────────────┘
                     │
                  NETWORK
                     │
          VPC / Route53 / CloudFront
          IGW / NAT / VPN / DX
                     │
                  SECURITY
                     │
       IAM / KMS / WAF / Shield
       GuardDuty / Inspector / Macie
                     │
                OPERATIONS
                     │
     CloudWatch / CloudTrail / Config
          X-Ray / Systems Manager
                     │
                  GOVERNANCE
                     │
    Organizations / SCP / Identity Center
                     │
                    COST
                     │
 Cost Explorer / Budgets / CUR / Calculator
                     │
                   AI/ML
                     │
 Bedrock / SageMaker / Rekognition / Textract
```

### ⭐ If you have only 30 minutes before the exam

Memorize these **five chains**:

**1. Storage:**
`S3 = Object | EBS = Block | EFS = File`

**2. Security:**
`IAM = Access | KMS = Encryption | WAF = Web | Shield = DDoS | GuardDuty = Threats | Inspector = Vulnerabilities`

**3. Monitoring:**
`CloudWatch = Metrics/Logs | CloudTrail = API Audit | Config = Configuration | X-Ray = Tracing`

**4. Networking:**
`Route53 = DNS | CloudFront = CDN | IGW = Internet | NAT = Private→Internet | VPN = Encrypted | DX = Dedicated`

**5. Integration:**
`SQS = Queue | SNS = Pub/Sub | Kinesis = Streaming | EventBridge = Events | Step Functions = Workflow`

This expanded version is much closer to the **full topic coverage of the uploaded deck**, while still keeping the depth appropriate for a 4-page CLF-C02 revision sheet. 
