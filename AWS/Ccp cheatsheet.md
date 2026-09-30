# AWS CLF-C02 — 2-Page Cheat Sheet

## PAGE 1 — CORE AWS + COMPUTE + STORAGE + DATABASES

### ☁️ Cloud Fundamentals

| Concept                | Remember                                      |
| ---------------------- | --------------------------------------------- |
| **CAPEX**              | Upfront hardware/infrastructure cost          |
| **OPEX**               | Pay-as-you-go operating expense               |
| **Elasticity**         | Automatically grow/shrink with demand         |
| **Scalability**        | Handle increasing workload                    |
| **Vertical scaling**   | Bigger instance                               |
| **Horizontal scaling** | More instances                                |
| **High Availability**  | Reduce downtime using redundant resources/AZs |
| **Fault Tolerance**    | Continue operating despite component failure  |
| **Economies of scale** | AWS benefits from massive infrastructure      |

**Cloud models:** Public / Private / Hybrid
**Service models:** IaaS → EC2 | PaaS → Elastic Beanstalk | SaaS → ready-to-use application

---

### 🌎 AWS Global Infrastructure

**Region** → geographic area
**Availability Zone (AZ)** → isolated datacenter(s) inside a Region
**Edge Location** → CloudFront content delivery
**Local Zones** → AWS infrastructure closer to users
**Wavelength** → AWS infrastructure for 5G networks
**Outposts** → AWS infrastructure in your own datacenter

> **Multi-AZ = high availability**
> **Multi-Region = geographic resilience / global reach**

---

### 🔐 IAM — Identity & Access

**IAM = authentication + authorization**

* **User** → person/application identity
* **Group** → collection of users
* **Role** → temporary permissions; assumed by users/services
* **Policy** → JSON permissions document
* **MFA** → additional authentication factor
* **Root user** → full account access; avoid daily use

**Policy structure:**

```text
Version
Statement
 ├─ Effect: Allow / Deny
 ├─ Action
 ├─ Resource
 ├─ Principal
 └─ Condition
```

### IAM Evaluation

```text
Explicit Deny
     ↓
   DENIED

No Allow
     ↓
Implicit Deny

Allow + No Explicit Deny
     ↓
  ALLOWED
```

**Remember:** Explicit Deny always wins.

**Best practices:** MFA, least privilege, temporary credentials/roles, avoid root access keys.

---

## 🖥️ Compute

### EC2

**EC2 = virtual server / IaaS**

Instance families:

* **General Purpose** → balanced CPU/memory
* **Compute Optimized** → CPU-intensive
* **Memory Optimized** → large datasets/in-memory workloads
* **Storage Optimized** → high local storage I/O
* **Accelerated Computing** → GPU/ML/HPC

**EC2 components:** AMI + Instance Type + EBS/Instance Store + Security Group + User Data

### EC2 Pricing

| Option                   | Use                            |
| ------------------------ | ------------------------------ |
| **On-Demand**            | Flexible, no commitment        |
| **Reserved Instances**   | 1/3-year commitment            |
| **Savings Plans**        | Commit to consistent usage     |
| **Spot**                 | Cheap, interruptible workloads |
| **Dedicated Host**       | Dedicated physical server      |
| **Capacity Reservation** | Reserve EC2 capacity           |

### Security Group

* Instance-level firewall
* **Stateful**
* Inbound traffic denied by default
* Outbound allowed by default

**Ports:**
`22 SSH` | `80 HTTP` | `443 HTTPS` | `3389 RDP`

---

## ⚖️ Load Balancing & Scaling

**ALB** → Layer 7 HTTP/HTTPS
**NLB** → Layer 4 TCP/UDP
**GWLB** → network/security appliances

**Auto Scaling Group**

```text
Minimum ← Desired → Maximum
```

Automatically:

* Adds instances → scale out
* Removes instances → scale in
* Replaces unhealthy instances
* Can distribute instances across AZs

---

# 🗄️ Storage

### S3

**Object storage**

```text
Bucket
 └── Object
      ├── Key
      ├── Data
      └── Metadata
```

**S3 durability:** **11 nines (99.999999999%)**

Storage classes:

* **Standard** → frequent access
* **Intelligent-Tiering** → unknown/changing access
* **Standard-IA** → infrequent access
* **One Zone-IA** → infrequent + single AZ
* **Glacier Instant Retrieval** → archive + fast retrieval
* **Glacier Flexible Retrieval** → archive
* **Glacier Deep Archive** → lowest-cost long-term archive

Important:

* Versioning → protect against accidental deletion
* Lifecycle → automatically transition/delete objects
* CRR → Cross-Region Replication
* SRR → Same-Region Replication
* Presigned URL → temporary object access
* Multipart upload → large objects
* Object Lock → WORM/retention

### Storage Comparison

| Service            | Think                |
| ------------------ | -------------------- |
| **S3**             | Object               |
| **EBS**            | Block disk for EC2   |
| **EFS**            | Shared file system   |
| **Instance Store** | Temporary local disk |

---

# 🛢️ Databases

| Requirement                                   | Service         |
| --------------------------------------------- | --------------- |
| Managed relational DB                         | **RDS**         |
| AWS high-performance relational DB            | **Aurora**      |
| NoSQL key-value/document                      | **DynamoDB**    |
| DynamoDB in-memory cache                      | **DAX**         |
| Managed Redis/Memcached                       | **ElastiCache** |
| Data warehouse                                | **Redshift**    |
| SQL directly on S3                            | **Athena**      |
| Big-data processing                           | **EMR**         |
| Graph DB                                      | **Neptune**     |
| Document DB compatible with MongoDB workloads | **DocumentDB**  |
| Search/log analytics                          | **OpenSearch**  |

### RDS

**Multi-AZ** → high availability/failover
**Read Replica** → read scaling

> **HA = Multi-AZ**
> **Read performance = Read Replica**

---

# PAGE 2 — NETWORKING + SECURITY + MONITORING + MANAGEMENT

## 🌐 VPC Networking

### Core

**VPC** → isolated virtual network
**Subnet** → network segment inside VPC
**Route Table** → determines traffic path
**Internet Gateway (IGW)** → internet connectivity
**NAT Gateway** → private subnet → outbound internet
**Security Group** → stateful instance firewall
**NACL** → stateless subnet firewall

### Public vs Private Subnet

**Public:**

```text
Route → Internet Gateway
```

**Private:**

```text
Route → NAT Gateway → Internet
```

> NAT allows **outbound** internet access; it doesn't make the private subnet public.

### Connectivity

| Requirement                         | Service          |
| ----------------------------------- | ---------------- |
| VPC → internet                      | Internet Gateway |
| Private subnet → internet           | NAT Gateway      |
| AWS service privately from VPC      | VPC Endpoint     |
| Connect VPCs                        | VPC Peering      |
| Many VPCs                           | Transit Gateway  |
| Encrypted network connection        | Site-to-Site VPN |
| Dedicated private connection to AWS | Direct Connect   |

**VPN = encrypted over internet**
**Direct Connect = dedicated private connection**

---

## 🌍 Route 53 / CloudFront

**Route 53 = DNS**

Routing policies:

* Simple
* Weighted
* Latency
* Failover
* Geolocation
* Geoproximity
* Multivalue

**CloudFront = CDN**

```text
User → Edge Location → Origin
```

Caches content closer to users.

**Global Accelerator**
→ improves global application performance using AWS global network/IPs.

---

# 🔒 AWS Security Services

| Service                 | Remember                                      |
| ----------------------- | --------------------------------------------- |
| **IAM**                 | Identity & permissions                        |
| **Organizations**       | Manage multiple AWS accounts                  |
| **SCP**                 | Maximum permissions boundary for accounts/OUs |
| **IAM Identity Center** | Workforce SSO                                 |
| **Cognito**             | Application users                             |
| **KMS**                 | Encryption keys                               |
| **CloudHSM**            | Dedicated hardware security module            |
| **Secrets Manager**     | Store/rotate secrets                          |
| **Parameter Store**     | Configuration/secrets                         |
| **WAF**                 | Web application attacks                       |
| **Shield**              | DDoS protection                               |
| **GuardDuty**           | Threat detection                              |
| **Inspector**           | Vulnerability management                      |
| **Macie**               | Sensitive data discovery in S3                |
| **Security Hub**        | Central security findings                     |
| **Artifact**            | AWS compliance documents                      |

### Don't Confuse

```text
WAF       → Web attacks
Shield    → DDoS

GuardDuty → Threat detection
Inspector → Vulnerability scanning

KMS       → Encryption keys
Secrets Manager → Secrets/passwords

IAM       → AWS resource access
Cognito   → Application users
```

---

# 📊 Monitoring & Auditing

### CloudWatch

**Metrics + Logs + Alarms + Monitoring**

Think:

> **"How is my AWS workload performing?"**

### CloudTrail

**API activity / account auditing**

Think:

> **"Who did what in AWS?"**

### AWS Config

Tracks:

> **"Is my resource configured correctly/compliantly?"**

### X-Ray

Application tracing/debugging.

### Health Dashboard

AWS service/account health events.

**Easy memory:**

```text
CloudWatch → Performance
CloudTrail  → API history
Config      → Configuration
X-Ray       → Application tracing
```

---

# 📨 Application Integration

| Service         | Purpose                             |
| --------------- | ----------------------------------- |
| **SQS**         | Queue / decouple applications       |
| **SNS**         | Pub/Sub notifications               |
| **Kinesis**     | Real-time streaming                 |
| **Amazon MQ**   | Managed traditional message brokers |
| **API Gateway** | Create/manage APIs                  |
| **Lambda**      | Serverless code                     |

### SQS vs SNS

```text
SQS:
Producer → Queue → Consumer

SNS:
             → Subscriber 1
Publisher → SNS
             → Subscriber 2
```

**SQS = queue**
**SNS = fan-out/pub-sub**

---

# ⚡ Serverless & Containers

**Lambda**

* Serverless functions
* Event-driven
* No server management
* Maximum execution time: **15 minutes**

**ECS** → AWS container orchestration
**EKS** → managed Kubernetes
**Fargate** → serverless compute for containers
**ECR** → container image registry

**Elastic Beanstalk**
→ deploy applications while AWS manages underlying infrastructure.

---

# 💰 Billing & Cost

| Service                       | Purpose               |
| ----------------------------- | --------------------- |
| **Cost Explorer**             | Analyze spending      |
| **AWS Budgets**               | Set budgets/alerts    |
| **Cost & Usage Report (CUR)** | Detailed billing data |
| **Pricing Calculator**        | Estimate costs        |
| **Cost Allocation Tags**      | Categorize costs      |
| **Consolidated Billing**      | Organizations billing |

### Cost mindset

```text
Unknown cost → Pricing Calculator
Current spending analysis → Cost Explorer
Budget threshold → Budgets
Detailed billing data → CUR
Multiple accounts → Organizations
```

---

# 🏗️ Well-Architected Framework

### 6 Pillars

**O S R P C S**

1. **Operational Excellence**
2. **Security**
3. **Reliability**
4. **Performance Efficiency**
5. **Cost Optimization**
6. **Sustainability**

### Design Principles

* Stop guessing capacity
* Test at production scale
* Automate
* Design for failure
* Use managed services
* Decouple systems
* Implement elasticity
* Monitor everything

---

# 🚚 Migration

| Requirement                 | Service                           |
| --------------------------- | --------------------------------- |
| Database migration          | **DMS**                           |
| Move files/online data      | **DataSync**                      |
| Hybrid storage              | **Storage Gateway**               |
| Large offline data transfer | **Snow Family**                   |
| Migrate servers/apps        | **Application Migration Service** |

### Snow Family

**Snowcone** → small
**Snowball Edge** → large data transfer/compute
**Snowmobile** → massive data transfer

---

# 🤖 AI/ML — CLF-C02 Recognition

| Requirement                       | Service         |
| --------------------------------- | --------------- |
| Build/train ML models             | **SageMaker**   |
| Generative AI / foundation models | **Bedrock**     |
| Images/video analysis             | **Rekognition** |
| Extract text from documents       | **Textract**    |
| NLP/sentiment                     | **Comprehend**  |
| Speech → text                     | **Transcribe**  |
| Text → speech                     | **Polly**       |
| Language translation              | **Translate**   |
| Conversational chatbot            | **Lex**         |
| Enterprise search                 | **Kendra**      |

---

# 🧠 FINAL EXAM MEMORY MAP

```text
IDENTITY
IAM → Users / Groups / Roles / Policies

COMPUTE
EC2 → VM
Lambda → Function
ECS/EKS → Containers
Fargate → Serverless containers

STORAGE
S3 → Object
EBS → Block
EFS → File

DATABASE
RDS/Aurora → Relational
DynamoDB → NoSQL
Redshift → Warehouse
Athena → SQL on S3

NETWORK
VPC → Network
Route 53 → DNS
CloudFront → CDN
IGW → Internet
NAT → Private → Internet
Direct Connect → Dedicated connection

SECURITY
WAF → Web attacks
Shield → DDoS
GuardDuty → Threat detection
Inspector → Vulnerabilities
KMS → Encryption keys

MONITORING
CloudWatch → Metrics/logs/alarms
CloudTrail → API auditing
Config → Configuration compliance
X-Ray → Tracing

INTEGRATION
SQS → Queue
SNS → Pub/Sub
Kinesis → Streaming
API Gateway → APIs

MANAGEMENT
CloudFormation → IaC
Systems Manager → Manage instances
Organizations → Multiple accounts
Trusted Advisor → Recommendations
```

### 🔥 15 Exam Traps to Memorize

1. **Explicit Deny > Allow**
2. **IAM Role ≠ IAM User**
3. **Multi-AZ = HA/failover**
4. **Read Replica = read scaling**
5. **S3 = object, EBS = block, EFS = file**
6. **CloudWatch ≠ CloudTrail**
7. **WAF ≠ Shield**
8. **GuardDuty ≠ Inspector**
9. **SQS ≠ SNS**
10. **NAT Gateway = outbound internet for private subnet**
11. **Route 53 = DNS**
12. **CloudFront = CDN**
13. **Direct Connect = dedicated network connection**
14. **Spot = cheapest but interruptible**
15. **Bedrock = foundation models / GenAI; SageMaker = ML platform**

**Exam rule:** When you see a scenario, identify the **specific requirement** first, then map it to the AWS service. The uploaded material emphasizes recognizing AWS services from their use cases. 
