# AIP-C01 5-Week Study Plan

Oct 6, 2026 · @Isuru Siriwardana

## Exam at a glance

AIP-C01 has 65 scored + 10 unscored questions, a scaled pass mark of 750/1000, and compensatory scoring, so time goes where the weight is. Source: [AWS exam guide](https://docs.aws.amazon.com/aws-certification/latest/ai-professional-01/ai-professional-01.html).

| Domain | Weight | Scored Qs (approx.) | Plan time | What it really tests |
| --- | --- | --- | --- | --- |
| 1. FM Integration, Data Management & Compliance | 31% | \~20 | 11 sessions | FM selection, resilience (cross-Region inference, AppConfig), SageMaker customization, data pipelines, vector stores, RAG retrieval, prompt engineering and Prompt Management/Flows |
| 2. Implementation & Integration | 26% | \~17 | 5 sessions | Agents (Strands, AgentCore, Agent Squad, MCP, Bedrock Agents), deployment (Bedrock vs SageMaker endpoints), Converse/streaming APIs, retries, routing, enterprise integration, CI/CD |
| 3. AI Safety, Security & Governance | 20% | \~13 | 4 sessions | Guardrails in depth, prompt-injection defence, PII (Comprehend, Macie, masking), VPC endpoints/IAM, lineage, audit logging, responsible AI |
| 4. Operational Efficiency & Optimization | 12% | \~8 | 2 sessions | Token cost, caching, batch inference, provisioned throughput, latency, CloudWatch/invocation logging |
| 5. Testing, Validation & Troubleshooting | 11% | \~7 | 3 sessions | Bedrock Model Evaluations, LLM-as-a-judge, RAG evaluation, A/B and canary, diagnosing retrieval and prompt failures |

Your two Udemy tests mirror these weights exactly (23 / 20 / 15 / 9 / 8 questions per 75). Across all three files, the most-tested services are Lambda, Bedrock Guardrails, Knowledge Bases, CloudWatch, SageMaker AI, API Gateway, OpenSearch, Converse/streaming APIs, Step Functions, AgentCore and MCP.

Out of scope: model training, advanced ML and feature engineering. Your Architect Associate covers most of the plumbing (IAM, VPC, Lambda, SQS, EventBridge), so this plan spends its time on Bedrock-specific behaviour and the "which option has the LEAST overhead" judgement calls.

The official 20-question file has no answer key. Check your answers in the AWS Skill Builder version of that set.

## How the plan works

Every session opens with recall, not reading, because pulling facts from memory is what makes them stick. Weekdays run \~1 hour, Saturdays \~2 hours for labs and tests, and Sundays are review days.

### Daily session (60–90 min)

1. **Recall (15 min).** Close everything. On a blank page, write what you remember from the days listed in the schedule's Recall column. Then check against your notes and circle the gaps. Finish with your due flashcards.
2. **Learn (40–60 min).** Work through that day's skills from the exam guide, using the AWS docs, your course, or a short lab. Read with the question "when would AWS want me to pick this over the alternative?"
3. **Capture (10 min).** Write a one-page note in your own words. Add 5–10 flashcards, mostly in scenario form: "Throttled, same model, no extra cost → ?".

### Repetition schedule

Each topic comes back about 1, 3 and 7 days after you learn it (the Recall column does this for you), again on the Sunday review, and once more in the final week. Use Anki or a similar app for flashcards so card spacing runs automatically.

### Error log

Keep one sheet for every practice question you miss or guess. A guessed right answer counts as a miss.

| Q ref | Domain / skill | My answer | Correct | Trigger words in the question | Why each distractor is wrong | Redo on |
| --- | --- | --- | --- | --- | --- | --- |
| T1-Q2 | 1.4.3 | More shards | Multi-index + fewer, larger shards | "tens of millions", "JVM pressure", "per domain" | Many small shards add coordination cost; UltraWarm is slower | +3 days, +10 days |

Re-attempt each logged question cold on its redo dates. The "why distractors are wrong" column matters most, because Professional questions are won by eliminating options.

### Practice test rules

- Take the Udemy tests on Udemy, not from these files. The files are for reviewing explanations afterwards.
- Budget about 2 minutes per question and flag anything over 3 minutes.
- Aim for 75%+ on first attempts. A retake score is inflated by memory, so judge retakes on whether you can explain every distractor.
- Your scores to beat: record them in the schedule below.

## 35-day schedule

The plan runs Wed 7 Oct to Tue 10 Nov, with the exam on or just after 11 Nov. Skill numbers (e.g. 1.2.3) map to the exam guide's domain pages, so read those bullets as your checklist for each day. Every link is official AWS documentation or an AWS blog, and most are the same pages your Udemy explanations cite.

### Week 1 (7–13 Oct): Domain 1 foundations

| Day | Date | Learn | Official resources | Recall | Done / notes |
| --- | --- | --- | --- | --- | --- |
| 1 | Wed 7 Oct | Read all 5 domain pages and the in-scope services list. Do the 20 official questions untimed as a diagnostic, marking confidence (sure / unsure / guess) for each. Set up the error log and flashcard deck. | [Exam guide](https://docs.aws.amazon.com/aws-certification/latest/ai-professional-01/ai-professional-01.html) · [In-scope services](https://docs.aws.amazon.com/aws-certification/latest/ai-professional-01/aip-01-in-scope-services.html) · [Certification page and Skill Builder prep](https://aws.amazon.com/certification/certified-generative-ai-developer-professional/) | — |  |
| 2 | Thu 8 Oct | Bedrock basics: model families and choosing an FM, InvokeModel vs Converse, request formats, temperature, top-p/top-k, max tokens, stop sequences (1.2.1, 1.3.3, 4.2.4) | [Supported foundation models](https://docs.aws.amazon.com/bedrock/latest/userguide/models.html) · [Using the Converse API](https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference-call.html) · [Inference parameters](https://docs.aws.amazon.com/bedrock/latest/userguide/inference-parameters.html) · [Model-specific request parameters](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters.html) | D1 |  |
| 3 | Fri 9 Oct | Resilience and flexibility: quotas and throttling, cross-Region inference profiles, on-demand vs provisioned throughput, AppConfig for model switching, API Gateway + Lambda abstraction, Step Functions circuit breaker, graceful degradation (1.2.2, 1.2.3, 2.4.3) | [Cross-Region inference](https://docs.aws.amazon.com/bedrock/latest/userguide/cross-region-inference.html) · [Provisioned Throughput](https://docs.aws.amazon.com/bedrock/latest/userguide/prov-throughput.html) · [Scaling throughput best practices](https://docs.aws.amazon.com/bedrock/latest/userguide/scaling-throughput-best-practices.html) · [What is AppConfig?](https://docs.aws.amazon.com/appconfig/latest/userguide/what-is-appconfig.html) · [Circuit breaker with Step Functions (blog)](https://aws.amazon.com/blogs/compute/using-the-circuit-breaker-pattern-with-aws-step-functions-and-amazon-dynamodb/) | D2 |  |
| 4 | Sat 10 Oct (2h) | Customization lifecycle: Bedrock fine-tuning, continued pre-training and distillation vs SageMaker JumpStart; LoRA and adapters; Model Registry; SageMaker endpoint types (real-time, serverless, async, batch transform); deploy pipelines and rollback (1.2.4, 2.2.1). Lab 1. | [Bedrock model customization](https://docs.aws.amazon.com/bedrock/latest/userguide/custom-models.html) · [Bedrock distillation](https://docs.aws.amazon.com/bedrock/latest/userguide/model-distillation.html) · [SageMaker inference options](https://docs.aws.amazon.com/sagemaker/latest/dg/deploy-model-options.html) · [Model Registry](https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry-models.html) · [Blue/green deployments](https://docs.aws.amazon.com/sagemaker/latest/dg/deployment-guardrails-blue-green.html) | D3, D2 |  |
| 5 | Sun 11 Oct | **Weekly review 1:** blurt D2–D4 one-pagers, then redo the official questions on those topics. | Your notes from D2–D4 | D2–D4 |  |
| 6 | Mon 12 Oct | Data pipelines: Glue Data Quality, Data Wrangler, Lambda validation, multimodal inputs (Transcribe, Textract, Bedrock Data Automation, multimodal FMs), Comprehend entity extraction (1.3) | [Glue Data Quality](https://docs.aws.amazon.com/glue/latest/dg/data-quality-getting-started.html) · [DQDL reference](https://docs.aws.amazon.com/glue/latest/dg/dqdl.html) · [Bedrock Data Automation](https://docs.aws.amazon.com/bedrock/latest/userguide/bda.html) · [SageMaker Processing](https://docs.aws.amazon.com/sagemaker/latest/dg/processing-job.html) · [Comprehend DetectEntities](https://docs.aws.amazon.com/comprehend/latest/APIReference/API_DetectEntities.html) · [Textract AnalyzeDocument](https://docs.aws.amazon.com/textract/latest/dg/API_AnalyzeDocument.html) | D4, D3 |  |
| 7 | Tue 13 Oct | Prompt engineering and governance: Prompt Management (variables, versions, approvals), Prompt Flows (chains, conditions), chain-of-thought, structured output, DynamoDB conversation history, Comprehend intent (1.6). Lab 2. | [Prompt engineering concepts](https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-engineering-guidelines.html) · [Prompt Management](https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-management.html) · [Deploy prompts with versions](https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-management-deploy.html) · [Bedrock Flows](https://docs.aws.amazon.com/bedrock/latest/userguide/flows.html) · [Flow node types](https://docs.aws.amazon.com/bedrock/latest/userguide/flows-nodes.html) | D6, D4 |  |

### Week 2 (14–20 Oct): RAG and retrieval

| Day | Date | Learn | Official resources | Recall | Done / notes |
| --- | --- | --- | --- | --- | --- |
| 8 | Wed 14 Oct | Vector stores: Knowledge Bases managed options (OpenSearch Serverless and managed, Aurora pgvector, S3 Vectors, others); pick by cost, scale and ops effort (1.4.1, 1.5.3) | [Knowledge Bases overview](https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html) · [S3 Vectors with Knowledge Bases](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-vectors-bedrock-kb.html) · [Aurora PostgreSQL as a knowledge base](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html) · [OpenSearch vector search](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/vector-search.html) · [OpenSearch vector database explained (blog)](https://aws.amazon.com/blogs/big-data/amazon-opensearch-services-vector-database-capabilities-explained/) | D7, D4, D2 |  |
| 9 | Thu 15 Oct | Ingestion: chunking strategies (fixed, hierarchical, semantic, none, custom Lambda), parsing options, embedding models and dimensions, metadata and filtering (1.5.1, 1.5.2, 1.4.2) | [How Knowledge Bases process data](https://docs.aws.amazon.com/bedrock/latest/userguide/kb-how-data.html) · [Chunking](https://docs.aws.amazon.com/bedrock/latest/userguide/kb-chunking.html) · [Custom transformation Lambda](https://docs.aws.amazon.com/en_us/bedrock/latest/userguide/kb-custom-transformation.html) · [Titan Text Embeddings](https://docs.aws.amazon.com/bedrock/latest/userguide/titan-embedding-models.html) · [Metadata files](https://docs.aws.amazon.com/bedrock/latest/userguide/kb-metadata.html) | D8, D6, D3 |  |
| 10 | Fri 16 Oct | Retrieval quality: Retrieve vs RetrieveAndGenerate, hybrid search, reranker models, query expansion and decomposition, OpenSearch sharding, multi-index and hierarchical indexing (1.5.4, 1.5.5, 1.4.3, 4.2.2) | [Retrieval and generation](https://docs.aws.amazon.com/bedrock/latest/userguide/kb-how-retrieval.html) · [Query configuration (hybrid search, filters)](https://docs.aws.amazon.com/bedrock/latest/userguide/kb-test-config.html) · [Reranker models](https://docs.aws.amazon.com/bedrock/latest/userguide/rerank.html) · [Hybrid search on OpenSearch Serverless](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/serverless-configure-neural-search.html) · [OpenSearch shard sizing](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/bp-sharding.html) | D9, D7, D4 |  |
| 11 | Sat 17 Oct (2h) | Keeping data fresh: ingestion jobs, event-driven sync (S3 events, EventBridge, SQS, Lambda), data source connectors, KB logging; retrieval via function calling and MCP (1.4.4, 1.4.5, 1.5.6). Lab 3. | [Sync and ingest](https://docs.aws.amazon.com/bedrock/latest/userguide/kb-data-source-sync-ingest.html) · [Direct ingestion](https://docs.aws.amazon.com/bedrock/latest/userguide/kb-direct-ingestion.html) · [Data source connectors](https://docs.aws.amazon.com/bedrock/latest/userguide/data-source-connectors.html) · [Knowledge Base monitoring and logs](https://docs.aws.amazon.com/bedrock/latest/userguide/kb-managed-observability.html) · [S3 events via EventBridge](https://docs.aws.amazon.com/AmazonS3/latest/userguide/EventBridge.html) · [Tool use (function calling)](https://docs.aws.amazon.com/bedrock/latest/userguide/tool-use.html) | D10, D8, D6 |  |
| 12 | Sun 18 Oct | **Weekly review 2:** blurt D8–D11, then draw a full RAG pipeline from memory (ingest → chunk → embed → store → retrieve → rerank → generate). | Your notes from D8–D11 | D8–D11, D2, D3 |  |
| 13 | Mon 19 Oct | RAG troubleshooting: embedding model or dimension mismatch, poor chunk size, context window overflow, stale index, low relevance; retrieval quality testing (5.2.1, 5.2.4, 5.1.6) | [Evaluate RAG with Knowledge Bases](https://docs.aws.amazon.com/bedrock/latest/userguide/evaluation-kb.html) · [RAG evaluation metrics](https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-evaluation-metrics.html) · [How tokens are counted](https://docs.aws.amazon.com/bedrock/latest/userguide/quotas-token-burndown.html) · [Retrieve API](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_agent-runtime_Retrieve.html) | D11, D9, D7 |  |
| 14 | Tue 20 Oct | Solution design: Well-Architected Generative AI Lens, PoCs on Bedrock, choosing integration and deployment patterns (1.1). Write a one-page Domain 1 summary. | [Generative AI Lens](https://docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/generative-ai-lens.html) · [Well-Architected Tool](https://docs.aws.amazon.com/wellarchitected/latest/userguide/intro.html) · [Generative AI best practices framework](https://docs.aws.amazon.com/audit-manager/latest/userguide/aws-generative-ai-best-practices.html) | D13, D10, D7 |  |

### Week 3 (21–27 Oct): Domain 2 and the first mock

| Day | Date | Learn | Official resources | Recall | Done / notes |
| --- | --- | --- | --- | --- | --- |
| 15 | Wed 21 Oct | Agent basics: Bedrock Agents (action groups, OpenAPI schemas, return of control, memory, trace), ReAct with Step Functions, stopping conditions, timeouts, IAM boundaries (2.1.2, 2.1.3) | [Bedrock Agents](https://docs.aws.amazon.com/bedrock/latest/userguide/agents.html) · [Action groups](https://docs.aws.amazon.com/bedrock/latest/userguide/agents-action-add.html) · [OpenAPI schemas](https://docs.aws.amazon.com/bedrock/latest/userguide/agents-api-schema.html) · [Agent trace](https://docs.aws.amazon.com/bedrock/latest/userguide/trace-events.html) · [Step Functions with Bedrock](https://docs.aws.amazon.com/step-functions/latest/dg/connect-bedrock.html) · [Step Functions error handling](https://docs.aws.amazon.com/step-functions/latest/dg/concepts-error-handling.html) | D14, D11, D8 |  |
| 16 | Thu 22 Oct | Agent frameworks: Strands Agents, AWS Agent Squad, AgentCore (Runtime, Memory, Gateway, Identity, Observability), MCP servers on Lambda vs ECS (2.1.1, 2.1.6, 2.1.7, 2.5.5) | [Strands Agents quickstart](https://strandsagents.com/latest/documentation/docs/user-guide/quickstart/overview) · [Strands deep dive (blog)](https://aws.amazon.com/blogs/machine-learning/strands-agents-sdk-a-technical-deep-dive-into-agent-architectures-and-observability/) · [Agent Squad](https://awslabs.github.io/agent-squad) · [AgentCore Runtime sessions](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-sessions.html) · [AgentCore Memory](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory.html) · [AgentCore Gateway](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway.html) · [MCP servers in AgentCore Runtime](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-mcp.html) | D15, D13, D9 |  |
| 17 | Fri 23 Oct | Coordination and humans: Step Functions approval steps, feedback via API Gateway, model ensembles and cascading, Intelligent Prompt Routing, content-based routing (2.1.4, 2.1.5, 2.2.3, 2.4.4) | [Human approval tutorial](https://docs.aws.amazon.com/step-functions/latest/dg/tutorial-human-approval.html) · [Prompt chaining with human in the loop (blog)](https://aws.amazon.com/blogs/machine-learning/building-generative-ai-prompt-chaining-workflows-with-human-in-the-loop/) · [Intelligent Prompt Routing](https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-routing.html) · [Orchestrate GenAI with Step Functions (blog)](https://aws.amazon.com/blogs/machine-learning/orchestrate-generative-ai-workflows-with-amazon-bedrock-and-aws-step-functions/) | D16, D14, D10 |  |
| 18 | Sat 24 Oct (2h) | **Udemy Test 1, part A:** Q1–38 timed (\~80 min). Mark and log errors (\~40 min). Use practice mode if you can't pause the timed test. | Further-reading links in each explanation | — | Score: |
| 19 | Sun 25 Oct | **Udemy Test 1, part B:** Q39–75 timed, then log errors. This replaces the weekly review. | Further-reading links in each explanation | — | Score: |
| 20 | Mon 26 Oct | 30 min on the Test 1 error log, grouped by skill. Then APIs: Converse vs InvokeModel, streaming (ConverseStream, WebSocket API, Lambda response streaming), async with SQS, backoff, rate limiting, X-Ray (2.4, 2.5.1) | [Converse API reference](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html) · [ConverseStream](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_ConverseStream.html) · [API Gateway response streaming](https://docs.aws.amazon.com/apigateway/latest/developerguide/response-transfer-mode.html) · [WebSocket @connections](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-how-to-call-websocket-api-connections.html) · [API Gateway + SQS async pattern](https://docs.aws.amazon.com/en_us/prescriptive-guidance/latest/patterns/integrate-amazon-api-gateway-with-amazon-sqs-to-handle-asynchronous-rest-apis.html) · [API Gateway throttling](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-request-throttling.html) · [X-Ray with Lambda](https://docs.aws.amazon.com/lambda/latest/dg/services-xray.html) | D17, Test 1 log, D11 |  |
| 21 | Tue 27 Oct | Deployment and enterprise: SageMaker LMI/DJL containers, tensor parallelism, quantization, batching; EventBridge and legacy APIs; identity federation; Outposts, Wavelength; CodePipeline and GenAI gateways; Q Developer, Amplify, Data Automation (2.2.2, 2.3, 2.5.2–2.5.4, 2.5.6) | [Large model inference](https://docs.aws.amazon.com/sagemaker/latest/dg/large-model-inference.html) · [LMI endpoint parameters](https://docs.aws.amazon.com/sagemaker/latest/dg/large-model-inference-hosting.html) · [EventBridge targets](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-targets.html) · [Bedrock IAM policy examples](https://docs.aws.amazon.com/bedrock/latest/userguide/security_iam_id-based-policy-examples.html) · [What is Outposts?](https://docs.aws.amazon.com/outposts/latest/network-userguide/what-is-outposts.html) · [CodePipeline stage rollback](https://docs.aws.amazon.com/en_us/codepipeline/latest/userguide/stage-rollback.html) · [What is Q Developer?](https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/what-is.html) | D20, D16, D13 |  |

### Week 4 (28 Oct – 3 Nov): Domains 3 and 4

| Day | Date | Learn | Official resources | Recall | Done / notes |
| --- | --- | --- | --- | --- | --- |
| 22 | Wed 28 Oct | Guardrails in depth: content and prompt-attack filters, denied topics, word filters, sensitive info (mask vs block, regex), contextual grounding, Automated Reasoning checks, ApplyGuardrail API, trace, enforcing with the bedrock:GuardrailIdentifier IAM condition key (3.1.1, 3.1.2) | [Guardrails overview](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html) · [How guardrails work](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-how.html) · [Prompt attack filter](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-prompt-attack.html) · [Sensitive information filters](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-sensitive-filters.html) · [Contextual grounding](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-contextual-grounding-check.html) · [Automated Reasoning checks](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-automated-reasoning-checks.html) · [ApplyGuardrail API](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-use-independent-api.html) · [Least-privilege Bedrock (blog)](https://aws.amazon.com/blogs/security/implementing-least-privilege-access-for-amazon-bedrock/) | D21, D17, D15 |  |
| 23 | Thu 29 Oct | Defence in depth: Comprehend pre-filters, Lambda post-validation, API Gateway response filtering, prompt injection and jailbreak detection, JSON Schema outputs, hallucination reduction (3.1.3–3.1.5) | [Prompt injection security](https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-injection.html) · [Comprehend PII detection](https://docs.aws.amazon.com/comprehend/latest/dg/pii.html) · [Guardrails with the Converse API](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-use-converse-api.html) · [Test a guardrail](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-test.html) | D22, D20, D16 |  |
| 24 | Fri 30 Oct | Data security: VPC endpoints and PrivateLink, least-privilege IAM, KMS, Lake Formation, Macie, Comprehend PII, S3 Lifecycle retention, Bedrock data-privacy guarantees (3.2) | [Bedrock VPC endpoints](https://docs.aws.amazon.com/bedrock/latest/userguide/vpc-interface-endpoints.html) · [Bedrock data protection](https://docs.aws.amazon.com/bedrock/latest/userguide/data-protection.html) · [Macie discovery jobs](https://docs.aws.amazon.com/macie/latest/user/discovery-jobs.html) · [Lake Formation permissions](https://docs.aws.amazon.com/lake-formation/latest/dg/managing-permissions.html) · [S3 Lifecycle](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html) | D23, D21, D17 |  |
| 25 | Sat 31 Oct (2h) | Governance and responsible AI: model cards, Glue Data Catalog lineage, CloudTrail vs model invocation logging, S3 Object Lock, fairness evaluation, agent tracing (3.3, 3.4). Lab 4. | [SageMaker Model Cards](https://docs.aws.amazon.com/sagemaker/latest/dg/model-cards.html) · [Glue Data Catalog and crawlers](https://docs.aws.amazon.com/glue/latest/dg/catalog-and-crawler.html) · [Bedrock CloudTrail logging](https://docs.aws.amazon.com/bedrock/latest/userguide/logging-using-cloudtrail.html) · [Model invocation logging](https://docs.aws.amazon.com/bedrock/latest/userguide/model-invocation-logging.html) · [S3 Object Lock](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html) | D24, D22, D20 |  |
| 26 | Sun 1 Nov | **Weekly review 4:** blurt D22–D25, redo every Test 1 error-log question, re-read the Domain 1 summary from D14. | Your notes and error log | D22–D25, Test 1 log |  |
| 27 | Mon 2 Nov | Cost and performance: token efficiency, prompt caching, batch inference, tiered models and routing, provisioned throughput sizing, semantic caching, latency-optimized inference, parallel calls (4.1, 4.2) | [Prompt caching](https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-caching.html) · [Batch inference](https://docs.aws.amazon.com/bedrock/latest/userguide/batch-inference.html) · [Count tokens](https://docs.aws.amazon.com/bedrock/latest/userguide/count-tokens.html) · [Latency-optimized inference](https://docs.aws.amazon.com/bedrock/latest/userguide/latency-optimized-inference.html) · [Intelligent Prompt Routing for cost (blog)](https://aws.amazon.com/blogs/machine-learning/use-amazon-bedrock-intelligent-prompt-routing-for-cost-and-latency-benefits/) · [Bedrock pricing](https://docs.aws.amazon.com/en_us/bedrock/latest/userguide/bedrock-pricing.html) | D25, D23, D20 |  |
| 28 | Tue 3 Nov | Monitoring: Bedrock CloudWatch metrics, invocation logs with Logs Insights, anomaly detection, X-Ray, AgentCore observability, vector store monitoring, golden datasets (4.3) | [Monitor Bedrock with CloudWatch](https://docs.aws.amazon.com/bedrock/latest/userguide/monitoring-cw.html) · [Runtime metrics](https://docs.aws.amazon.com/bedrock/latest/userguide/monitoring-runtime-metrics.html) · [CloudWatch Logs Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html) · [CloudWatch model invocations](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/model-invocations.html) · [OpenSearch Serverless monitoring](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/monitoring-cloudwatch.html) · [Track usage by request metadata](https://docs.aws.amazon.com/bedrock/latest/userguide/cost-mgmt-request-metadata.html) | D27, D25, D21 |  |

### Week 5 (4–10 Nov): Domain 5, final mock, consolidation

| Day | Date | Learn | Official resources | Recall | Done / notes |
| --- | --- | --- | --- | --- | --- |
| 29 | Wed 4 Nov | Evaluation: Bedrock Model Evaluations (automatic, human, LLM-as-a-judge), Knowledge Base RAG evaluation, relevance and faithfulness metrics, A/B and canary testing, regression gates (5.1) | [Bedrock evaluations](https://docs.aws.amazon.com/bedrock/latest/userguide/evaluation.html) · [LLM-as-a-judge](https://docs.aws.amazon.com/bedrock/latest/userguide/evaluation-judge.html) · [Human evaluations](https://docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-type-human.html) · [Evaluation metrics](https://docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-metrics.html) · [Create a RAG evaluation job](https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-evaluation-create.html) · [CloudWatch Synthetics canaries](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Synthetics_Canaries.html) | D28, D25, D22 |  |
| 30 | Thu 5 Nov | Troubleshooting: context overflow and truncation, API errors (throttling, validation, timeouts), prompt regression, schema validation, agent evaluation (5.1.7, 5.2) | [Bedrock API error codes](https://docs.aws.amazon.com/bedrock/latest/userguide/troubleshooting-api-error-codes.html) · [AgentCore Evaluations](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/evaluations.html) · [Compare prompt versions](https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-management-version-compare.html) · [API Gateway request validation](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-method-request-validation.html) | D29, D27, D23 |  |
| 31 | Fri 6 Nov | Retake the 20 official questions (25 min) and compare with Day 1. Check answers on Skill Builder and log misses. | [Certification page and Skill Builder prep](https://aws.amazon.com/certification/certified-generative-ai-developer-professional/) | D30, D28, D24 | Score: |
| 32 | Sat 7 Nov (2.5h) | **Udemy Test 2, full and timed** as your dress rehearsal. Split into two sittings only if you must. | Further-reading links in each explanation | — | Score: |
| 33 | Sun 8 Nov | Test 2 error log, then redo every logged question from both tests cold. | Links you saved in the error log | Full log |  |
| 34 | Mon 9 Nov | Weakest two domains from Test 2: re-read those one-pagers and docs. Build a one-page cram sheet. | The links for those days above | Weak domains |  |
| 35 | Tue 10 Nov | Light only: cram sheet, decision rules (below), flashcards. Stop by early evening and sleep well. | — | Cram sheet |  |

## Hands-on labs

Four short labs turn the most-tested features into things you have actually clicked, which makes scenario questions far easier to read. Set an AWS Budgets alert first, and work in us-east-1 or us-west-2 for the widest model and feature coverage.

| Lab | Day | What to do (≈45–60 min) | Step-by-step guide | Cost note |
| --- | --- | --- | --- | --- |
| 1. Bedrock basics | 4 | In the playground, compare two models on one prompt. Change temperature, top-p and max tokens, and add a stop sequence. Call the Converse API once from the CLI or a Python script and read the JSON request and response. | [Using the Converse API](https://docs.aws.amazon.com/bedrock/latest/userguide/conversation-inference-call.html) | Cents |
| 2. Prompt Management and Flows | 7 | Create a prompt with variables, save two versions, and build a small flow with a condition node that routes to different prompts. | [Create prompts](https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-management-create.html) · [Create a flow](https://docs.aws.amazon.com/bedrock/latest/userguide/flows-create.html) · [Test a flow](https://docs.aws.amazon.com/bedrock/latest/userguide/flows-test.html) | Cents |
| 3. Knowledge Base | 11 | Upload a few documents with metadata files to S3. Create a Knowledge Base, sync it, then test Retrieve with a metadata filter and with reranking on. Delete one document, re-sync, and confirm it is gone. | [Create a knowledge base](https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-create.html) · [Test with Retrieve](https://docs.aws.amazon.com/bedrock/latest/userguide/kb-test-retrieve.html) · [S3 Vectors setup](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-vectors-bedrock-kb.html) | Prefer S3 Vectors. OpenSearch Serverless bills hourly even when idle, so delete it the same day. |
| 4. Guardrails and logging | 25 | Build a guardrail with a denied topic, a prompt-attack filter and PII masking. Test it with trace on and read why each prompt was blocked. Turn on model invocation logging to S3 or CloudWatch and find your test calls. | [Test a guardrail](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-test.html) · [Model invocation logging](https://docs.aws.amazon.com/bedrock/latest/userguide/model-invocation-logging.html) | Cents |

Agents (Strands, AgentCore) are optional. If you have spare time on Day 16, run the [Strands quickstart](https://strandsagents.com/latest/documentation/docs/user-guide/quickstart/overview) with one custom tool; otherwise reading the docs is enough.

## High-yield decision rules

Most questions hinge on a qualifier (LEAST operational overhead, MOST cost-effective, MINIMAL code change), and the managed Bedrock feature usually wins over a custom Lambda build. Turn each row into a flashcard and add your own from the error log.

| When the question says… | Usually points to | Common distractor |
| --- | --- | --- |
| Throttling at peak, same model, no extra ops, cost-effective | Cross-Region inference profile | Provisioned throughput (costly), custom multi-Region Lambda |
| Steady, predictable high volume or a custom model on Bedrock | Provisioned throughput | On-demand with retries |
| Large offline jobs, no real-time need, cheapest | Bedrock batch inference, or SageMaker batch transform | Real-time endpoints |
| Long-running or large-payload inference on SageMaker, minutes to respond | SageMaker asynchronous inference | Real-time endpoint (60 s limit) |
| Swap models or providers without code changes | AppConfig or Prompt Management config behind API Gateway + Lambda | Hard-coded model IDs |
| Every model call must use a guardrail | IAM condition key bedrock:GuardrailIdentifier | Lambda proxy that "remembers" to add it |
| See exactly why a guardrail blocked something | Guardrail trace on the response | CloudTrail |
| Mask PII but keep the answer useful | Guardrails PII masking, Comprehend placeholders before the call | Blocking or discarding the whole message |
| Find PII sitting in S3 | Amazon Macie | Comprehend on live prompts |
| Stop output after a phrase | Stop sequences | Lower max tokens |
| Versioned, approved prompt templates | Bedrock Prompt Management | S3, DynamoDB or Secrets Manager |
| Multi-step prompt chain with branching, low code | Bedrock Prompt Flows | Custom Step Functions build |
| Audit who called which API | CloudTrail | Invocation logging |
| Full prompt and response content for analysis or retention | Model invocation logging (S3 + Object Lock for long retention) | CloudTrail |
| Debug Knowledge Base ingestion failures | Knowledge Base logging to CloudWatch Logs | Invocation logging |
| Most relevant chunk ranks too low | Reranker model; hybrid search | Learning-to-Rank or custom scoring |
| Exact terms (codes, IDs) missed by semantic search | Hybrid search (keyword + vector) | Bigger embedding model |
| Answers suddenly "no relevant info" after a code change, no errors | Query embedded with a different model or dimension than the index | Cluster health, FM failure |
| New or deleted docs must show up fast | S3 events → EventBridge/SQS → Lambda → ingestion job | Nightly scheduled sync |
| Huge vector set, infrequent queries, cheapest, serverless | S3 Vectors | Always-on OpenSearch cluster |
| Deploy existing agent code, managed runtime, long streaming sessions | AgentCore Runtime | Self-managed ECS or EC2 |
| Agent tool calls fail on bad parameters | Typed tool schema + validation and structured errors in Lambda | Retries or a bigger model |
| Simple, stateless tool for an agent | MCP server on Lambda | MCP server on ECS (complex, stateful tools) |
| Human approval mid-workflow | Step Functions with a task token wait | Polling loop |
| Mixed easy and hard queries, cut cost | Tiered models or Intelligent Prompt Routing | Largest model for everything |
| Repeated long system prompt or context | Prompt caching | Bigger provisioned throughput |
| Compare models on your data | Bedrock Model Evaluations (LLM-as-a-judge for scale, human for nuance) | Manual spot checks |
| Is retrieval or generation the weak part? | Knowledge Base RAG evaluation (retrieve-only vs retrieve-and-generate) | General model evaluation |
| Private traffic to Bedrock | VPC interface endpoint (PrivateLink) | NAT gateway |
| Data lineage and source attribution | Glue Data Catalog + metadata tags on outputs | SageMaker Clarify |

Strong heuristics for eliminating options:

- Choose a managed feature over a custom Lambda, Step Functions or SageMaker build unless the question demands control.
- Answers that train a model are rarely right when RAG, prompting or a guardrail would solve it.
- In "Select TWO" questions, the two answers usually cover different layers, such as input plus output, or retrieval plus ranking.
- Watch for real but wrong-job services: CloudTrail vs invocation logs, Macie vs Comprehend, Kendra vs Knowledge Bases.

## Exam week and exam day

Book the exam now for around 11 Nov so the date anchors the plan. If Test 2 on Day 32 comes in under 70%, consider moving it back a week and repeating Weeks 4–5.

- **If you fall behind:** skip a lab before you skip a Sunday review. Domains 4 and 5 can be squeezed; Domains 1–3 (77% of the exam) cannot.
- **On each question:** read the last line first to find the qualifier, then underline constraints in the scenario (latency, cost, "same model", "no code changes").
- **Pacing:** aim for about 2 minutes per question. Flag anything that runs over 3 minutes and come back to it.
- **Never leave a blank.** Unanswered questions score as wrong and there is no guessing penalty.
- **On multi-select:** confirm how many answers the question asks for before you choose.
- **The night before:** no new material. Read the cram sheet once and sleep.
