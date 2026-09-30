Absolutely. I reviewed the uploaded **509-page CLF-C02 course slide deck** and condensed it into an exam-oriented cheat sheet. The deck covers the full progression from cloud fundamentals and IAM through EC2, storage, databases, networking, security, monitoring, billing, architecture, and exam preparation. 

# AWS Certified Cloud Practitioner — CLF-C02 Comprehensive Cheat Sheet

> **How to use this:** Prioritize the **bold service → use-case mappings**, comparison tables, and **Exam Traps**. For CLF-C02, recognizing *which AWS service solves a scenario* is usually more important than knowing implementation details.

---

# 1. AWS CLOUD FUNDAMENTALS

## Cloud Computing

**Cloud computing = on-demand delivery of IT resources over the internet with pay-as-you-go pricing.**

AWS manages the underlying physical infrastructure; you provision and use resources.

### Traditional IT problems

* Data-center cost
* Hardware maintenance
* Power/cooling
* Capacity planning
* Slow provisioning
* Limited scalability
* Disaster recovery complexity
* 24/7 infrastructure management

### Cloud advantages

| Concept                    | Meaning                                           |
| -------------------------- | ------------------------------------------------- |
| **CAPEX → OPEX**           | Avoid large upfront hardware investment           |
| **Pay-as-you-go**          | Pay for resources consumed                        |
| **Economies of scale**     | AWS can achieve lower costs through massive scale |
| **Stop guessing capacity** | Scale according to demand                         |
| **Agility**                | Provision resources quickly                       |
| **Global reach**           | Deploy around the world                           |
| **Elasticity**             | Automatically scale resources up/down             |
| **High availability**      | Use multiple AZs/Regions                          |

### Scalability vs Elasticity

**Scalability**

* Ability to handle increasing workload.

**Vertical scaling**

* Bigger machine.
* Example: `t3.medium → t3.2xlarge`

**Horizontal scaling**

* More machines.
* Example: `2 EC2 → 10 EC2`

**Elasticity**

* Automatically scale **out/in** according to demand.

---

# 2. CLOUD DEPLOYMENT MODELS

### Public Cloud

AWS owns/manages infrastructure.

### Private Cloud

Cloud infrastructure dedicated to one organization.

### Hybrid Cloud

Combination of on-premises/private infrastructure + public cloud.

**Exam clue:**

> "Some workloads must remain on-premises while others move to AWS"

→ **Hybrid Cloud**

---

# 3. CLOUD SERVICE MODELS

| Model    | You manage                 | AWS manages               | Example            |
| -------- | -------------------------- | ------------------------- | ------------------ |
| **IaaS** | OS, apps, configuration    | Hardware/infrastructure   | EC2                |
| **PaaS** | Application/code           | Infrastructure + platform | Elastic Beanstalk  |
| **SaaS** | Mostly usage/configuration | Almost everything         | Amazon Rekognition |

### Easy memory

**IaaS = Infrastructure**

**PaaS = Platform**

**SaaS = Software**

---

# 4. AWS GLOBAL INFRASTRUCTURE

## Region

A geographic area containing multiple Availability Zones.

Examples:

* `us-east-1`
* `eu-west-1`
* `ap-southeast-1`

Most AWS services are **Region-scoped**. 

### Choosing a Region

Consider:

1. **Compliance/legal requirements**
2. **Latency to customers**
3. **Available AWS services**
4. **Pricing**

---

## Availability Zone — AZ

An AZ consists of one or more discrete data centers.

AZs within a Region are:

* Physically separated
* Independently powered
* Connected with high-bandwidth, low-latency networking
* Designed for fault isolation

### Exam pattern

> "Protect an application from failure of a single data center/AZ"

→ Deploy across **multiple AZs**

---

## Edge Locations

Used primarily by services such as **CloudFront** to place content closer to users.

### Think:

```text
Region
  ↓
Availability Zones
  ↓
Data Centers

Users
  ↓
Edge Location
  ↓
CloudFront
  ↓
Origin
```

---

# 5. SHARED RESPONSIBILITY MODEL

### AWS responsibility

**Security OF the cloud**

AWS manages:

* Physical data centers
* Physical hardware
* Networking infrastructure
* Hardware replacement
* Infrastructure security
* Managed-service underlying infrastructure

### Customer responsibility

**Security IN the cloud**

Depending on service:

* Data
* IAM permissions
* Passwords
* MFA
* OS patches
* Security groups
* Network configuration
* Application security
* Encryption configuration

### Key exam distinction

For **EC2**:

AWS:

* Physical host
* Physical network
* Hypervisor

Customer:

* OS
* Patches
* Applications
* Security groups
* IAM
* Data

For a **managed service**, AWS takes more responsibility.

---

# 6. IAM — IDENTITY AND ACCESS MANAGEMENT

IAM is a **global service**. 

## IAM components

### User

Represents an individual/person or application identity.

### Group

Collection of IAM users.

**Groups can contain users only.**

A user can belong to multiple groups.

### Policy

JSON document defining permissions.

### Role

An identity that can be assumed by:

* AWS services
* Applications
* Users
* Other AWS accounts

---

# 7. IAM POLICY STRUCTURE

Typical policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::bucket/*"
    }
  ]
}
```

### Memorize

```text
Policy
 ├── Version
 ├── Statement
 │    ├── Sid
 │    ├── Effect
 │    ├── Principal
 │    ├── Action
 │    ├── Resource
 │    └── Condition
```

`Sid` and `Condition` are optional.

`Statement` is required. 

---

# 8. IAM POLICY EVALUATION

This is especially important.

### Basic rule

**Explicit Deny overrides Allow.**

If multiple policies grant access:

```text
Allow + Allow = Allow
Allow + Deny  = Deny
No Allow      = Implicit Deny
```

### Example

User belongs to:

```text
Developers
   ↓
Allow S3:GetObject

Operations
   ↓
Allow S3:PutObject
```

Effective permissions include both.

If another applicable policy says:

```text
Deny S3:GetObject
```

then:

```text
Explicit Deny
      ↓
     WINS
```

---

# 9. IAM SECURITY

### Root account

Avoid daily usage.

Use root only when specifically required.

### MFA

**Something you know + something you have.**

Examples:

* Password + authenticator
* Password + security key

Enable MFA particularly for root.

### Access keys

Used for:

* AWS CLI
* AWS SDK

Think:

```text
Access Key ID     ≈ username
Secret Access Key ≈ password
```

Never expose them.

### IAM best practices

* Least privilege
* Don't use root regularly
* One physical user → one IAM user where IAM users are appropriate
* Use groups
* Enable MFA
* Use roles for AWS services
* Rotate credentials
* Audit permissions

---

# 10. IAM TOOLS

| Tool                       | Purpose                                                        |
| -------------------------- | -------------------------------------------------------------- |
| **IAM Credentials Report** | Account-level report of users/credentials                      |
| **IAM Access Advisor**     | Shows services a user can access and last-accessed information |
| **IAM Policy**             | Defines permissions                                            |
| **IAM Role**               | Temporary/assumed permissions                                  |

---

# 11. CLI vs SDK

### AWS Management Console

Browser GUI.

### AWS CLI

Command-line interface.

```bash
aws s3 ls
```

### AWS SDK

Libraries used inside applications.

Examples:

* Python
* Java
* JavaScript
* .NET
* Go
* C++

### Exam clue

> "Application needs to call AWS programmatically"

→ **AWS SDK**

> "Developer wants command-line access"

→ **AWS CLI**

---

# 12. EC2

**EC2 = Elastic Compute Cloud**

Primarily **IaaS**.

EC2 provides virtual machines.

An EC2 instance involves:

```text
AMI
 +
Instance Type
 +
Storage
 +
Security Group
 +
User Data
```

---

# 13. EC2 INSTANCE TYPES

### General Purpose — `T`, `M`

Balanced:

* CPU
* Memory
* Networking

Use cases:

* Web servers
* Application servers
* Development

### Compute Optimized — `C`

High CPU.

Use cases:

* Batch processing
* HPC
* Scientific computing
* Media transcoding
* CPU-intensive applications

### Memory Optimized — `R`, `X`, etc.

Large RAM.

Use cases:

* In-memory databases
* Large caches
* Big-data processing

### Storage Optimized — `I`, `D`, etc.

High local storage I/O.

Use cases:

* NoSQL databases
* Data warehousing
* High-frequency workloads
* Distributed file systems

### Accelerated Computing

GPU / specialized hardware.

Use cases:

* ML
* Graphics
* Video processing

---

# 14. EC2 INSTANCE NAMING

Example:

```text
m5.2xlarge
│ │ │
│ │ └── size
│ └──── generation
└────── instance family
```

---

# 15. EC2 USER DATA

Used for **bootstrapping** an instance.

Runs commands when the instance starts initially.

Examples:

* Install packages
* Install software
* Download files
* Configure server

**Exam clue:**

> "Automatically configure an EC2 instance when it launches"

→ **EC2 User Data**

---

# 16. SECURITY GROUPS

Security Groups = virtual firewall for EC2.

Control:

* Inbound traffic
* Outbound traffic
* Ports
* IP ranges
* Other security groups

### Important

Default:

```text
Inbound → DENY
Outbound → ALLOW
```

Security groups are **stateful**.

They operate at the instance level.

---

# 17. IMPORTANT PORTS

|     Port | Protocol |
| -------: | -------- |
|   **22** | SSH      |
|   **21** | FTP      |
|   **22** | SFTP     |
|   **80** | HTTP     |
|  **443** | HTTPS    |
| **3389** | RDP      |

Memorize these.

---

# 18. EC2 PRICING OPTIONS

## On-Demand

* No commitment
* Highest flexibility
* No long-term commitment
* Short/unpredictable workloads

**Think:** pay normally whenever you need it.

---

## Reserved Instances

For predictable long-term workloads.

Typical terms:

* 1 year
* 3 years

Good for:

> steady-state database/application

---

## Convertible Reserved Instance

Allows more flexibility to change attributes.

---

## Savings Plans

Commit to a certain amount of usage for 1 or 3 years.

More flexible than traditional RIs in some dimensions.

---

## Spot Instances

Very cheap.

Can be interrupted.

Best for:

* Batch jobs
* Data processing
* Image processing
* Distributed workloads
* Fault-tolerant workloads

**NOT suitable for critical workloads that cannot tolerate interruption.**

---

## Dedicated Hosts

Entire physical server dedicated to you.

Use when:

* Compliance requires dedicated hardware
* BYOL licensing requirements

Very expensive.

---

## Dedicated Instances

Instances run on hardware dedicated to your account, but you don't control physical placement.

---

## Capacity Reservations

Reserve EC2 capacity in a specific AZ.

Important:

**Capacity reservation ≠ discount.**

You pay On-Demand rates.

---

# 19. EC2 STORAGE

## EBS — Elastic Block Store

Think:

> **Network-attached virtual disk**

Characteristics:

* Persistent
* Attached to EC2
* AZ-scoped
* Can survive EC2 termination depending on configuration
* Provisioned capacity

```text
EC2
 │
 └── EBS
```

An EBS volume in `us-east-1a` cannot directly attach to an EC2 instance in `us-east-1b`.

---

# 20. EBS SNAPSHOTS

Snapshot = point-in-time backup of EBS.

Can be:

* Copied across AZs
* Copied across Regions
* Used to create new EBS volumes

### Snapshot Archive

Cheaper archival tier.

### Recycle Bin

Allows recovery of accidentally deleted snapshots according to retention rules.

---

# 21. AMI

**AMI = Amazon Machine Image**

Contains customized machine configuration.

Can include:

* OS
* Applications
* Configuration
* Monitoring software

Benefits:

* Faster instance launches
* Consistent deployments

AMI is Region-specific but can be copied to another Region.

---

# 22. EC2 INSTANCE STORE

Instance Store = physically attached local storage.

### Advantages

* Very high performance
* Low latency

### Major disadvantage

**Ephemeral**

Data is lost when the instance is stopped/terminated according to the instance-store lifecycle.

### Exam clue

> "Very high-speed temporary storage"

→ **Instance Store**

> "Persistent block storage"

→ **EBS**

---

# 23. EFS

**Elastic File System**

Managed shared file system.

Can be mounted by multiple EC2 instances.

Think:

```text
EC2 ─┐
EC2 ─┼── EFS
EC2 ─┘
```

Useful when many Linux instances need shared file storage.

---

# 24. ELASTIC LOAD BALANCING

ELB distributes incoming traffic.

### ALB — Application Load Balancer

Layer 7.

Best for:

* HTTP
* HTTPS
* Path-based routing
* Host-based routing

### NLB — Network Load Balancer

Layer 4.

Best for:

* TCP
* UDP
* Very high performance
* Low latency

### GWLB — Gateway Load Balancer

For network/security appliances.

---

# 25. AUTO SCALING GROUP — ASG

Automatically adjusts EC2 capacity.

```text
High demand
   ↓
Scale OUT
   ↓
More EC2

Low demand
   ↓
Scale IN
   ↓
Fewer EC2
```

Can:

* Maintain minimum capacity
* Maintain desired capacity
* Maintain maximum capacity
* Replace unhealthy instances
* Work across AZs
* Integrate with ELB

---

# 26. S3

**Amazon S3 = Simple Storage Service**

Object storage.

```text
Bucket
 ├── object
 ├── object
 └── object
```

### Key concepts

* Bucket
* Object
* Object key
* Metadata
* Version ID

Bucket names are globally unique.

---

# 27. S3 STORAGE CLASSES

| Class                          | Use                                          |
| ------------------------------ | -------------------------------------------- |
| **S3 Standard**                | Frequently accessed data                     |
| **S3 Intelligent-Tiering**     | Unknown/changing access patterns             |
| **S3 Standard-IA**             | Infrequently accessed but needs rapid access |
| **S3 One Zone-IA**             | Infrequent, re-creatable data                |
| **Glacier Instant Retrieval**  | Archive but millisecond retrieval            |
| **Glacier Flexible Retrieval** | Archive with minutes/hours retrieval         |
| **Glacier Deep Archive**       | Long-term archival                           |

### Memory trick

```text
Frequently accessed
       ↓
Standard

Unknown access pattern
       ↓
Intelligent-Tiering

Rare but fast
       ↓
Standard-IA

Rare + single AZ acceptable
       ↓
One Zone-IA

Archive
       ↓
Glacier
```

---

# 28. S3 DURABILITY vs AVAILABILITY

**Durability ≠ Availability**

Durability:

> Probability data will not be lost.

S3 is designed for extremely high durability: **11 nines**.

Availability:

> How often the service/data is accessible.

Different storage classes have different availability characteristics. 

---

# 29. S3 VERSIONING

Enabled at bucket level.

Protects against:

* Accidental deletion
* Accidental overwrite

Allows:

* Restore old versions
* Rollback

Important:

**Suspending versioning does not delete previous versions.**

---

# 30. S3 REPLICATION

### CRR

**Cross-Region Replication**

```text
Region A
   ↓
Region B
```

Use cases:

* Disaster recovery
* Compliance
* Lower-latency access
* Cross-account replication

### SRR

**Same-Region Replication**

Use cases:

* Log aggregation
* Replication between environments

Versioning must be enabled appropriately on source/destination.

---

# 31. S3 LIFECYCLE

Automate object movement/deletion.

Example:

```text
S3 Standard
    ↓ 30 days
Standard-IA
    ↓ 90 days
Glacier
    ↓
Delete
```

Good for:

* Cost optimization
* Automatic archival
* Data retention

---

# 32. S3 IMPORTANT FEATURES

### Encryption

Data can be encrypted at rest.

### Presigned URLs

Provide temporary access to private S3 objects.

### Multipart Upload

Recommended for large uploads.

### S3 Transfer Acceleration

Accelerates transfers over long geographic distances.

### Static Website Hosting

S3 can host static websites.

### Object Lock

Helps prevent object deletion/modification for a retention period.

---

# 33. EBS vs EFS vs S3

|                 | EBS              | EFS          | S3                 |
| --------------- | ---------------- | ------------ | ------------------ |
| Type            | Block            | File         | Object             |
| Attached to EC2 | Yes              | Mounted      | No                 |
| Shared          | Limited          | Yes          | Yes                |
| Persistent      | Yes              | Yes          | Yes                |
| AZ relationship | AZ-specific      | Regional     | Regional           |
| Typical use     | OS/database disk | Shared files | Objects/files/data |

### Exam shortcut

**EC2 disk → EBS**

**Shared Linux file system → EFS**

**Object storage → S3**

---

# 34. DATABASES

## RDS

Managed relational database service.

Supports engines such as:

* MySQL
* PostgreSQL
* MariaDB
* Oracle
* SQL Server

AWS manages:

* Infrastructure
* Backups
* Patching
* Some maintenance
* Automated failover options

You still manage database configuration/data/schema.

---

# 35. RDS MULTI-AZ

Designed primarily for **high availability/failover**.

```text
Primary
  ↓ synchronous replication
Standby
```

If primary fails:

→ standby can become primary.

### Exam trap

**Multi-AZ ≠ read scaling**

For read scaling:

→ **Read Replicas**

---

# 36. RDS READ REPLICAS

Used to scale read workloads.

```text
Application
    │
 ┌──┴────┐
 ↓       ↓
Primary  Read Replica
write      read
```

Can be cross-Region.

### Remember

**Multi-AZ = HA**

**Read Replica = read scaling**

---

# 37. AURORA

AWS-managed relational database.

Compatible with:

* MySQL
* PostgreSQL

Designed for higher performance/availability than standard RDS engines in many scenarios.

Important concepts:

* Aurora Cluster
* Aurora Replicas
* Aurora Global Database
* Serverless options

---

# 38. DYNAMODB

Fully managed **NoSQL key-value/document database**.

Characteristics:

* Serverless
* Highly scalable
* Low latency
* No traditional server management

### Good for

* High-scale applications
* Key-value workloads
* Serverless applications
* Gaming
* IoT
* Mobile applications

---

# 39. DAX

**DynamoDB Accelerator**

In-memory cache specifically for DynamoDB.

```text
Application
    ↓
   DAX
    ↓
DynamoDB
```

### DAX vs ElastiCache

**DAX**
→ specifically DynamoDB

**ElastiCache**
→ general-purpose caching for applications/databases

The uploaded material explicitly highlights this distinction.

---

# 40. ELASTICACHE

Managed in-memory caching.

Engines:

* Redis
* Memcached

Use for:

* Session storage
* Frequently accessed data
* Reducing database load
* Low-latency reads

---

# 41. REDSHIFT

**Data warehouse / OLAP**

Designed for analytics over large datasets.

```text
OLTP
↓
RDS / Aurora / DynamoDB

OLAP
↓
Redshift
```

Redshift uses columnar storage and massively parallel processing.

---

# 42. ATHENA

**Serverless SQL query service for data stored in S3.**

```text
S3
 ↓
Athena
 ↓
SQL
```

Excellent exam clue:

> "Analyze/query files stored in S3 using SQL without managing servers."

→ **Amazon Athena**

---

# 43. EMR

**Elastic MapReduce**

Used for big-data processing.

Technologies include:

* Hadoop
* Spark
* HBase
* Presto
* Flink

Think:

> Large-scale distributed big-data processing

---

# 44. DATABASE QUICK MAP

```text
Relational DB
    ↓
RDS / Aurora

NoSQL
    ↓
DynamoDB

Cache
    ↓
ElastiCache

DynamoDB cache
    ↓
DAX

Data warehouse
    ↓
Redshift

SQL directly on S3
    ↓
Athena

Big Data processing
    ↓
EMR

Graph database
    ↓
Neptune

Document database
    ↓
DocumentDB

Search / analytics
    ↓
OpenSearch Service
```

---

# 45. SERVERLESS COMPUTE

## Lambda

**Function as a Service**

You provide code.

AWS manages servers.

Characteristics:

* Event-driven
* Automatically scales
* Pay based on usage
* Maximum execution time is limited
* Good for APIs, automation, event processing

Examples:

```text
S3 upload
   ↓
Lambda
   ↓
Process image
```

```text
API Gateway
   ↓
Lambda
   ↓
Application logic
```

---

# 46. CONTAINERS

### Docker

Container technology.

### ECS

AWS container orchestration service.

### EKS

Managed Kubernetes.

### Fargate

Serverless compute engine for containers.

```text
ECS/EKS
   ↓
Fargate
   ↓
Containers
```

### ECR

Private container image registry.

---

# 47. ECS vs EKS vs FARGATE

| Service     | Purpose                           |
| ----------- | --------------------------------- |
| **ECS**     | AWS container orchestration       |
| **EKS**     | Managed Kubernetes                |
| **Fargate** | Serverless compute for containers |
| **ECR**     | Container image repository        |

### Exam clue

> "Run containers without managing EC2 servers"

→ **Fargate**

---

# 48. ELASTIC BEANSTALK

**PaaS**

Developer uploads application.

Beanstalk manages much of:

* EC2
* Auto Scaling
* Load Balancing
* Capacity provisioning
* Health monitoring

You still have considerable control over the underlying environment.

---

# 49. LIGHTSAIL

Simplified AWS environment for:

* Simple websites
* WordPress
* Small applications
* Dev/test

Predictable/simple pricing.

Think:

> "AWS for beginners/simple applications"

→ **Lightsail**

---

# 50. AWS BATCH

Managed batch processing.

Good for:

* Batch jobs
* Large compute jobs
* Flexible workloads

### Batch vs Lambda

**Lambda**

* Serverless
* Event driven
* Time-limited execution

**Batch**

* Long-running batch workloads
* Docker
* EC2-based infrastructure managed by AWS

---

# 51. API GATEWAY

Managed API service.

Can expose:

* Lambda
* HTTP services
* AWS services

Typical:

```text
Client
  ↓
API Gateway
  ↓
Lambda
  ↓
DynamoDB
```

---

# 52. APPLICATION INTEGRATION

## SQS

**Queue**

Decouples applications.

```text
Producer
   ↓
 SQS
   ↓
Consumer
```

Characteristics:

* Asynchronous
* Messages retained
* Multiple producers/consumers
* Helps absorb traffic spikes

### FIFO

**First In First Out**

Maintains message ordering.

---

# 53. SNS

**Simple Notification Service**

Pub/Sub.

```text
             → Email
             → Lambda
Publisher → SNS
             → SQS
             → HTTP
```

One message can go to many subscribers.

### Memory

**SQS = queue**

**SNS = notification/pub-sub**

---

# 54. KINESIS

For **real-time streaming data**.

Think:

* Logs
* IoT
* Clickstreams
* Metrics
* Real-time analytics

### Kinesis Data Streams

Real-time data streaming.

### Firehose

Deliver streaming data to destinations such as:

* S3
* Redshift
* OpenSearch

---

# 55. AMAZON MQ

Managed message broker.

Useful when migrating applications that already use traditional messaging protocols such as:

* ActiveMQ
* RabbitMQ

### Exam clue

> "Existing application uses traditional messaging protocols; minimize application changes."

→ **Amazon MQ**

---

# 56. CLOUDFORMATION

Infrastructure as Code.

Instead of manually creating:

```text
EC2
S3
VPC
ELB
IAM
...
```

define infrastructure in a template.

CloudFormation creates it.

### Key term

**Declarative**

You describe **what you want**, rather than manually specifying every creation step.

---

# 57. AWS CDK

Define AWS infrastructure using programming languages:

* TypeScript
* JavaScript
* Python
* Java
* .NET

CDK synthesizes infrastructure into CloudFormation templates.

### Memory

```text
CDK
 ↓
CloudFormation
 ↓
AWS Resources
```

---

# 58. AWS SYSTEMS MANAGER

Helps manage infrastructure.

Important capabilities:

* Parameter Store
* Run Command
* Patch management
* Session Manager
* Automation

### Session Manager

Connect to EC2 without needing traditional SSH in supported configurations.

---

# 59. AWS AUTO SCALING

Automatically adjusts capacity.

Scaling types:

### Dynamic scaling

Responds to current demand.

### Target tracking

Example:

> Maintain average CPU around 40%.

### Scheduled scaling

Known predictable traffic.

Example:

> Increase capacity every weekday at 8 AM.

### Predictive scaling

Uses ML to predict demand.

---

# 60. MONITORING

## CloudWatch

Think:

> **Metrics + Logs + Alarms + Events**

### CloudWatch Metrics

Examples:

* CPU
* Network
* Request counts
* Billing metrics

### CloudWatch Logs

Collect application/system logs.

### CloudWatch Alarms

Trigger actions based on metrics.

Example:

```text
CPU > 80%
   ↓
CloudWatch Alarm
   ↓
SNS / Auto Scaling action
```

---

# 61. CLOUDTRAIL

Think:

> **Who did what?**

Records AWS API activity.

Example:

> Who deleted an S3 bucket?

→ **CloudTrail**

### CloudWatch vs CloudTrail

|              | CloudWatch          | CloudTrail   |
| ------------ | ------------------- | ------------ |
| Main purpose | Monitoring          | Auditing     |
| Metrics      | Yes                 | No           |
| Logs         | Yes                 | API activity |
| API calls    | Not primary purpose | Yes          |

### Memory

**CloudWatch = How is AWS/application performing?**

**CloudTrail = Who made the API call?**

---

# 62. AWS CONFIG

Records/evaluates resource configurations.

Useful for:

* Compliance
* Configuration history
* Detecting configuration changes

### Example

> Find EC2 instances without required security configuration.

→ **AWS Config**

---

# 63. X-RAY

Distributed tracing.

Useful for:

* Microservices
* Finding bottlenecks
* Request tracing
* Identifying errors
* Understanding dependencies

---

# 64. AWS HEALTH DASHBOARD

### Service Health Dashboard

General AWS service status.

### Account Health Dashboard

Events specifically affecting your AWS account/resources.

---

# 65. VPC

**Virtual Private Cloud**

Your logical private network in AWS.

Regional resource.

---

# 66. SUBNETS

Subnets live within an AZ.

### Public subnet

Has route to the Internet Gateway.

### Private subnet

No direct route from the internet.

Typical:

```text
Internet
   ↓
Internet Gateway
   ↓
Public Subnet
   ↓
Load Balancer
   ↓
Private Subnet
   ↓
EC2 / RDS
```

---

# 67. INTERNET GATEWAY

Allows VPC resources in public subnets to communicate with the internet.

---

# 68. NAT GATEWAY

Allows resources in **private subnets** to initiate outbound internet access.

Important:

```text
Private EC2
    ↓
NAT Gateway
    ↓
Internet
```

Internet cannot initiate a connection back to the private EC2 through NAT Gateway.

---

# 69. SECURITY GROUP vs NACL

|                | Security Group        | NACL                       |
| -------------- | --------------------- | -------------------------- |
| Level          | Instance/ENI          | Subnet                     |
| Stateful       | **Yes**               | **No**                     |
| Rules          | Allow                 | Allow + Deny               |
| Return traffic | Automatically allowed | Must be explicitly handled |
| Main use       | Instance firewall     | Subnet-level firewall      |

### Exam clue

> "Explicit DENY rule"

→ **Network ACL**

Security Groups do not have explicit deny rules.

---

# 70. VPC FLOW LOGS

Capture information about IP traffic.

Useful for troubleshooting/security analysis.

Can send flow logs to services such as:

* CloudWatch Logs
* S3

---

# 71. VPC ENDPOINTS

Private connectivity to AWS services without requiring internet/NAT in many scenarios.

Example:

```text
Private EC2
   ↓
VPC Endpoint
   ↓
S3
```

---

# 72. VPC PEERING

Connect two VPCs privately.

```text
VPC A
  ↕
Peering
  ↕
VPC B
```

---

# 73. TRANSIT GATEWAY

Central networking hub for connecting:

* Multiple VPCs
* On-premises networks

Think:

> "Many VPCs need centralized connectivity."

→ **Transit Gateway**

---

# 74. VPN vs DIRECT CONNECT

### Site-to-Site VPN

Encrypted connection over the internet.

Usually:

* Faster to establish
* Lower initial cost
* Uses internet

### Direct Connect

Dedicated private connection from on-premises to AWS.

Benefits:

* More consistent network performance
* Private connectivity
* Useful for large-scale hybrid environments

### Memory

**VPN = encrypted internet**

**Direct Connect = dedicated connection**

---

# 75. ROUTE 53

Managed DNS service.

DNS translates:

```text
www.example.com
       ↓
IP address/resource
```

### Common records

* A → IPv4
* AAAA → IPv6
* CNAME → hostname → hostname
* Alias → AWS resource

---

# 76. ROUTE 53 ROUTING POLICIES

Know the concepts:

* Simple
* Weighted
* Latency-based
* Failover
* Geolocation
* Geoproximity
* Multi-value answer

### Exam clues

**Lowest latency → Latency-based**

**Primary/secondary DR → Failover**

**Percentage distribution → Weighted**

**Based on user location → Geolocation**

---

# 77. CLOUDFRONT

AWS CDN.

Caches content at Edge Locations.

```text
User
 ↓
CloudFront Edge
 ↓
Origin
```

Benefits:

* Lower latency
* Faster content delivery
* Reduced origin load
* Global distribution

---

# 78. GLOBAL ACCELERATOR

Improves performance/availability of global applications using the AWS global network.

### CloudFront vs Global Accelerator

**CloudFront**
→ CDN/content caching

**Global Accelerator**
→ Network acceleration for applications

---

# 79. AWS SECURITY SERVICES

## KMS

**Key Management Service**

Manage encryption keys.

Used for encryption at rest by many AWS services.

---

## CloudHSM

Dedicated hardware security module.

More control over cryptographic hardware.

### Memory

**KMS = managed key service**

**CloudHSM = dedicated HSM hardware**

---

# 80. SECRETS MANAGER

Store/manage secrets such as:

* Database passwords
* API keys
* Credentials

Supports secret rotation.

### Parameter Store

Store configuration values and parameters.

### Memory

**Secrets Manager → secrets/credentials**

**Parameter Store → configuration parameters**

---

# 81. WAF

**Web Application Firewall**

Protects web applications.

Helps against attacks such as:

* SQL injection
* Cross-site scripting
* Malicious HTTP requests

Can be associated with services such as:

* CloudFront
* ALB
* API Gateway

---

# 82. AWS SHIELD

DDoS protection.

### Shield Standard

Automatic/basic DDoS protection.

### Shield Advanced

Enhanced DDoS protection and additional capabilities.

### Memory

**WAF = web application attacks**

**Shield = DDoS**

---

# 83. GUARDDUTY

Threat detection.

Analyzes AWS data/signals to detect suspicious activity.

Think:

> "AWS detects potentially malicious behavior."

→ **GuardDuty**

---

# 84. INSPECTOR

Automated vulnerability management.

Looks for vulnerabilities in supported AWS workloads such as:

* EC2
* Containers
* Lambda

### Memory

**Inspector = vulnerability scanning**

---

# 85. MACIE

Data security/privacy service focused on **sensitive data in S3**.

Think:

> "Discover sensitive information such as PII in S3."

→ **Macie**

---

# 86. SECURITY HUB

Centralized security findings.

Aggregates security findings from multiple AWS security services.

Think:

> "Central place to view security findings."

→ **Security Hub**

---

# 87. AWS ARTIFACT

Provides access to AWS:

* Compliance reports
* Agreements
* Security/compliance documentation

### Exam clue

> "Need AWS compliance documents."

→ **AWS Artifact**

---

# 88. AMAZON COGNITO

Customer/application identity.

Use for:

* Web applications
* Mobile applications
* User registration
* Login
* Authentication

### IAM vs Cognito

**IAM**
→ AWS resource access

**Cognito**
→ Application end-user authentication/identity

---

# 89. AWS ORGANIZATIONS

Centrally manage multiple AWS accounts.

Features:

* Consolidated billing
* Account management
* Service Control Policies

---

# 90. SERVICE CONTROL POLICIES — SCP

Used with AWS Organizations.

SCPs establish the **maximum available permissions** for accounts/organizational units.

Important:

**SCP does NOT grant permissions.**

An IAM policy must still grant the permission.

Think:

```text
SCP
 ↓
Maximum boundary

IAM Policy
 ↓
Actual permission
```

Effective access requires both.

---

# 91. IAM IDENTITY CENTER

Centralized workforce access to multiple AWS accounts/applications.

Previously commonly called:

**AWS SSO**

---

# 92. STS

**Security Token Service**

Provides temporary security credentials.

Important for:

* Role assumption
* Cross-account access
* Temporary permissions

---

# 93. AWS DATABASE MIGRATION SERVICE — DMS

Used to migrate databases.

Can help migrate:

* On-premises databases → AWS
* Database engines
* Data with minimal downtime scenarios

### Exam clue

> "Migrate database to AWS"

→ **AWS DMS**

---

# 94. STORAGE GATEWAY

Hybrid cloud storage integration between on-premises and AWS.

Types include concepts such as:

* File Gateway
* Volume Gateway
* Tape Gateway

### Exam clue

> "Connect on-premises storage to AWS storage services."

→ **Storage Gateway**

---

# 95. AWS SNOW FAMILY

Physical devices for moving large amounts of data.

Useful when:

> Network transfer would take too long.

Think:

```text
Huge amount of data
+
Slow network
      ↓
Snowball / Snow family
```

---

# 96. DATASYNC

Automates data transfer between:

* On-premises
* AWS storage

Useful for moving/synchronizing large amounts of file data.

---

# 97. AWS MIGRATION SERVICES

| Requirement                  | Service                           |
| ---------------------------- | --------------------------------- |
| Database migration           | **DMS**                           |
| Server migration             | **Application Migration Service** |
| Hybrid storage               | **Storage Gateway**               |
| Large physical data transfer | **Snow Family**                   |
| Online file/data transfer    | **DataSync**                      |

---

# 98. MACHINE LEARNING / AI SERVICES

## Amazon SageMaker

Build, train and deploy machine-learning models.

Think:

> ML platform for developers/data scientists.

---

## Amazon Bedrock

Build generative AI applications using foundation models.

Think:

> **Generative AI / foundation models**

---

## Rekognition

Image/video analysis.

Examples:

* Object detection
* Face analysis
* Image/video labels

---

## Textract

Extract text/data from documents.

Think:

> PDFs, forms, scanned documents.

---

## Comprehend

Natural language processing.

Examples:

* Sentiment
* Entities
* Key phrases

---

## Transcribe

Speech → text.

---

## Polly

Text → speech.

---

## Translate

Language translation.

---

## Lex

Conversational chatbots.

---

## Kendra

Intelligent enterprise search.

---

# 99. AI SERVICE MEMORY TRICK

```text
Image/video
→ Rekognition

Documents/forms
→ Textract

Text analysis
→ Comprehend

Speech → text
→ Transcribe

Text → speech
→ Polly

Language translation
→ Translate

Chatbot
→ Lex

Enterprise search
→ Kendra

Generative AI
→ Bedrock

Build/train/deploy ML models
→ SageMaker
```

---

# 100. AWS COST MANAGEMENT

## Cost Explorer

Analyze historical/current AWS costs and usage.

---

## AWS Budgets

Set budgets and receive alerts.

Example:

> Alert me when estimated monthly cost exceeds $100.

---

## Cost & Usage Report — CUR

Detailed AWS cost/usage information.

Useful for:

* Detailed billing analysis
* Cost allocation
* Reporting

---

## AWS Pricing Calculator

Estimate AWS costs **before deployment**.

---

# 101. COST ALLOCATION TAGS

Tags can help identify:

```text
Team
Project
Environment
Application
Department
```

Then analyze costs by those categories.

---

# 102. CONSOLIDATED BILLING

AWS Organizations can consolidate billing across accounts.

Benefits:

* One bill
* Combined usage
* Potential volume pricing benefits
* Centralized billing management

---

# 103. AWS SUPPORT PLANS

Know the progression:

```text
Basic
 ↓
Business
 ↓
Enterprise
 ↓
Unified Operations
```

The uploaded course distinguishes Basic, Business+, Enterprise and Unified Operations support offerings and their increasing levels of support.

### Basic

Free.

Provides:

* Documentation
* Forums
* Customer service/community resources
* Core Trusted Advisor checks
* Account health information

### Business+

24/7 support and production-oriented support.

### Enterprise

Additional capabilities including:

* TAM
* Faster response for critical cases
* Additional enterprise support

### Unified Operations

Highest level in the material.

Includes more specialized architectural/operational support.

---

# 104. TRUSTED ADVISOR

Provides recommendations in areas such as:

* Cost optimization
* Performance
* Security
* Fault tolerance
* Service limits
* Operational Excellence

### Exam clue

> "AWS checks your account and recommends improvements."

→ **Trusted Advisor**

---

# 105. AWS WELL-ARCHITECTED FRAMEWORK

## SIX PILLARS

Memorize this order:

```text
1. Operational Excellence
2. Security
3. Reliability
4. Performance Efficiency
5. Cost Optimization
6. Sustainability
```

---

# 106. OPERATIONAL EXCELLENCE

Focus:

* Run and monitor systems
* Improve processes
* Automation
* Operations as code
* Learn from failures
* Observability

Think:

> "Operate and improve the system."

---

# 107. SECURITY

Focus:

* IAM
* Least privilege
* Traceability
* Encryption
* Security at every layer
* Automated security
* Incident response

---

# 108. RELIABILITY

Focus:

* Recover from failures
* High availability
* Fault tolerance
* Automatically recover
* Test recovery procedures
* Scale horizontally

Think:

> "Can the system survive failure?"

---

# 109. PERFORMANCE EFFICIENCY

Focus:

* Efficient resource usage
* Right technology
* Global deployment
* Serverless
* Experimentation
* Monitoring

Think:

> "Are we using resources efficiently?"

---

# 110. COST OPTIMIZATION

Focus:

* Pay only for what you need
* Right-size resources
* Savings Plans
* Reserved Instances
* Spot
* Cost monitoring
* Managed services
* Lifecycle policies

---

# 111. SUSTAINABILITY

Focus:

* Minimize environmental impact
* Maximize utilization
* Efficient hardware/software
* Managed services
* Reduce idle resources

---

# 112. WELL-ARCHITECTED DESIGN PRINCIPLES

Remember:

### Stop guessing capacity

Use elasticity/scaling.

### Test at production scale

Don't assume small-scale behavior predicts production.

### Automate

Use:

* CloudFormation
* Auto Scaling
* Serverless
* CI/CD

### Loose coupling

Avoid tightly coupled components.

Use:

* SQS
* SNS
* Event-driven architecture

### Services, not servers

Prefer managed services where appropriate.

---

# 113. HIGH AVAILABILITY vs FAULT TOLERANCE vs DISASTER RECOVERY

### High Availability

System remains available despite component failures.

Usually:

```text
Multi-AZ
```

### Fault Tolerance

System continues operating despite failures with minimal/no interruption.

### Disaster Recovery

Recovering from major failure.

May involve:

```text
Region A
   ↓ failure
Region B
```

---

# 114. DISASTER RECOVERY STRATEGIES

Know the progression:

```text
Backup & Restore
       ↓
Pilot Light
       ↓
Warm Standby
       ↓
Multi-Site / Active-Active
```

### Backup & Restore

Cheapest/slower recovery.

### Pilot Light

Minimal core infrastructure running.

### Warm Standby

Scaled-down functional environment ready.

### Multi-Site Active-Active

Both environments actively serve users.

Highest cost/complexity.

---

# 115. AWS ARCHITECTURE PATTERN

Typical highly available web application:

```text
                 Internet
                    │
                 Route 53
                    │
               CloudFront
                    │
                   ALB
              ┌─────┴─────┐
              │            │
            EC2           EC2
              │            │
              └─────┬──────┘
                    │
                 RDS
                    │
              Multi-AZ
```

Add:

```text
ElastiCache
S3
CloudWatch
CloudTrail
WAF
```

depending on requirements.

---

# 116. GLOBAL APPLICATION SERVICES

| Requirement                       | Service                      |
| --------------------------------- | ---------------------------- |
| Global DNS                        | **Route 53**                 |
| CDN                               | **CloudFront**               |
| Global application acceleration   | **Global Accelerator**       |
| Faster S3 transfer                | **S3 Transfer Acceleration** |
| AWS infrastructure at customer DC | **Outposts**                 |
| AWS services near 5G              | **Wavelength**               |
| AWS resources closer to users     | **Local Zones**              |

---

# 117. OUTPOSTS

AWS infrastructure deployed in your own data center.

Think:

> "AWS infrastructure on-premises."

---

# 118. LOCAL ZONES

AWS infrastructure placed closer to large population centers.

Useful for:

> latency-sensitive applications.

---

# 119. WAVELENGTH

AWS infrastructure at **5G edge locations**.

Use for:

> ultra-low-latency 5G applications.

---

# 120. DEVELOPER SERVICES

| Service          | Purpose                         |
| ---------------- | ------------------------------- |
| **CodeCommit**   | Git repository                  |
| **CodeBuild**    | Build/test                      |
| **CodeDeploy**   | Deploy application              |
| **CodePipeline** | CI/CD orchestration             |
| **CodeArtifact** | Package/dependency repository   |
| **CDK**          | IaC using programming languages |

### Easy sequence

```text
CodeCommit
    ↓
CodeBuild
    ↓
CodeDeploy
```

CodePipeline orchestrates the workflow.

---

# 121. AWS BACKUP

Centralized managed backup service.

Supports:

* Scheduled backups
* On-demand backups
* Retention
* Lifecycle management
* Cross-Region backup
* Cross-account backup
* Point-in-time recovery for supported services

---

# 122. AWS CAF

**Cloud Adoption Framework**

Six perspectives:

```text
Business
People
Governance
Platform
Security
Operations
```

Useful for organizational cloud transformation.

---

# 123. AWS SERVICE SELECTION — MOST IMPORTANT TABLE

| Scenario                                   | Answer                            |
| ------------------------------------------ | --------------------------------- |
| Virtual server                             | **EC2**                           |
| Serverless function                        | **Lambda**                        |
| Containers                                 | **ECS/EKS**                       |
| Containers without managing servers        | **Fargate**                       |
| Container registry                         | **ECR**                           |
| Simple small application                   | **Lightsail**                     |
| PaaS application deployment                | **Elastic Beanstalk**             |
| Object storage                             | **S3**                            |
| Block storage                              | **EBS**                           |
| Shared file storage                        | **EFS**                           |
| Relational DB                              | **RDS**                           |
| AWS relational DB optimized                | **Aurora**                        |
| NoSQL                                      | **DynamoDB**                      |
| DynamoDB cache                             | **DAX**                           |
| General cache                              | **ElastiCache**                   |
| Data warehouse                             | **Redshift**                      |
| SQL on S3                                  | **Athena**                        |
| Big-data processing                        | **EMR**                           |
| DNS                                        | **Route 53**                      |
| CDN                                        | **CloudFront**                    |
| Load balancing                             | **ELB**                           |
| Auto scaling EC2                           | **ASG**                           |
| API management                             | **API Gateway**                   |
| Queue                                      | **SQS**                           |
| Pub/Sub                                    | **SNS**                           |
| Real-time streaming                        | **Kinesis**                       |
| Traditional message broker                 | **Amazon MQ**                     |
| Infrastructure as Code                     | **CloudFormation**                |
| Infrastructure using programming languages | **CDK**                           |
| Monitoring                                 | **CloudWatch**                    |
| API auditing                               | **CloudTrail**                    |
| Configuration compliance                   | **AWS Config**                    |
| Distributed tracing                        | **X-Ray**                         |
| Threat detection                           | **GuardDuty**                     |
| Vulnerability scanning                     | **Inspector**                     |
| Sensitive S3 data                          | **Macie**                         |
| Web application firewall                   | **WAF**                           |
| DDoS protection                            | **Shield**                        |
| Encryption keys                            | **KMS**                           |
| Secrets                                    | **Secrets Manager**               |
| Compliance documents                       | **Artifact**                      |
| AWS account recommendations                | **Trusted Advisor**               |
| Database migration                         | **DMS**                           |
| Server migration                           | **Application Migration Service** |
| Hybrid storage                             | **Storage Gateway**               |
| Large offline data transfer                | **Snow Family**                   |
| Online data transfer                       | **DataSync**                      |
| ML platform                                | **SageMaker**                     |
| Generative AI                              | **Bedrock**                       |
| Image/video AI                             | **Rekognition**                   |
| Document extraction                        | **Textract**                      |
| NLP                                        | **Comprehend**                    |
| Speech → text                              | **Transcribe**                    |
| Text → speech                              | **Polly**                         |
| Translation                                | **Translate**                     |
| Chatbot                                    | **Lex**                           |
| Enterprise search                          | **Kendra**                        |

---

# 124. "DON'T CONFUSE THESE" — HIGH-VALUE EXAM SECTION

### CloudWatch vs CloudTrail

```text
CloudWatch → Monitoring
CloudTrail  → API auditing
```

### GuardDuty vs Inspector

```text
GuardDuty → Threat detection
Inspector  → Vulnerability management
```

### WAF vs Shield

```text
WAF    → Web application attacks
Shield → DDoS
```

### KMS vs Secrets Manager

```text
KMS             → Encryption keys
Secrets Manager → Passwords/secrets
```

### IAM vs Cognito

```text
IAM      → AWS resource access
Cognito  → Application users
```

### SQS vs SNS

```text
SQS → Queue
SNS → Pub/Sub
```

### S3 vs EBS vs EFS

```text
S3  → Object
EBS → Block
EFS → File
```

### Multi-AZ vs Read Replica

```text
Multi-AZ     → High availability/failover
Read Replica → Read scaling
```

### EC2 vs Lambda

```text
EC2    → Manage virtual servers
Lambda → Run functions/serverless
```

### ECS vs EKS

```text
ECS → AWS container orchestration
EKS → Kubernetes
```

### Fargate vs ECS

```text
ECS     → Orchestration
Fargate → Serverless container compute
```

### CloudFormation vs CDK

```text
CloudFormation → IaC service/template
CDK            → Code-based IaC → CloudFormation
```

### Athena vs Redshift

```text
Athena   → SQL against S3
Redshift → Data warehouse
```

### DAX vs ElastiCache

```text
DAX         → DynamoDB-specific cache
ElastiCache → General-purpose cache
```

### VPN vs Direct Connect

```text
VPN            → Encrypted connection over internet
Direct Connect → Dedicated private connection
```

### Public vs Private subnet

```text
Public  → route to Internet Gateway
Private → no direct internet route
```

---

# 125. CLF-C02 EXAM KEYWORDS

When you see these phrases, immediately think:

| Keyword in question              | Think           |
| -------------------------------- | --------------- |
| **"least privilege"**            | IAM             |
| **"temporary credentials"**      | IAM Role / STS  |
| **"API activity/audit"**         | CloudTrail      |
| **"performance metrics"**        | CloudWatch      |
| **"configuration compliance"**   | Config          |
| **"DDoS"**                       | Shield          |
| **"SQL injection"**              | WAF             |
| **"threat detection"**           | GuardDuty       |
| **"vulnerability"**              | Inspector       |
| **"sensitive data in S3"**       | Macie           |
| **"compliance reports"**         | Artifact        |
| **"encryption keys"**            | KMS             |
| **"database password rotation"** | Secrets Manager |
| **"static files globally"**      | CloudFront + S3 |
| **"DNS"**                        | Route 53        |
| **"high availability database"** | RDS Multi-AZ    |
| **"scale database reads"**       | Read Replica    |
| **"NoSQL"**                      | DynamoDB        |
| **"SQL on S3"**                  | Athena          |
| **"data warehouse"**             | Redshift        |
| **"real-time streaming"**        | Kinesis         |
| **"decouple application"**       | SQS             |
| **"fan-out"**                    | SNS             |
| **"serverless code"**            | Lambda          |
| **"containers without servers"** | Fargate         |
| **"Kubernetes"**                 | EKS             |
| **"private Docker images"**      | ECR             |
| **"infrastructure as code"**     | CloudFormation  |
| **"code-based infrastructure"**  | CDK             |
| **"migrate database"**           | DMS             |
| **"physical data transfer"**     | Snow Family     |
| **"hybrid storage"**             | Storage Gateway |
| **"machine learning platform"**  | SageMaker       |
| **"foundation models / GenAI"**  | Bedrock         |

---

# 126. ULTRA-HIGH-YIELD NUMBERS

For the exam, don't try to memorize every number in the slides. Prioritize recognizable service limits/concepts.

### Ports

```text
22   SSH
21   FTP
80   HTTP
443  HTTPS
3389 RDP
```

### Lambda

**15-minute maximum invocation duration** in the course material.

### S3

**11 nines durability**

```text
99.999999999%
```

### EC2

Reserved Instances / Savings Plans:

**1 or 3 years**

### S3 Glacier

Know the relative retrieval behavior:

```text
Glacier Instant Retrieval
    ↓
milliseconds

Glacier Flexible Retrieval
    ↓
minutes → hours

Glacier Deep Archive
    ↓
hours
```

---

# 127. EXAM QUESTION DECISION TREE

When faced with a scenario:

### Step 1 — What type of problem?

```text
Compute?
Storage?
Database?
Networking?
Security?
Monitoring?
Migration?
Integration?
Cost?
AI?
```

### Step 2 — Managed or unmanaged?

If the question says:

> "Minimize operational overhead"

Prefer:

**Managed/serverless service**

rather than manually managing EC2.

### Step 3 — What is the key requirement?

```text
Low cost?
High availability?
Low latency?
Global?
Serverless?
Real-time?
Security?
Compliance?
Migration?
```

### Step 4 — Match the service.

---

# 128. MOST IMPORTANT CLF-C02 MENTAL MODEL

If you remember only one architecture:

```text
                         USERS
                           │
                        Route 53
                           │
                       CloudFront
                           │
                          WAF
                           │
                          ALB
                           │
              ┌────────────┴────────────┐
              │                         │
            EC2                       EC2
              │                         │
              └──────────┬──────────────┘
                         │
                    ElastiCache
                         │
                     RDS/Aurora
                         │
                       S3

Supporting services:

IAM       → Identity
CloudWatch → Monitoring
CloudTrail  → Audit
KMS         → Encryption
GuardDuty   → Threat detection
AWS Config  → Configuration compliance
SNS         → Notifications
SQS         → Decoupling
Lambda      → Serverless processing
CloudFormation → Infrastructure as Code
```

---

# 129. FINAL 1-PAGE MEMORY SHEET

```text
IAM
├─ Users = people
├─ Groups = users
├─ Roles = temporary/service permissions
├─ Policies = JSON permissions
├─ MFA = extra authentication
└─ Explicit DENY wins

COMPUTE
├─ EC2 = VM
├─ Lambda = serverless function
├─ ECS = containers
├─ EKS = Kubernetes
├─ Fargate = serverless containers
├─ Beanstalk = PaaS
└─ Lightsail = simple AWS

STORAGE
├─ S3 = object
├─ EBS = block
├─ EFS = shared file
├─ Instance Store = temporary/high-performance
└─ Glacier = archive

DATABASE
├─ RDS/Aurora = relational
├─ DynamoDB = NoSQL
├─ ElastiCache = cache
├─ DAX = DynamoDB cache
├─ Redshift = warehouse
├─ Athena = SQL on S3
└─ EMR = big data

NETWORK
├─ VPC = private network
├─ Subnet = network partition
├─ IGW = internet
├─ NAT = private → internet
├─ SG = stateful instance firewall
├─ NACL = stateless subnet firewall
├─ Route 53 = DNS
├─ CloudFront = CDN
├─ ELB = load balancing
└─ Direct Connect = dedicated connection

INTEGRATION
├─ SQS = queue
├─ SNS = pub/sub
├─ Kinesis = streaming
├─ API Gateway = APIs
└─ MQ = traditional broker

SECURITY
├─ KMS = encryption keys
├─ Secrets Manager = secrets
├─ WAF = web attacks
├─ Shield = DDoS
├─ GuardDuty = threats
├─ Inspector = vulnerabilities
├─ Macie = sensitive S3 data
├─ Security Hub = security findings
└─ Artifact = compliance reports

MONITORING
├─ CloudWatch = metrics/logs/alarms
├─ CloudTrail = API audit
├─ Config = configuration
├─ X-Ray = tracing
└─ Health Dashboard = AWS health

MANAGEMENT
├─ CloudFormation = IaC
├─ CDK = code-based IaC
├─ Systems Manager = fleet management
├─ Organizations = multi-account
├─ SCP = maximum permissions
└─ Trusted Advisor = recommendations

MIGRATION
├─ DMS = databases
├─ Application Migration Service = servers
├─ DataSync = online data
├─ Storage Gateway = hybrid storage
└─ Snow Family = physical transfer

AI
├─ SageMaker = ML
├─ Bedrock = GenAI
├─ Rekognition = images/video
├─ Textract = documents
├─ Comprehend = NLP
├─ Transcribe = speech → text
├─ Polly = text → speech
├─ Translate = translation
├─ Lex = chatbot
└─ Kendra = enterprise search

COST
├─ Cost Explorer = analyze
├─ Budgets = alerts
├─ Pricing Calculator = estimate
├─ CUR = detailed usage/cost
├─ Savings Plans = usage commitment
├─ Reserved = long-term instances
└─ Spot = cheap/interruption-prone
```

## The 20 things I'd memorize first

1. **IAM = identity and permissions**
2. **Explicit Deny always wins**
3. **Role = temporary/service permissions**
4. **EC2 = VM**
5. **Lambda = serverless function**
6. **S3 = object storage**
7. **EBS = block storage**
8. **EFS = shared file storage**
9. **RDS Multi-AZ = HA**
10. **RDS Read Replica = read scaling**
11. **DynamoDB = NoSQL**
12. **SQS = queue / decoupling**
13. **SNS = pub/sub**
14. **CloudWatch = monitoring**
15. **CloudTrail = API auditing**
16. **Route 53 = DNS**
17. **CloudFront = CDN**
18. **WAF = web attacks; Shield = DDoS**
19. **GuardDuty = threat detection**
20. **CloudFormation = Infrastructure as Code**

The most important exam skill is **scenario recognition**: don't ask only *“What does this service do?”* Ask *“What exact requirement in this question is the service designed to solve?”* The slides themselves emphasize this service-recognition approach and cover more than 40 AWS services for the certification. 
