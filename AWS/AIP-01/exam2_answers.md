# AWS AIP-C01 Practice Exam 2 — Answers and Explanations

> **Study guide:** 75 questions · 15 multiple-answer questions
>
> Correct choices are marked with **✅ Correct**. Open each question to review its choices and explanations.

---

<details>
<summary><strong>Question 1</strong> — Answer: <strong>C</strong></summary>

### Question 1

A pharmaceutical clinical operations team is preparing a generative AI assistant for regulated trial-document review. The assistant uses Amazon Bedrock for inference, SageMaker AI jobs for evaluation reports, and AWS Glue pipelines to prepare indexed document metadata. Auditors require a repeatable compliance evidence framework that records intended use and risk for each model release, preserves evaluation evidence, attributes outputs to governed data sources, and captures runtime model interaction evidence for supported Bedrock calls. The team wants to automate evidence collection without treating any single artifact as a legal compliance attestation.<br>Which implementation will BEST meet these requirements?

> **Answer:** C

#### A. Set SageMaker Model Cards to Approved for each release, store evaluation reports only as S3 objects, run AWS Glue crawlers for schema cataloging, and rely on default Bedrock invocation logging.

❌ Incorrect

> **Explanation:** Approved is a valid model-card status, but approving a model card does not make it a legal compliance attestation by itself. Storing reports only as standalone S3 objects and relying on default Bedrock invocation logging leaves gaps because model-card evidence should reference the reports and invocation logging is disabled by default.

#### B. Create SageMaker Model Cards with an Approved status, store source attribution only in card custom fields, use AWS Glue crawlers for schema snapshots, and use CloudTrail as the decision log.

❌ Incorrect

> **Explanation:** Approved is a valid model-card status, and custom fields can add useful governance context. However, using only model-card custom fields and schema snapshots is weaker than maintaining governed Data Catalog lineage, and CloudTrail does not replace Bedrock model invocation logging for model input, output, and invocation metadata.

#### C. Create SageMaker Model Cards with schema-valid JSON, link evaluation reports from S3, maintain AWS Glue Data Catalog lineage metadata, and enable Bedrock model invocation logging for supported runtime calls.

✅ **Correct**

> **Explanation:** This approach combines model governance, evaluation evidence, data provenance, and runtime decision logging without overstating what any one service provides. SageMaker Model Cards document governance details, AWS Glue Data Catalog supports metadata and lineage, and Bedrock invocation logging captures supported runtime interactions when enabled.

#### D. Export SageMaker Model Cards to PDF after each deployment, tag S3 documents with source owners, update Glue ETL jobs without catalog metadata, and use CloudTrail only for Bedrock auditing.

❌ Incorrect

> **Explanation:** PDF exports and S3 object tags can support review and attribution workflows, but they are not a substitute for versioned model-card content and Data Catalog lineage metadata. CloudTrail is useful for auditing API activity, but it does not capture the runtime model interaction evidence provided by Bedrock model invocation logging.

</details>

---

<details>
<summary><strong>Question 2</strong> — Answer: <strong>B</strong></summary>

### Question 2

A precision agriculture startup&#x27;s platform team is exposing existing diagnostic tools to autonomous agents by using Amazon Bedrock AgentCore Gateway. The tools are implemented in one shared AWS Lambda function, which currently dispatches to internal handlers by unprefixed names such as getSoilStatus and scheduleIrrigation. The team wants the tools to be MCP-compatible through Gateway, keep the existing handler names, and add defensive parameter validation in the Lambda code.<br>Which implementation will meet these requirements with the least custom integration code?

> **Answer:** B

#### A. Create an AgentCore Gateway Lambda target with the Lambda ARN and outputSchema definitions for each tool. In the Lambda dispatcher, read tool arguments from the context metadata and route directly by bedrockAgentCoreToolName.

❌ Incorrect

> **Explanation:** Incorrect. A Lambda tool definition requires name, description, and inputSchema, while outputSchema is optional. Tool arguments are delivered in the Lambda event object, and bedrockAgentCoreToolName can include the Gateway target-name prefix that would not match existing unprefixed handlers.

#### B. Create an AgentCore Gateway Lambda target with the Lambda ARN and a toolSchema that defines each tool. In the Lambda dispatcher, validate the event fields from each inputSchema and strip the Gateway target-name prefix from bedrockAgentCoreToolName before selecting the handler.

✅ **Correct**

> **Explanation:** Correct. AgentCore Gateway Lambda targets are designed to expose Lambda-backed tools through Gateway endpoints, and the Lambda event contains the inputSchema properties as values. Gateway-visible tool names are prefixed with the target name, so stripping that prefix lets the shared Lambda preserve its existing unprefixed handler dispatch.

#### C. Create an AgentCore Gateway OpenAPI target from a Swagger 2.0 document that describes the Lambda operations. In the Lambda dispatcher, map operationId values to handlers and validate request bodies after invocation.

❌ Incorrect

> **Explanation:** Incorrect. AgentCore Gateway OpenAPI targets support OpenAPI 3.0 and 3.1, not Swagger 2.0. OpenAPI operationId values are used as MCP tool names for OpenAPI targets, but this approach does not use the documented Lambda target configuration for exposing the existing Lambda directly.

#### D. Create an AgentCore Gateway Lambda target with the Lambda ARN and a toolSchema that defines each tool. In the Lambda dispatcher, validate the event fields and route directly by bedrockAgentCoreToolName after registering handlers with Gateway-visible names.

❌ Incorrect

> **Explanation:** Incorrect. This uses the correct Gateway target family and validates the event payload, but it couples the Lambda dispatcher to Gateway-visible prefixed names. The requirement is to keep the existing unprefixed handler names, so the dispatcher must account for the prefix rather than require handler registration by prefixed names.

</details>

---

<details>
<summary><strong>Question 3</strong> — Answer: <strong>C</strong></summary>

### Question 3

An online education platform&#x27;s tutoring team runs a browser-based writing coach. The current API Gateway REST API invokes an AWS Lambda function that calls Amazon Bedrock synchronously, so students wait until the full answer is generated before seeing any feedback. The browser client already supports server-sent events, and the team must preserve the REST API contract without moving to a WebSocket protocol. The solution must reduce time to first byte and stream partial model output as it is generated.<br>Which implementation will meet these requirements?

> **Answer:** C

#### A. Configure an API Gateway REST API AWS_PROXY Lambda integration in BUFFERED mode with the standard Lambda invocation URI. Have Lambda call Bedrock ConverseStream and return one SSE-formatted response.

❌ Incorrect

> **Explanation:** Incorrect. BUFFERED mode causes API Gateway to wait for the complete integration response before sending data to the client, which does not reduce time to first byte. Calling ConverseStream inside Lambda does not help if the function concatenates the stream and returns the complete response at the end.

#### B. Configure an API Gateway REST API non-proxy HTTP integration in STREAM mode with VTL response templates. Have API Gateway convert Bedrock event-stream chunks into SSE frames.

❌ Incorrect

> **Explanation:** Incorrect. API Gateway REST API response streaming works only with HTTP_PROXY or AWS_PROXY integrations, not a non-proxy HTTP integration. STREAM mode also does not support response features that require full-response buffering, including VTL response transformation.

#### C. Configure an API Gateway REST API AWS_PROXY Lambda integration in STREAM mode with the /response-streaming-invocations URI. Have Lambda call Bedrock ConverseStream and write SSE frames as deltas arrive.

✅ **Correct**

> **Explanation:** Correct. API Gateway REST API response streaming supports STREAM mode with AWS_PROXY integrations, and Lambda proxy response streaming uses the Lambda InvokeWithResponseStream path ending in /response-streaming-invocations. Bedrock ConverseStream returns incremental response events, which the Lambda function can translate into server-sent event frames for the existing REST client.

#### D. Configure an API Gateway REST API AWS_PROXY Lambda integration in STREAM mode with the standard Lambda invocation URI. Have Lambda call Bedrock ConverseStream and write SSE frames as deltas arrive.

❌ Incorrect

> **Explanation:** Incorrect. STREAM mode is the right response transfer mode for REST API response streaming, and AWS_PROXY is a supported integration type. However, Lambda proxy response streaming requires the Lambda integration URI that ends in /response-streaming-invocations, not the standard Lambda invocation URI.

</details>

---

<details>
<summary><strong>Question 4</strong> — Answer: <strong>A</strong></summary>

### Question 4

A global airline&#x27;s disruption-management team is building a generative AI service that classifies passenger messages and generates responses by using several Amazon Bedrock foundation models. Simple itinerary questions should use a low-cost model, policy disputes should use a model tuned for reasoning, and multilingual rebooking requests should use a model with stronger language support. Existing clients send only free-form text, locale, and account tier, and the team does not want clients to choose models. The solution must keep an auditable routing path, allow routing rules to change without redeploying clients, and invoke only one generation model for each request to control cost.<br>Which implementation will meet these requirements?

> **Answer:** A

#### A. Use API Gateway to validate requests and start a Step Functions workflow. Run a lightweight classification step, use Choice states for routing, and invoke the selected Bedrock model from a Lambda task.

✅ **Correct**

> **Explanation:** This approach centralizes model selection behind the API and bases routing on request content rather than client choice. Step Functions provides visible execution history and Choice states, while invoking only the selected model controls generation cost.

#### B. Use API Gateway to validate requests and invoke a Lambda function. Evaluate routing rules in Lambda from the message text, select a Bedrock model, and emit routing metrics to CloudWatch.

❌ Incorrect

> **Explanation:** This approach can keep model selection server-side and can invoke only one model, so it is a plausible design. However, a Lambda-only rules engine provides less explicit workflow-level auditability than Step Functions execution history and makes branching behavior harder to inspect and govern.

#### C. Use API Gateway to start a Step Functions workflow. Route with Choice states based on locale and account tier, and invoke the mapped Bedrock model from a Lambda task.

❌ Incorrect

> **Explanation:** This approach uses the right workflow service and can preserve an execution history while invoking a single model. It does not reliably classify the free-form message content, so it can misroute policy disputes and itinerary questions that share the same locale or account tier.

#### D. Use Amazon Bedrock prompt routing as the primary selector. Configure supported model choices for cost and capability tradeoffs, and send each airline message through one shared generation prompt.

❌ Incorrect

> **Explanation:** This approach can help optimize model selection when the supported routing behavior matches the workload. It is weaker for explicit airline business categories because it does not give the same application-controlled classification step and branch-level audit trail required for policy, itinerary, and rebooking decisions.

</details>

---

<details>
<summary><strong>Question 5</strong> — Answer: <strong>A, C</strong></summary>

### Question 5

A regional court system&#x27;s case-access technology team is building a generative AI assistant on Amazon Bedrock. The assistant answers questions from public court procedure documents by using an Amazon Bedrock Knowledge Base, and it uses an Amazon Bedrock agent for multi-step internal workflows that can call action groups. The compliance team requires user-facing evidence for generated answers and an auditable record of how each agent request selected knowledge bases, action groups, and follow-up steps. The solution must not depend on undocumented model confidence scores or assume that provider-internal reasoning is always available.<br>Which TWO actions should the team implement to meet these transparency requirements? (Select TWO.)

> **Answer:** A, C

#### A. Invoke the Bedrock agent with enableTrace set to true and persist trace events for audit review of orchestration steps and failures.

✅ **Correct**

> **Explanation:** Correct. The InvokeAgent API supports request-controlled tracing by setting enableTrace to true. Agent traces provide visibility into orchestration, action group interactions, knowledge base activity, reasoning used for those steps, and failure reasons.

#### B. Capture reasoningContent from supported Converse responses as supplemental debugging metadata and use reasoningText in place of citations and agent traces when present.

❌ Incorrect

> **Explanation:** Incorrect. reasoningContent is available through supported Converse and ConverseStream content blocks, and providers can return redactedContent instead of visible reasoning text. It can be useful as supplemental metadata when available, but it cannot replace source citations for evidence or agent trace records for workflow auditability.

#### C. Return the RetrieveAndGenerate citation spans and retrieved references with each answer so users can inspect supporting document content and locations.

✅ **Correct**

> **Explanation:** Correct. Amazon Bedrock Knowledge Bases can return generated responses with citations that associate answer spans with retrieved references. Those references can include source content, metadata, and document location information, which supports user-facing source attribution.

#### D. Use AWS/Bedrock runtime metrics in CloudWatch as per-response confidence and uncertainty scores, and display them with generated answers.

❌ Incorrect

> **Explanation:** Incorrect. The documented Bedrock runtime metrics in CloudWatch are operational metrics such as invocations, latency, errors, throttling, token counts, and prompt-cache metrics. They are not generic per-response model confidence, uncertainty, or faithfulness scores.

#### E. Configure Guardrails Automated Reasoning checks to block invalid generations and evaluate retrieved Knowledge Base references before the response is returned.

❌ Incorrect

> **Explanation:** Incorrect. Automated Reasoning checks operate as a validation layer that returns findings and feedback, not as a general-purpose blocking mechanism. Guardrails for Knowledge Bases are applied to the input and generated LLM response, not to retrieved references.

</details>

---

<details>
<summary><strong>Question 6</strong> — Answer: <strong>C</strong></summary>

### Question 6

An industrial robotics manufacturer&#x27;s GenAI platform team is building a RAG retrieval layer for maintenance manuals, safety notices, parts catalogs, and warranty procedures. The team will use managed Amazon OpenSearch Service as the vector database. Each corpus has different terminology, receives large nightly document revisions, and may need different embedding settings. The application uses pure semantic search with a moderate latency target, must return the top 20 matches for each query across the whole corpus, and must avoid a large reindexing effort after launch.<br>Which indexing and query design will best meet these requirements?

> **Answer:** C

#### A. Create one k-NN enabled index per domain, allocate many small 10-30 GiB shards to maximize fan-out, store embeddings in dimensioned knn_vector fields, route by domain metadata, and set k to 20 without size.

❌ Incorrect

> **Explanation:** The multi-index and knn_vector choices are directionally reasonable, but creating many small shards is not the best fit for a workload with large nightly revisions and can increase CPU and memory pressure. The query also does not set size, so it does not ensure the intended number of final results for the overall query.

#### B. Create one k-NN enabled index for all domains, accept the managed service default shard layout, store the domain in metadata, use filtered vector queries, and set k to 20 without overriding size in k-NN queries.

❌ Incorrect

> **Explanation:** A single shared index limits the team&#x27;s ability to use different domain-specific tuning and can make shard planning harder for corpora that grow differently. Setting only k is not sufficient to control the final top 20 result set for a distributed k-NN query because the query should also set size for the desired overall hits.

#### C. Create one k-NN enabled index per domain, decide primary shard counts before ingestion to keep shards near 30-50 GiB, store embeddings in dimensioned knn_vector fields, fan out to every domain index, and globally merge the top 20 matches.

✅ **Correct**

> **Explanation:** This design separates specialized domains so each index can be tuned independently while still searching the whole corpus for each request. It also plans primary shards before ingestion, uses the required OpenSearch k-NN index and field configuration, and uses a global merge so the final answer is the top 20 across domains.

#### D. Create one index per domain after ingestion completes, resize primary shards as each domain grows, store embeddings as numeric arrays, route through aliases, and use standard search requests to return the top 20 vector matches.

❌ Incorrect

> **Explanation:** Primary shard count should be planned before data is indexed because it is not easy to change afterward without disruptive work. Storing embeddings as ordinary numeric arrays does not configure the managed OpenSearch k-NN path, which requires a knn_vector field in a k-NN enabled index.

</details>

---

<details>
<summary><strong>Question 7</strong> — Answer: <strong>B</strong></summary>

### Question 7

A medical imaging equipment manufacturer&#x27;s service AI team is extending an FM-based troubleshooting assistant with MCP tools. The team will deploy the MCP server to Amazon Bedrock AgentCore Runtime. One tool runs multi-step calibration simulations that can emit progress updates and can request missing parameter values during the same tool interaction. The team wants client integrations to remain portable across local testing and remote runtime invocation.<br>Which implementation approach will meet these requirements?

> **Answer:** B

#### A. Deploy a streamable-HTTP MCP server container to AgentCore Runtime, keep default stateless MCP handling, listen on 0.0.0.0:8000/mcp, and reuse Mcp-Session-Id values.

❌ Incorrect

> **Explanation:** Incorrect. Stateless MCP is the documented default and is recommended for basic servers, but it is not appropriate for capabilities that require retained MCP session state. Reusing or receiving an Mcp-Session-Id helps continuity to the same runtime session, but it does not make stateless mode suitable for elicitation or progress notifications.

#### B. Deploy a streamable-HTTP MCP server container to AgentCore Runtime, configure stateful MCP handling, listen on 0.0.0.0:8000/mcp, and use the official mcp client session.

✅ **Correct**

> **Explanation:** Correct. The tool requires retained MCP session state because it uses progress notifications and multi-turn elicitation, so stateful MCP handling is appropriate. AgentCore Runtime expects MCP server containers to listen on 0.0.0.0:8000/mcp, and the documented client pattern uses the official mcp package with a ClientSession.

#### C. Deploy a streamable-HTTP MCP server container to AgentCore Runtime, configure stateful MCP handling, listen on 0.0.0.0:8000/mcp, and require Accept: application/x-ndjson.

❌ Incorrect

> **Explanation:** Incorrect. The server mode and runtime listening path align with the stateful MCP requirement. However, AWS notes that any Accept header used for remote AgentCore Runtime invocation must follow the MCP standard, such as application/json or text/event-stream.

#### D. Deploy a streamable-HTTP MCP server container to AgentCore Runtime, configure stateful MCP handling, listen on 0.0.0.0:8000/tools, and route MCP calls through a proxy.

❌ Incorrect

> **Explanation:** Incorrect. Stateful MCP handling matches the tool behavior, but the endpoint path does not match the AgentCore Runtime requirement for MCP server containers. Runtime expects the server to listen at 0.0.0.0:8000/mcp when configured with the MCP protocol.

</details>

---

<details>
<summary><strong>Question 8</strong> — Answer: <strong>B</strong></summary>

### Question 8

An online learning platform&#x27;s tutoring engineering team is building autonomous tutor agents with Strands Agents and Amazon Bedrock AgentCore Memory. The tutors must keep the problem-solving context separate for each active browser tab, learn each learner&#x27;s preferred explanation style for future sessions, and reduce memory write overhead by buffering multiple messages. Some tutoring chats end after only one or two turns, before the configured batch threshold is reached.<br>Which implementation will meet these requirements with the LEAST custom code while avoiding loss of state?

> **Answer:** B

#### A. Configure an AgentCore Memory resource with no long-term memory strategies, store USER and ASSISTANT turns with actorId and per-chat sessionId values, and close the Strands memory session after each chat.

❌ Incorrect

> **Explanation:** This preserves short-term events for a session and handles the Strands buffering concern. However, AgentCore Memory does not extract long-term memory records unless memory strategies are configured, so learner preferences would not be generated for future sessions.

#### B. Configure an AgentCore Memory user preference strategy, store USER and ASSISTANT turns with actorId and per-chat sessionId values, and close the Strands memory session after each chat.

✅ **Correct**

> **Explanation:** This is correct because the user preference strategy extracts durable preferences across sessions, while events grouped by actorId and sessionId preserve short-term conversational context. Closing the Strands memory session, or using a context manager, flushes buffered messages that have not reached the batch threshold.

#### C. Configure an AgentCore Memory user preference strategy, store USER and ASSISTANT turns with actorId and one persistent sessionId per learner, and rely on batch_size to flush messages automatically.

❌ Incorrect

> **Explanation:** The user preference strategy is appropriate for learning explanation style, but one persistent sessionId per learner does not keep active browser-tab context separated as distinct continuous interactions. Relying only on the batch threshold can lose buffered messages when a chat ends before the threshold is reached.

#### D. Configure an AgentCore Memory semantic strategy, store OTHER summaries with actorId and per-chat sessionId values, and close the Strands memory session after each chat.

❌ Incorrect

> **Explanation:** Closing the session addresses the buffered-message issue, and per-chat sessionId values can separate active interactions. However, the documented semantic and user preference strategies process USER and ASSISTANT role messages, and semantic memory is oriented toward factual context rather than user preference extraction.

</details>

---

<details>
<summary><strong>Question 9</strong> — Answer: <strong>C</strong></summary>

### Question 9

An airline loyalty program&#x27;s contact-center AI team wants to decide whether to replace an existing non-Bedrock answer generator with an Amazon Bedrock model. The team has prepared 750 representative customer prompts in Amazon S3. For each prompt, the dataset includes the existing system&#x27;s response with modelIdentifier set to legacy-assistant-v1. The team has 45 senior agents who must independently rate the legacy response and the candidate model response for helpfulness and preference. At least three agents should review each prompt, and the team wants an AWS-managed workflow with results stored in S3 for later analysis.<br>Which approach meets these requirements with the least custom development?

> **Answer:** C

#### A. Create an Amazon Bedrock human-based model evaluation job with the candidate model, the legacy response source, and a control response source. Use the S3 prompt dataset and an S3 output location, choose a comparison rank method, and set three workers per prompt.

❌ Incorrect

> **Explanation:** Human-based model evaluation jobs support evaluating up to two inference sources. Adding a third response source exceeds that documented limit, even though a comparison ranking style can be a valid human rating method.

#### B. Create an Amazon Bedrock human-based model evaluation job with the candidate model and a bring-your-own response source named production-baseline. Use the S3 prompt dataset and an S3 output location, choose a comparison rating method, and set three workers per prompt.

❌ Incorrect

> **Explanation:** Human-based evaluation is the right evaluation type, but the bring-your-own response source name must match the modelIdentifier in the prompt dataset. Using a different source name would not correctly identify the existing system&#x27;s responses for the evaluation job.

#### C. Create an Amazon Bedrock human-based model evaluation job with the candidate model and a bring-your-own response source named legacy-assistant-v1. Use the S3 prompt dataset and an S3 output location, choose a comparison rating method, and set three workers per prompt.

✅ **Correct**

> **Explanation:** This meets the requirement to collect structured ratings and preferences from human reviewers without building a custom annotation workflow. The bring-your-own response source name matches the modelIdentifier in the dataset, the prompt count is within the documented custom dataset limit, and three workers per prompt provides independent reviews.

#### D. Create an Amazon Bedrock automatic model evaluation job with the candidate model and a bring-your-own response source named legacy-assistant-v1. Use the S3 prompt dataset and an S3 output location, choose a quality metric, and review the computed scores.

❌ Incorrect

> **Explanation:** Automatic evaluations produce computed metrics, but they do not collect ratings and preferences from the senior agents. This approach would not satisfy the requirement for independent human review of each prompt.

</details>

---

<details>
<summary><strong>Question 10</strong> — Answer: <strong>D</strong></summary>

### Question 10

A university admissions office&#x27;s AI platform team is standardizing retrieval access for several admissions assistants. The team uses Amazon Bedrock Managed Knowledge Bases as the retrieval source. Some assistants are MCP-compatible agents, while other assistants use Amazon Bedrock chat-style model integrations. The platform must provide a consistent retrieval tool interface, prevent application developers from passing knowledge base identifiers at runtime, and support both single-pass retrieval and multi-step retrieval for complex questions with minimal custom code.<br>Which implementation will best meet these requirements?

> **Answer:** D

#### A. Create Converse API tool definitions for the retrieval operations, mirror the MCP-visible tool names in toolConfig, and have the model execute the retrieval calls directly.

❌ Incorrect

> **Explanation:** This is incorrect because the common Bedrock tool-use pattern has the model request tool use, while application code executes the tool and returns a toolResult. Converse tool names also have documented length and character constraints, so directly mirroring MCP-visible names can create schema compatibility issues.

#### B. Create a Lambda-backed MCP gateway that calls Retrieve for every query, bind the managed knowledge base mapping in Lambda configuration, and rely on knowledge base guardrails for retrieved references.

❌ Incorrect

> **Explanation:** This is incorrect because Retrieve is a single retrieval API and does not provide the multi-step agentic retrieval behavior required for complex questions. Knowledge base guardrails apply to the input and generated response, but they do not filter retrieved references at runtime.

#### C. Create a custom MCP server that wraps RetrieveAndGenerate, bind the managed knowledge base mapping in server configuration, and route every request through one retrieval-and-generation operation.

❌ Incorrect

> **Explanation:** This is incorrect because RetrieveAndGenerate combines retrieval with model invocation and citations instead of exposing separate tools for source retrieval and agentic multi-step retrieval. A custom wrapper also adds maintenance and session-handling logic, including reusing the service-generated session ID for later turns.

#### D. Create an Amazon Bedrock AgentCore Gateway target with the managed knowledge base connector, bind the managed knowledge base and retrieval settings to the target, and have clients invoke the target-prefixed Retrieve and AgenticRetrieveStream tools.

✅ **Correct**

> **Explanation:** This is correct because the AgentCore Gateway managed knowledge base connector exposes MCP tools for Retrieve and AgenticRetrieveStream. The managed knowledge base identifier and retrieval settings are bound to the Gateway target, so clients do not normally pass the knowledge base ID at runtime.

</details>

---

<details>
<summary><strong>Question 11</strong> — Answer: <strong>C</strong></summary>

### Question 11

A museum consortium&#x27;s digital preservation team is building a RAG application with Amazon Bedrock Knowledge Bases. The team will use a customer-managed vector store because it must control vector index mappings. The embedding configuration stores binary vector embeddings to reduce storage footprint. The team wants the lowest operational burden while allowing Bedrock to ingest, index, and retrieve content from the vector store.<br>Which configuration will meet these requirements?

> **Answer:** C

#### A. Create an Amazon OpenSearch Managed cluster with public access and a k-NN index that uses the nmslib engine with vector, text, and metadata fields.

❌ Incorrect

> **Explanation:** OpenSearch Managed clusters can be used with Bedrock Knowledge Bases when the documented requirements are met. However, Bedrock&#x27;s OpenSearch Managed setup must use the faiss engine, and nmslib is not supported for this integration.

#### B. Create an Amazon OpenSearch Managed cluster in VPC-only mode with engine version 2.16 and a faiss k-NN index that stores binary vectors.

❌ Incorrect

> **Explanation:** OpenSearch Managed clusters require engine version 2.16 or later for binary vector embeddings, and faiss is the supported engine for Bedrock Knowledge Bases. However, Bedrock Knowledge Bases do not support VPC-only OpenSearch Managed domains, so this configuration is not valid.

#### C. Create an Amazon OpenSearch Serverless vector collection with a faiss vector index that defines the vector, text, and metadata fields and matches the embedding dimensions.

✅ **Correct**

> **Explanation:** This configuration supports binary vector embeddings for Bedrock Knowledge Bases and avoids managing OpenSearch cluster capacity. Bedrock requires the OpenSearch Serverless vector index mapping to expose a vector field, raw text field, and metadata field with dimensions that match the embedding model.

#### D. Create an Amazon Aurora PostgreSQL database with pgvector tables that store binary embeddings, document text, and metadata fields and configure Bedrock to use the tables.

❌ Incorrect

> **Explanation:** Aurora with pgvector can be used as a vector store for Bedrock Knowledge Bases, but the documented binary-vector support for Bedrock Knowledge Bases is limited to OpenSearch Serverless and OpenSearch Managed clusters. This choice does not satisfy the stated binary embedding requirement.

</details>

---

<details>
<summary><strong>Question 12</strong> — Answer: <strong>B</strong></summary>

### Question 12

A renewable energy grid operator&#x27;s GenAI enablement team uses Amazon Bedrock Prompt management for an incident-summary assistant. After several manual prompt edits, the team sees semantic drift and inconsistent output style across edge-case tickets. The team has 75 curated evaluation samples with expected behavior and wants an evaluation-driven way to refine one prompt template across three candidate models before promoting a production snapshot. The team must avoid custom orchestration and must not rely only on heuristic rewrites.<br>Which approach best meets these requirements?

> **Answer:** B

#### A. Run simple prompt optimization for the draft prompt separately for each candidate model. Compare the rewritten prompts in Prompt builder, save the best variant as the draft, and use the draft in production.

❌ Incorrect

> **Explanation:** Simple prompt optimization is a fast heuristic rewrite for a single short prompt and one model, and it does not use evaluation data. It does not satisfy the need to use curated evaluation samples or systematically optimize across three candidate models.

#### B. Create an Advanced Prompt Optimization JSONL input file for the template with 75 evaluationSamples and three target models. Select one evaluation method, review the optimized result, and create a Prompt management version for production.

✅ **Correct**

> **Explanation:** This approach matches the requirement for evaluation-driven refinement across multiple candidate models. Advanced Prompt Optimization supports up to five models per job and allows 1 to 100 evaluation samples per template, so the stated sample count and model count are within documented limits.

#### C. Create an automatic model evaluation job with a custom S3 JSONL prompt dataset. Put the three prompt templates in the dataset, compare the model report scores, and deploy the highest-scoring template.

❌ Incorrect

> **Explanation:** Automatic model evaluation jobs require prompt datasets and can report metrics for retrieved model responses. They are designed to evaluate model outputs against prompts, not to optimize prompt templates and return refined prompt candidates across multiple target models.

#### D. Use Prompt builder Compare variants mode with three variants and temporary test variables. Run each variant in the console, save the preferred variant as the draft, and use the draft in production.

❌ Incorrect

> **Explanation:** Compare variants is useful for interactive testing, and it can compare up to three variants in the console. However, test variable values are temporary, and saving a variant as the draft is not the same as running an evaluation-driven optimization workflow or creating a production version.

</details>

---

<details>
<summary><strong>Question 13</strong> — Answer: <strong>A</strong></summary>

### Question 13

An industrial robotics vendor&#x27;s field-service AI team runs a RAG assistant on Amazon Bedrock Knowledge Bases. The knowledge base is a custom knowledge base backed by Amazon OpenSearch Serverless, and the vector index stores each chunk&#x27;s raw text in a filterable text field. Technicians search by using both natural-language symptoms and exact robot model numbers or error codes. API profiling shows that semantic retrieval often misses chunks that contain exact codes, and relevant chunks are sometimes ranked below less useful chunks. The team wants to improve relevance from Retrieve and RetrieveAndGenerate requests without replacing the vector store or building a custom retrieval service.<br>Which retrieval configuration should the team use?

> **Answer:** A

#### A. Configure retrievalConfiguration.vectorSearchConfiguration with overrideSearchType HYBRID, set numberOfResults to a larger supported value, and add rerankingConfiguration with BEDROCK_RERANKING_MODEL and an appropriate numberOfRerankedResults.

✅ **Correct**

> **Explanation:** Correct. The knowledge base uses a supported vector store for hybrid search and has a filterable text field, so HYBRID can combine vector similarity with raw-text matching for exact codes. Bedrock Knowledge Bases reranking can then reorder the retrieved chunks by using a Bedrock reranking model, which addresses the ranking problem without a custom retriever.

#### B. Configure retrievalConfiguration.vectorSearchConfiguration with overrideSearchType HYBRID, set numberOfResults to a larger supported value, and add a metadata filter for model and error-code attributes instead of rerankingConfiguration.

❌ Incorrect

> **Explanation:** Incorrect. A metadata filter can narrow retrieval when the application has structured metadata fields to filter on, but the scenario only states that each chunk&#x27;s raw text is available as a filterable text field. This approach also omits reranking, so it does not address relevant chunks being ordered below less useful chunks.

#### C. Configure retrievalConfiguration.vectorSearchConfiguration with overrideSearchType HYBRID, keep numberOfResults at the default result count, and attach guardrails to filter irrelevant retrieved references before response generation.

❌ Incorrect

> **Explanation:** Incorrect. HYBRID is appropriate for the exact-code retrieval issue, but leaving the default result count can limit the candidate set when more source chunks need to be considered. Guardrails do not apply to the source chunks retrieved from Knowledge Bases, so they are not a mechanism for filtering irrelevant references.

#### D. Configure retrievalConfiguration.vectorSearchConfiguration with overrideSearchType SEMANTIC, set numberOfResults to a larger supported value, and add rerankingConfiguration with BEDROCK_RERANKING_MODEL and an appropriate numberOfRerankedResults.

❌ Incorrect

> **Explanation:** Incorrect. SEMANTIC uses vector embeddings only, so it does not add raw-text matching for exact model numbers or error codes. Reranking can improve ordering of retrieved chunks, but it cannot rerank chunks that were not retrieved in the first place.

</details>

---

<details>
<summary><strong>Question 14</strong> — Answer: <strong>A</strong></summary>

### Question 14

A pharmaceutical clinical operations platform ingests partner trial-site notes as JSON into Amazon S3, normalizes them, and then creates embeddings for an Amazon Bedrock RAG application. The incoming JSON contains nested structs and lists, and the team must quarantine records that fail completeness and uniqueness checks before the curated dataset is loaded for embedding. The workflow must publish rule pass and fail counts to Amazon CloudWatch for alarms and minimize custom validation code.<br>Which validation design best meets these requirements?

> **Answer:** A

#### A. Build an AWS Glue ETL validation stage that flattens nested fields, uses EvaluateDataQuality.processRows or Glue Studio row-level output with case-sensitive DQDL, enables CloudWatch metrics, and splits pass and fail records for curated and quarantine writes.

✅ **Correct**

> **Explanation:** This design uses the AWS Glue ETL job entry point, which is appropriate for validating and filtering data before it is loaded for downstream FM consumption. It also accounts for nested data preparation, DQDL case sensitivity, row-level quarantine, and the need to explicitly enable CloudWatch metrics publishing.

#### B. Build an AWS Glue ETL validation stage that reads the raw nested JSON, runs EvaluateDataQuality with a lowercase dqdl rules list, leaves default publishing options unchanged, and writes records with failed row percentages to quarantine.

❌ Incorrect

> **Explanation:** DQDL documents are case sensitive and require a capitalized Rules list and case-sensitive rule names such as IsComplete and IsUnique. CloudWatch metrics publishing is disabled by default for EvaluateDataQuality, so leaving the defaults unchanged does not satisfy the monitoring requirement.

#### C. Configure AWS Glue Data Quality in the Data Catalog after the ETL job writes the curated table, generate recommended completeness and uniqueness rules, enable scheduled evaluations, and quarantine records by interpreting failed-rule results.

❌ Incorrect

> **Explanation:** Running Data Catalog evaluations after the curated table is written does not validate and filter records before the embedding dataset is loaded. Data Catalog evaluations also do not provide the failed-record identification capability needed for an automated quarantine workflow.

#### D. Configure AWS Glue Data Quality in the Data Catalog on the raw JSON table, generate recommended rules for completeness and uniqueness, publish the catalog run results, and use the resulting score to quarantine failing records before embedding.

❌ Incorrect

> **Explanation:** The Data Catalog entry point is useful for evaluating cataloged datasets and can recommend rules, but it is not the right path for identifying failed records in an ETL flow. The data quality score is the percentage of rules that pass, not a row-level pass percentage for quarantine decisions.

</details>

---

<details>
<summary><strong>Question 15</strong> — Answer: <strong>B</strong></summary>

### Question 15

A university library consortium is building semantic search for scanned policy documents that have already been converted to cleaned text. A Lambda ingestion pipeline reads SQS message batches, splits text into document sections, and writes embeddings to a vector index. The production index is being created from the prototype with the same HNSW parameters and metadata schema, but the team can choose the vector dimension before first ingestion. The offline tests used the index&#x27;s standard floating-point vector representation, and the launch window does not allow another relevance test or index rebuild after ingestion starts. The sections are all below 50,000 characters and below 8,192 tokens. The prototype used Amazon Titan Text Embeddings V2 default output dimensions. Offline testing produced these results relative to the prototype: 1,024 dimensions, nDCG@10 of 0.846 and 100% vector footprint; 512 dimensions, nDCG@10 of 0.845 and 50% vector footprint; 256 dimensions, nDCG@10 of 0.842 and 25% vector footprint. Production must meet nDCG@10 of at least 0.840, reduce vector storage footprint by at least 70%, and preserve section-level retrieval granularity and the Bedrock API based ingestion flow.<br>Which approach should the team use?

> **Answer:** B

#### A. Configure Lambda ingestion workers to invoke amazon.titan-embed-text-v2:0 for each validated section and apply half-precision quantization to 512-dimensional embeddings before writing vectors.

❌ Incorrect

> **Explanation:** This is a plausible storage optimization because it preserves the section boundary and uses a supported Titan Text Embeddings V2 dimensionality. However, the offline test did not validate half-precision quantized vectors, so it adds relevance and index-compatibility risk during a launch window that does not allow another evaluation cycle.

#### B. Configure Lambda ingestion workers to invoke amazon.titan-embed-text-v2:0 for each validated section and request 256-dimensional floating-point embeddings before writing vectors.

✅ **Correct**

> **Explanation:** This uses Amazon Titan Text Embeddings V2 with a supported output size that satisfies the measured relevance threshold and the storage reduction target. The approach also keeps the tested vector representation, section-level retrieval, and the existing Lambda-to-Bedrock ingestion pattern intact.

#### C. Configure Lambda ingestion workers to invoke amazon.titan-embed-text-v2:0 for each validated section and convert default-dimensional embeddings to binary vectors before writing vectors.

❌ Incorrect

> **Explanation:** This keeps the same model and document granularity while attempting to reduce storage through representation changes. However, the tested default-dimensional result used the prototype&#x27;s floating-point representation, and changing to binary vectors would require validation before relying on the measured relevance result.

#### D. Configure Lambda ingestion workers to invoke amazon.titan-embed-text-v2:0 for each validated section and convert 512-dimensional embeddings to binary vectors before writing vectors.

❌ Incorrect

> **Explanation:** This preserves section-level ingestion and could appear attractive because binary vectors can reduce storage footprint. However, it introduces an untested vector representation, so the measured nDCG@10 result for 512-dimensional floating-point vectors cannot be assumed to apply.

</details>

---

<details>
<summary><strong>Question 16</strong> — Answer: <strong>B</strong></summary>

### Question 16

A national tax advisory firm&#x27;s digital products team is building a proof of concept for an Amazon Bedrock based assistant that answers questions about internal tax research notes. The team has three prompt variants, two foundation models, and a representative dataset of 400 SME-written questions with expected answers. The team must decide whether the assistant is feasible before any production integration, and must compare quality, latency, and cost with minimal custom evaluation infrastructure.<br>Which approach will BEST meet these requirements?

> **Answer:** B

#### A. Deploy each prompt variant behind an Amazon API Gateway endpoint that invokes Amazon Bedrock. Route employees to the endpoints and compare thumbs-up feedback after a pilot period.

❌ Incorrect

> **Explanation:** This approach can collect useful business feedback, but it requires deploying user-facing endpoints before the feasibility decision. It also depends on production-like traffic and does not use the existing SME-labeled dataset as the primary repeatable evaluation mechanism.

#### B. Create managed Amazon Bedrock evaluation jobs for the candidate models and prompt variants by using the SME dataset. Review the evaluation results and invocation characteristics before selecting a configuration.

✅ **Correct**

> **Explanation:** This approach uses a managed evaluation workflow to compare candidate model and prompt configurations before production integration. It aligns with the need to validate quality and operational characteristics while avoiding a custom evaluation platform.

#### C. Build an AWS Step Functions workflow that invokes Amazon Bedrock for every dataset item. Store outputs in Amazon S3 and ask SMEs to manually score every generated answer.

❌ Incorrect

> **Explanation:** This approach can produce comparison data, but it adds custom orchestration, storage, and manual scoring work that the scenario is trying to minimize. It is less repeatable and more operationally intensive than using a managed Bedrock evaluation workflow.

#### D. Fine-tune one Amazon Bedrock supported model by using the SME dataset. Compare the fine-tuned model with a base model after deploying both through application endpoints.

❌ Incorrect

> **Explanation:** Fine-tuning is a customization step that is usually considered after simpler approaches such as prompt and model evaluation show enough value. This option also narrows the comparison too early and introduces deployment work before the proof of concept has established feasibility.

</details>

---

<details>
<summary><strong>Question 17</strong> — Answer: <strong>C</strong></summary>

### Question 17

A financial market data provider&#x27;s AI platform team manages Amazon Bedrock prompts that are used by multiple internal applications. Developers currently copy prompt text into application repositories, which has caused inconsistent behavior and unclear ownership of production changes. The team needs reusable parameterized templates, controlled promotion of prompt changes, a stable versioned production reference for each approved prompt, auditability for prompt resource changes, and application-emitted access logs for troubleshooting.<br>Which approach will meet these requirements with the MOST appropriate governance?

> **Answer:** C

#### A. Store prompt templates as encrypted S3 objects with object tags for environments. Load the latest approved object at application startup. Track S3 object reads with CloudTrail data events, and emit application request metadata to CloudWatch Logs.

❌ Incorrect

> **Explanation:** This approach can provide storage history and object-level auditing, but it does not use Bedrock prompt resources or managed prompt versions. Applications would still need custom template loading and parameter handling, which increases the chance of drift across teams.

#### B. Store each prompt template in AWS Secrets Manager with a separate secret for each environment. Rotate prompt secrets after approval, audit secret updates with CloudTrail, and emit application access metadata to CloudWatch Logs.

❌ Incorrect

> **Explanation:** Secrets Manager is designed for credentials and sensitive configuration, not for governing reusable prompt templates. Secret rotation is not an appropriate promotion model for prompt content and does not provide Bedrock-native prompt version references for production applications.

#### C. Create prompts in Amazon Bedrock Prompt Management with variables and versions. Store prompt source artifacts in a versioned S3 repository. Promote prompt versions through a manual deployment approval step, audit Bedrock API activity with CloudTrail, and write prompt access metadata from applications to CloudWatch Logs.

✅ **Correct**

> **Explanation:** This approach uses Bedrock Prompt Management for reusable parameterized prompts and versioned production snapshots. S3 versioning, an external approval step, CloudTrail, and application-emitted CloudWatch Logs provide source control, promotion control, auditability, and operational visibility without requiring each application to manage raw prompt text.

#### D. Define each prompt as an Amazon Bedrock Flow node with input variables. Store the Flow JSON definitions in S3. Promote Flow aliases after review, audit Flow API calls with CloudTrail, and emit orchestration logs to CloudWatch Logs.

❌ Incorrect

> **Explanation:** Bedrock Flows are useful for orchestrating multi-step generative AI workflows, including prompts, model calls, and conditions. Using a Flow for every reusable prompt adds unnecessary orchestration overhead and does not directly address centralized prompt template governance as cleanly as Prompt Management.

</details>

---

<details>
<summary><strong>Question 18</strong> — Answer: <strong>A, B</strong></summary>

### Question 18

A national retail bank&#x27;s digital servicing platform team is standardizing how internal applications interact with Amazon Bedrock models. The team needs one synchronous chat interface that can support multiple message-capable models while still allowing model-specific parameters when required. A second interface must support real-time streaming for selected models, but the implementation must avoid unsupported client tooling and must verify model capability before enabling streaming. The bank wants to use Bedrock-native inference endpoints rather than OpenAI-compatible compatibility APIs or provider-specific endpoint families.<br>Which combination of actions will meet these requirements? (Select TWO.)

> **Answer:** A, B

#### A. Build the synchronous chat interface with the AWS SDK by calling the Converse API on the regional bedrock-runtime endpoint, and pass model-specific parameters through additionalModelRequestFields when needed.

✅ **Correct**

> **Explanation:** This is correct because Converse provides a consistent synchronous messages interface for supported message-capable models. The API supports model-specific request fields through additionalModelRequestFields and uses the Bedrock runtime endpoint family for Bedrock-native inference.

#### B. Build the streaming interface with an AWS SDK by calling ConverseStream or InvokeModelWithResponseStream only after checking GetFoundationModel for responseStreamingSupported on the selected model.

✅ **Correct**

> **Explanation:** This is correct because streaming support is model-dependent in Amazon Bedrock. Checking the model metadata before enabling streaming prevents the integration layer from selecting a streaming operation for a model that does not support it.

#### C. Build the synchronous chat interface with the AWS SDK by calling Converse for supported message-capable models, and grant callers only bedrock:InvokeModelWithResponseStream permission.

❌ Incorrect

> **Explanation:** This is incorrect because Converse requires bedrock:InvokeModel permission for authorization. Granting only the streaming invocation permission would not authorize the required synchronous Converse calls, even when the selected model supports messages.

#### D. Build the synchronous chat interface with the AWS SDK by calling InvokeModel on the regional bedrock-runtime endpoint, and require each application to send the native request body for its chosen provider.

❌ Incorrect

> **Explanation:** This is incorrect because InvokeModel is a valid Bedrock-native synchronous API, but it does not provide the unified messages abstraction required by the scenario. Requiring each application to use provider-specific request bodies pushes model-specific integration logic into clients instead of standardizing the chat interface.

#### E. Build the streaming interface with the AWS CLI by calling ConverseStream for every selected chat model, and fall back to InvokeModelWithResponseStream when a stream fails.

❌ Incorrect

> **Explanation:** This is incorrect because the AWS CLI does not support Bedrock streaming operations such as ConverseStream and InvokeModelWithResponseStream. It also relies on failure-based fallback rather than checking model streaming capability before enabling the interface.

</details>

---

<details>
<summary><strong>Question 19</strong> — Answer: <strong>A</strong></summary>

### Question 19

A retail bank&#x27;s digital channels AI team runs an Amazon Bedrock assistant that answers policy questions for branch employees. Several developers edit the same prompt frequently. Some prompt releases improve factual completeness, but other releases produce responses that downstream systems cannot parse. The bank wants to improve answer quality over time, preserve a traceable history of prompt changes, and avoid model customization.<br>Which approach best meets these requirements?

> **Answer:** A

#### A. Store prompt releases in Amazon Bedrock Prompt Management, define variables for policy context and user intent, specify a JSON response contract, and correlate user ratings with prompt versions.

✅ **Correct**

> **Explanation:** Correct. Prompt Management supports reusable prompts with variables and versioning, which helps teams track prompt changes and compare behavior across releases. Structured input components, output format specifications, and feedback tied to prompt versions create an iterative quality loop without model customization.

#### B. Apply Amazon Bedrock Guardrails to the existing prompt, configure denied topics and PII masking, validate JSON in application code, and use guardrail intervention counts as the feedback loop.

❌ Incorrect

> **Explanation:** Incorrect. Guardrails are useful for safety, privacy, and policy controls, and application-side schema validation can reject malformed JSON. Guardrail intervention counts do not directly measure whether answers are complete, helpful, or consistently parseable across prompt releases.

#### C. Store prompt templates in a source repository, run CI checks against sample outputs, inject policy context at runtime, and compare release notes after deployment.

❌ Incorrect

> **Explanation:** Incorrect. A source repository and CI checks can provide general change control, but they do not provide Bedrock-native prompt management for reusable prompt resources and versions. Comparing release notes after deployment is weaker than correlating actual user feedback or reviewer judgments with the prompt version that produced each response.

#### D. Keep the prompt in application code, lower temperature to zero, request step-by-step reasoning, and use average response length as the primary quality signal.

❌ Incorrect

> **Explanation:** Incorrect. Lowering temperature can reduce variability, but it does not provide managed prompt versioning or a meaningful feedback loop. Average response length is a weak proxy for quality and does not measure factual completeness, parseability, or user usefulness.

</details>

---

<details>
<summary><strong>Question 20</strong> — Answer: <strong>A</strong></summary>

### Question 20

A maritime insurance underwriter&#x27;s claims AI platform team uses Amazon Bedrock Knowledge Bases for a RAG assistant. The team is tuning chunking and retrieval settings before connecting the retrieved content to a foundation model. The team needs a repeatable prerelease test that evaluates only the retrieval component against SME-written ground-truth answers, and the team also needs request-level troubleshooting for retrieval path latency without adding application-side timing code.<br>Which approach best meets these requirements?

> **Answer:** A

#### A. Create an S3 .jsonl prompt dataset with single-turn records that include prompt and referenceResponses. Run a retrieve-only RAG evaluation with Builtin.ContextRelevance and Builtin.ContextCoverage. Use AWS X-Ray traces for Retrieve latency analysis.

✅ **Correct**

> **Explanation:** Correct. Retrieve-only RAG evaluations are designed to evaluate retrieved data without evaluating generated answers, and the built-in retrieval metrics are ContextRelevance and ContextCoverage. ContextCoverage requires ground truth, and AWS X-Ray traces can be used to analyze internal steps and latency for the Retrieve operation.

#### B. Create an S3 .jsonl prompt dataset with up to five-turn records that include prompt and referenceResponses. Run a retrieve-and-generate RAG evaluation with Builtin.Faithfulness and Builtin.CitationCoverage. Use KnowledgeBases CloudWatch metrics for latency analysis.

❌ Incorrect

> **Explanation:** Incorrect. Retrieve-and-generate evaluations assess both retrieval and generated responses, so they do not isolate the retrieval component. Managed Knowledge Bases publish operational CloudWatch metrics such as invocations and errors, but the documented metrics do not include a latency metric for this purpose.

#### C. Create an S3 .jsonl prompt dataset with single-turn records that include knowledgeBaseIdentifier and retrievedResults. Run a retrieve-only RAG evaluation with Builtin.Correctness and Builtin.Completeness. Use model-runtime CloudWatch metrics for latency analysis.

❌ Incorrect

> **Explanation:** Incorrect. Precomputed retrieval results can be evaluated, but Correctness and Completeness are retrieve-and-generate metrics, not retrieve-only metrics. Model-runtime metrics apply to foundation model invocation behavior and should not be confused with Knowledge Base retrieval troubleshooting.

#### D. Create an S3 .jsonl prompt dataset with single-turn records that include prompt and referenceContexts. Run a retrieve-only RAG evaluation with Builtin.ContextRelevance and Builtin.ContextCoverage. Use KnowledgeBases CloudWatch metrics for latency analysis.

❌ Incorrect

> **Explanation:** Incorrect. For a retrieve-only evaluation where Amazon Bedrock invokes the Knowledge Base, ContextCoverage uses referenceResponses as the ground truth, not referenceContexts. ReferenceContexts is used only for custom metrics in precomputed retrieval datasets, and the KnowledgeBases CloudWatch namespace is not the documented way to analyze request latency.

</details>

---

<details>
<summary><strong>Question 21</strong> — Answer: <strong>A</strong></summary>

### Question 21

A regional airline&#x27;s contact center platform team uses Amazon Bedrock Runtime InvokeModel from a middleware service that receives a fixed internal request object from web and mobile clients. The middleware routes requests to multiple Bedrock model IDs, including base models from different providers and customized models. After adding an imported customized model, some requests fail validation and other requests complete but do not honor several generation settings. The team must keep the client contract unchanged and must continue using InvokeModel.<br>Which change should the team implement?

> **Answer:** A

#### A. Build a model-aware serialization layer that sets contentType to application/json and converts the canonical request into the documented native body for each modelId.

✅ **Correct**

> **Explanation:** Correct. InvokeModel requires a JSON request body, but the JSON shape and inference parameters depend on the selected model. A middleware adapter can preserve the client contract while emitting the correct native payload for each model ID.

#### B. Build a shared serialization layer that sets contentType to application/json and sends the same messages, system, temperature, and maxTokens body to each modelId.

❌ Incorrect

> **Explanation:** Incorrect. A JSON content type is necessary, but it is not sufficient because InvokeModel native request bodies are not universal across model providers. Sending one generic body to every model can still cause validation failures or ignored settings.

#### C. Build a prompt-only serialization layer that sets contentType to application/json and sends prompt text plus all optional parameters, leaving unsupported keys in place.

❌ Incorrect

> **Explanation:** Incorrect. Keeping unsupported keys in the payload does not make InvokeModel normalize or translate those parameters for the selected model. For imported customized models, unmatched parameters can be ignored, which conflicts with the requirement to honor generation settings.

#### D. Build a source-model serialization layer that sets contentType to application/json and sends the original foundation model body to every customized or imported model.

❌ Incorrect

> **Explanation:** Incorrect. Customized models use the inference parameters of the foundation model they were customized from, but that does not create one body shape for all routed models. Imported customized models ignore parameters that do not match documented parameters, so this approach can preserve the silent parameter loss.

</details>

---

<details>
<summary><strong>Question 22</strong> — Answer: <strong>C, D</strong></summary>

### Question 22

A municipal permitting office is replacing several spreadsheet-driven review steps with a generative AI portal for residents and permit reviewers. The office wants front-end teams to embed an accessible chat experience quickly, stream multi-turn responses from Amazon Bedrock foundation models, persist each user&#x27;s conversation history without building custom storage, and scope access to each signed-in user. The office also wants non-developer process analysts to maintain a branching review workflow that can call prompts, a knowledge base, and Lambda functions, and developers must be able to inspect per-node inputs and outputs during testing.<br>Which TWO implementation steps meet these requirements? (Select TWO.)

> **Answer:** C, D

#### A. Build the review workflow as an Amazon Bedrock Flow with separate flow input nodes for applicant details, parcel data, and uploaded document text.

❌ Incorrect

> **Explanation:** Amazon Bedrock Flows require exactly one flow input node, and the flow must begin with that input node. Multiple input nodes for different form sections would fail the documented flow structure requirements.

#### B. Build the multi-turn clarification path with prompt and condition nodes in Amazon Bedrock Flows; resume user questions by passing prior flowOutputEvent content.

❌ Incorrect

> **Explanation:** Multi-turn behavior in Amazon Bedrock Flows requires an Agent node connected to an Amazon Bedrock agent. Continuation calls must use the flow conversation executionId after an input-required response, not simply replay prior output content.

#### C. Build the permitting review workflow in Amazon Bedrock Flows by linking input, prompt, knowledge base, condition, and Lambda nodes; test with InvokeFlow tracing enabled.

✅ **Correct**

> **Explanation:** This meets the workflow requirements because Amazon Bedrock Flows supports visual or API-based composition of prompts, Bedrock features such as knowledge bases, and AWS services such as Lambda. Enabling trace during InvokeFlow testing provides visibility into per-node inputs, outputs, and condition results.

#### D. Build the resident chat front end with Amplify Gen 2 AI conversation routes and Amplify UI primitives; configure owner-based authorization for each user&#x27;s conversations.

✅ **Correct**

> **Explanation:** This meets the chat interface requirements because Amplify Gen 2 AI conversation routes set up the AppSync and Lambda components for streaming multi-turn Bedrock interactions. The feature persists conversations and messages in DynamoDB, includes prior messages in LLM history, and supports owner-based authorization.

#### E. Build the resident chat front end with Amplify UI primitives and call InvokeFlow from the browser; store conversation turns in local storage for each session.

❌ Incorrect

> **Explanation:** Amplify UI primitives can help teams follow accessibility best practices, but this approach does not use the documented Amplify AI conversation route capability for streaming multi-turn Bedrock conversations. Local storage does not satisfy the requirement to persist conversation history with per-user access scoping without custom storage.

</details>

---

<details>
<summary><strong>Question 23</strong> — Answer: <strong>C</strong></summary>

### Question 23

A medical device manufacturer&#x27;s AI governance office already uses AWS Audit Manager for internal control evidence. The office is standardizing oversight for several FM applications that use Amazon Bedrock and Amazon SageMaker AI. The governance program must align with responsible AI principles, support automated and manually collected evidence, and avoid treating the assessment results as a formal compliance certification.<br>Which approach will meet these requirements with the LEAST custom governance implementation?

> **Answer:** C

#### A. Create a custom AWS Audit Manager framework, define all responsible AI controls manually, and use application logs as the primary source for evidence collection.

❌ Incorrect

> **Explanation:** A custom framework can be valid when no managed framework fits, but it creates more governance implementation work than required here. It also requires the team to recreate controls that are already available in the AWS-managed generative AI framework.

#### B. Create Amazon Bedrock Guardrails for each application, collect intervention results during inference, and use blocked responses as the primary governance evidence.

❌ Incorrect

> **Explanation:** Guardrails can evaluate user inputs and model responses, but they are runtime safety controls rather than an organizational assessment framework. This approach does not provide the broader control sets, manual evidence support, or SageMaker AI evidence coverage required by the governance office.

#### C. Create an AWS Audit Manager assessment from the AWS Generative AI Best Practices Framework v2, collect automated evidence where supported, and attach manual evidence for procedural controls.

✅ **Correct**

> **Explanation:** This approach uses the AWS-managed generative AI framework that supports evidence collection for Amazon Bedrock and Amazon SageMaker AI. It also accounts for the fact that some procedural controls require manual evidence and that the framework is not a compliance certification.

#### D. Create an AWS Audit Manager assessment from the AWS Generative AI Best Practices Framework v1, collect automated evidence where supported, and attach manual evidence for procedural controls.

❌ Incorrect

> **Explanation:** The earlier framework version is no longer supported for creating new assessments. Choosing it would not meet the requirement to standardize new governance assessments for current FM implementations.

</details>

---

<details>
<summary><strong>Question 24</strong> — Answer: <strong>B</strong></summary>

### Question 24

A digital textbook platform&#x27;s engineering productivity team is standardizing how developers build generative AI features that use AWS Lambda, AWS CDK, and Amazon Bedrock APIs. Developers work in Visual Studio Code and JetBrains IDEs. The team needs help with AWS SDK questions, code suggestions and refactoring in the IDE, repository coding guidance, and security issue identification before pull requests. The team wants the fastest path with the least custom integration.<br>Which approach will meet these requirements MOST effectively?

> **Answer:** B

#### A. Deploy Amazon Q Business for the engineering organization. Connect source repositories and AWS documentation, and expose custom plugins for pull request and build workflow actions.

❌ Incorrect

> **Explanation:** Incorrect. Amazon Q Business is intended for employee question answering and task automation over enterprise knowledge and applications. It does not provide the same IDE-native code completion, refactoring, and security scanning workflow expected for developers.

#### B. Deploy Amazon Q Developer in the approved IDEs. Configure project guidance, and use chat, inline suggestions, refactoring support, and security scans during pull request preparation.

✅ **Correct**

> **Explanation:** Correct. Amazon Q Developer is designed for developer workflows, including IDE-based chat, code suggestions, AWS API assistance, refactoring help, and security scans. Project guidance can help align generated or suggested code with repository conventions without requiring a custom assistant.

#### C. Create an Amazon Bedrock agent for the engineering organization. Index AWS documentation in a knowledge base, and use action groups to run lint, test, and build commands.

❌ Incorrect

> **Explanation:** Incorrect. An Amazon Bedrock agent can orchestrate tools and knowledge bases, but this approach requires custom integration and ongoing maintenance. It also does not natively provide the IDE code suggestion and security scanning experience required by the development workflow.

#### D. Create Amazon Q Apps for the engineering organization. Build reusable workflow apps for code review checklists, prompt templates, and issue tracking updates through approved plugins.

❌ Incorrect

> **Explanation:** Incorrect. Amazon Q Apps helps users create productivity applications from natural language, typically for business workflows. It is not the best fit for IDE-based code generation, refactoring, AWS SDK assistance, or security scanning.

</details>

---

<details>
<summary><strong>Question 25</strong> — Answer: <strong>C</strong></summary>

### Question 25

A public-sector weather agency&#x27;s citizen-services team runs a RAG assistant on Amazon Bedrock Knowledge Bases to answer storm-preparedness questions through an API. The team is changing the FM used for generation, but the retrieval source and application code are unchanged. Before each promotion, the team must exercise the deployed API path with production-like user journeys, check availability and latency, and automatically compare generated answers against an 850-prompt regression set stored in S3 as .jsonl. The regression set includes reference contexts, and no conversation has more than four turns. The team wants to catch answer drift and unsupported claims without building a separate evaluation platform.<br>Which validation design best meets these requirements?

> **Answer:** C

#### A. Schedule CloudWatch Synthetics canaries to invoke the API routes with representative prompts and scripted response checks. Run an Amazon Bedrock retrieve-only evaluation job using the S3 .jsonl dataset, and gate promotion on context relevance and coverage metrics.

❌ Incorrect

> **Explanation:** Retrieve-only evaluation is useful when the validation target is retrieval quality, such as whether the retrieved context is relevant and complete. The changed component is the generation FM, so this approach does not directly evaluate the generated answers for unsupported claims or response drift.

#### B. Schedule a Step Functions workflow to invoke the API routes with representative prompts and store transcripts in S3. Run an Amazon Bedrock retrieve-and-generate evaluation job using the S3 .jsonl dataset, and gate promotion on built-in response-quality metrics.

❌ Incorrect

> **Explanation:** This approach can validate generated RAG answers with a documented Bedrock retrieve-and-generate evaluation job. However, it recreates scheduled endpoint monitoring logic that CloudWatch Synthetics already provides for availability, latency, and customer-like API workflow checks.

#### C. Schedule CloudWatch Synthetics canaries to invoke the API routes with representative prompts and scripted response checks. Run an Amazon Bedrock retrieve-and-generate evaluation job using the S3 .jsonl dataset, and gate promotion on the canary results and built-in response-quality metrics.

✅ **Correct**

> **Explanation:** This design validates both the deployed application path and the generated answer quality before promotion. CloudWatch Synthetics canaries cover availability, latency, and scripted workflow checks, while a retrieve-and-generate evaluation can score RAG answer quality with metrics such as faithfulness and correctness.

#### D. Schedule CloudWatch Synthetics canaries to invoke the API routes with representative prompts and scripted response checks. Run an Amazon Bedrock model evaluation job against the changed FM, and gate promotion on built-in correctness and faithfulness metrics.

❌ Incorrect

> **Explanation:** This approach uses the right managed service for API-path validation and uses documented Bedrock evaluation metrics. However, a model evaluation job targets the model rather than the Knowledge Bases retrieve-and-generate RAG workflow, so it is less aligned to validating generated answers with retrieved context.

</details>

---

<details>
<summary><strong>Question 26</strong> — Answer: <strong>A</strong></summary>

### Question 26

A university&#x27;s research administration AI team is building an Amazon Bedrock RAG assistant for grants staff. The source content is split between Atlassian Confluence spaces and Microsoft SharePoint sites, both updated daily. The assistant must use supported source integrations rather than a custom crawler, minimize ownership of ingestion, indexing, storage, and retrieval infrastructure, and respect document-level access boundaries during retrieval for each grants staff user. The team can pass required user context from the application to retrieval calls, can tolerate externally scheduled synchronization, but cannot allow deleted or modified source documents to remain indefinitely stale in retrieval results.<br>Which integration design best meets these requirements?

> **Answer:** A

#### A. Create a Managed Knowledge Base, add Confluence and SharePoint data sources, configure document-level permissions, pass user context during retrieval, and schedule recurring StartIngestionJob calls.

✅ **Correct**

> **Explanation:** This approach uses the managed knowledge base type, which is the documented option for Bedrock-managed ingestion, indexing, storage, and retrieval infrastructure. Confluence and SharePoint are supported unstructured-data connectors, document-level permissions are documented for managed knowledge bases, and recurring StartIngestionJob calls can synchronize source changes.

#### B. Create a customer-managed Bedrock Knowledge Base, ingest Confluence and SharePoint content into a self-managed vector store, apply user filters during retrieval, and schedule recurring sync jobs.

❌ Incorrect

> **Explanation:** This design could enforce access boundaries if the team correctly builds and maintains the permission metadata and retrieval filters. However, it shifts more RAG pipeline and vector-store-related infrastructure ownership to the team and does not best meet the requirement to minimize managed infrastructure ownership.

#### C. Create a custom Bedrock data source, ingest Confluence and SharePoint documents with KnowledgeBaseDocuments APIs, map ACL metadata in recurring jobs, and delete removed documents.

❌ Incorrect

> **Explanation:** A custom data source supports direct document ingestion, deletion, and metadata attachment through KnowledgeBaseDocuments API operations. However, it requires the team to build and maintain the extraction, permission mapping, and update logic from Confluence and SharePoint, which conflicts with the requirement to use supported source integrations with minimal operational ownership.

#### D. Create a Bedrock Knowledge Base over S3 exports, copy Confluence and SharePoint content to S3, enable metadata filters, and schedule export and sync jobs.

❌ Incorrect

> **Explanation:** Amazon S3 is a supported data source, and metadata filters can be useful when the application reliably supplies per-user filter criteria. However, this design replaces the native Confluence and SharePoint integrations with a separate export pipeline and additional permission-mapping logic.

</details>

---

<details>
<summary><strong>Question 27</strong> — Answer: <strong>A</strong></summary>

### Question 27

A telehealth triage platform&#x27;s clinical operations team uses a single Amazon Bedrock text model to generate structured intake summaries from nurse chat transcripts. The downstream system rejects summaries when required JSON fields are missing or when the same transcript produces materially different field values across repeated runs. The team has 2,000 reviewed transcripts with expected summaries and must choose inference settings for production without building a custom experimentation service.<br>Which approach will best meet these requirements?

> **Answer:** A

#### A. Run Amazon Bedrock Evaluations across low-temperature and narrower-sampling candidates, then deploy the supported configuration that meets the quality thresholds.

✅ **Correct**

> **Explanation:** This approach uses the reviewed transcript dataset to compare inference configurations before production rollout. Lower temperature and narrower sampling settings generally reduce randomness for extraction-style workloads, while evaluation verifies that the chosen settings still meet the required quality thresholds.

#### B. Run Amazon Bedrock Evaluations across maxTokens and JSON-template candidates while keeping sampling unchanged, then deploy the configuration that passes schema checks.

❌ Incorrect

> **Explanation:** JSON templates and response length controls can help reduce malformed or incomplete output, but they do not directly address randomness from unchanged sampling parameters. A configuration can pass schema checks and still produce materially different field values across repeated runs.

#### C. Run Amazon Bedrock Evaluations across very low top_p candidates, then deploy the configuration that best satisfies repeatability checks.

❌ Incorrect

> **Explanation:** Restricting nucleus sampling can reduce variability, but setting it too aggressively can make outputs brittle or reduce answer quality. Optimizing repeatability without also validating schema completeness and expected field values does not meet all production requirements.

#### D. Run Amazon Bedrock Evaluations across temperature-only candidates, then deploy the configuration with the highest semantic correctness score.

❌ Incorrect

> **Explanation:** Temperature tuning is relevant, but it is not the only sampling control that can affect repeatability for supported models. A semantic correctness score alone can miss required-field omissions or repeated-run differences that cause downstream rejection.

</details>

---

<details>
<summary><strong>Question 28</strong> — Answer: <strong>C</strong></summary>

### Question 28

A biomedical imaging software vendor&#x27;s AI platform team is deploying a 70 GB open-weight LLM to a SageMaker real-time endpoint for interactive report drafting. The model artifact is stored in Amazon S3. Endpoint creation repeatedly fails before the model can serve traffic because downloading the artifact and passing the container startup health check take too long. The selected GPU instance configuration does not provide local instance storage large enough for the full model artifact. The team also wants a deployment pattern that is designed for LLM memory use, GPU utilization, and token processing capacity without building a custom serving stack.<br>Which deployment approach best meets these requirements?

> **Answer:** C

#### A. Deploy the model with a standard SageMaker PyTorch inference container. Reference a `tar.gz` artifact with `ModelDataUrl`; increase endpoint instance count and set longer client-side read timeouts for invocations.

❌ Incorrect

> **Explanation:** A standard inference container can host models, but it does not provide the SageMaker LMI container tooling that is designed specifically for LLM serving challenges. Increasing instance count and client timeouts does not solve failures that occur before the endpoint becomes healthy during model download and container startup.

#### B. Deploy the model with a custom SageMaker inference container. Download the weights from S3 during the first invocation; keep the default model download and container startup settings for the endpoint.

❌ Incorrect

> **Explanation:** Loading a very large model during the first request shifts the startup problem into the request path and is a poor fit for an interactive endpoint. Keeping the default download and startup settings also fails to address the documented timeout and storage considerations for large model artifacts.

#### C. Deploy the model with a SageMaker LMI container. Reference the S3 prefix with `ModelDataSource` and `CompressionType` set to `None`; set `VolumeSizeInGB`, `ModelDataDownloadTimeoutInSeconds`, and `ContainerStartupHealthCheckTimeoutInSeconds` for the production variant.

✅ **Correct**

> **Explanation:** This approach uses the SageMaker Large Model Inference container family, which is specialized for LLM inference and related optimizations such as quantization, tensor parallelism, and continuous batching. It also addresses the documented startup constraints for large model artifacts by using uncompressed model deployment and configuring the production variant storage and timeout settings.

#### D. Deploy the model with a SageMaker multi-model endpoint. Store each shard as a separate S3 model artifact; rely on dynamic loading and leave the production variant storage settings unchanged.

❌ Incorrect

> **Explanation:** Multi-model endpoints are useful for hosting multiple models on shared infrastructure, but this scenario is about reliably starting one very large LLM endpoint. Leaving the production variant storage and timeout settings unchanged does not address the model download and container health check failures.

</details>

---

<details>
<summary><strong>Question 29</strong> — Answer: <strong>B</strong></summary>

### Question 29

A European pharmaceutical manufacturer&#x27;s lab automation team is building a generative AI assistant for researchers. Raw experiment records must be normalized inside the manufacturer&#x27;s data center in Germany before any prompt is sent to Amazon Bedrock. Bedrock prompt processing may occur in AWS Regions within the EU geography, but not in Regions outside that geography. The data center has an AWS Outposts rack attached to a VPC with non-overlapping CIDR ranges, and the application does not require Provisioned Throughput. The design must avoid public internet paths for Bedrock API calls and must use supported routing between on-premises systems, the Outposts rack, and AWS services.<br>Which architecture will meet these requirements?

> **Answer:** B

#### A. Run the preprocessing service on EC2 instances in an Outposts rack subnet. Use the rack local gateway with direct VPC routing to the instance private IPs, route Bedrock Runtime API calls through a NAT gateway, and invoke an EU geographic inference profile.

❌ Incorrect

> **Explanation:** This design uses a supported Outposts routing pattern and a valid Bedrock inference profile, but it sends Bedrock Runtime API traffic through a public service endpoint path. The scenario requires avoiding public internet paths for Bedrock API calls, so private access through an interface VPC endpoint is the better fit.

#### B. Run the preprocessing service on EC2 instances in an Outposts rack subnet. Use the rack local gateway with direct VPC routing to the instance private IPs, create a Bedrock Runtime interface VPC endpoint in the VPC, and invoke an EU geographic inference profile.

✅ **Correct**

> **Explanation:** This design keeps the required preprocessing on the Outposts rack and uses direct VPC routing appropriately because the on-premises network reaches instance private IP addresses and the CIDRs do not overlap. The Bedrock Runtime interface endpoint provides private VPC access to Bedrock, and an EU geographic inference profile keeps cross-Region inference within the EU geography.

#### C. Run the preprocessing service on EC2 instances in an Outposts rack subnet. Use the rack local gateway with direct VPC routing to the Bedrock endpoint ENI IPs, create a Bedrock Runtime interface VPC endpoint in the VPC, and invoke an EU geographic inference profile.

❌ Incorrect

> **Explanation:** This design incorrectly depends on on-premises systems reaching the interface endpoint&#x27;s requester-managed network interfaces through direct VPC routing. AWS documents that direct VPC routing for a local gateway is supported for instance network interfaces, not requester-managed interfaces such as VPC endpoint network interfaces.

#### D. Run the preprocessing service on EC2 instances in an Outposts rack subnet. Use the rack local gateway with direct VPC routing to the instance private IPs, create a Bedrock Runtime interface VPC endpoint in the VPC, and invoke a global inference profile.

❌ Incorrect

> **Explanation:** This design uses supported local gateway routing to the preprocessing instances and private VPC access to Bedrock. However, a global inference profile can route requests to supported commercial AWS Regions worldwide, which does not satisfy a requirement to keep Bedrock processing within the EU geography.

</details>

---

<details>
<summary><strong>Question 30</strong> — Answer: <strong>B</strong></summary>

### Question 30

An aerospace manufacturer&#x27;s engineering AI team is deploying a generative design assistant. The application runs in AWS Lambda functions attached to private subnets, invokes Amazon Bedrock foundation models, and reads proprietary CAD metadata through Amazon Athena from an Amazon S3 data lake registered in the AWS Glue Data Catalog. Regulations require model invocations and data retrieval to stay off the public internet, project teams to see only authorized datasets and columns, and security operations to alarm on unusual access attempts with minimal custom code.<br>Which design best meets these requirements?

> **Answer:** B

#### A. Configure interface VPC endpoints for Bedrock Runtime, Athena, and AWS Glue, add an S3 gateway endpoint with endpoint and bucket policies, enforce project access only with IAM policies on S3 prefixes, and publish Lambda application logs to CloudWatch alarms.

❌ Incorrect

> **Explanation:** Incorrect. The VPC endpoint pattern is appropriate, but IAM policies on S3 prefixes do not provide the same table and column governance for Athena queries as Lake Formation. Lambda application logs can show application behavior, but they are not a complete audit source for AWS API and S3 data access attempts.

#### B. Configure interface VPC endpoints for Bedrock Runtime, Athena, and AWS Glue, add an S3 gateway endpoint with endpoint and bucket policies, grant table and column access with Lake Formation, and send relevant CloudTrail events to CloudWatch Logs for metric filters and alarms.

✅ **Correct**

> **Explanation:** Correct. Interface VPC endpoints keep supported AWS API calls from the private subnets on private connectivity, and an S3 gateway endpoint can be combined with bucket and endpoint policies to restrict S3 access paths. Lake Formation provides fine-grained permissions for cataloged data used by Athena, and CloudTrail events can be delivered to CloudWatch Logs for metric filters and alarms.

#### C. Configure interface VPC endpoints for Bedrock Runtime and S3, copy authorized data into project-specific S3 buckets, grant bucket access with IAM policies, and monitor Amazon S3 request metrics with CloudWatch alarms.

❌ Incorrect

> **Explanation:** Incorrect. Project-specific buckets can reduce accidental sharing, but copying governed data creates operational overhead and does not provide centralized column-level authorization for Athena. This design also omits private endpoints for the Athena and AWS Glue API calls made by the application.

#### D. Configure private subnets with NAT gateways for Bedrock Runtime, Athena, and AWS Glue, restrict egress with IAM and security group rules, grant table and column access with Lake Formation, and send relevant CloudTrail events to CloudWatch Logs for metric filters and alarms.

❌ Incorrect

> **Explanation:** Incorrect. NAT gateways allow private subnet resources to reach public service endpoints, which does not satisfy the requirement to keep model invocation and data access off the public internet path. Lake Formation and CloudWatch monitoring help with authorization and visibility, but they do not compensate for the network isolation gap.

</details>

---

<details>
<summary><strong>Question 31</strong> — Answer: <strong>D</strong></summary>

### Question 31

An electric utility&#x27;s grid operations software team is enabling several product teams to build Amazon Bedrock applications, including outage summarization, maintenance procedure Q&amp;A, and regulatory report drafting. The product teams deploy independently in separate AWS accounts and sometimes use different RAG data sources, but the security office has found inconsistent IAM boundaries, guardrail use, logging, and retrieval patterns. The platform team must provide a reusable standard that teams can adopt without waiting for manual design approval, and must produce repeatable architecture review evidence for each deployment.<br>Which approach will meet these requirements MOST effectively?

> **Answer:** D

#### A. Publish reusable AWS CDK constructs for approved Bedrock integration patterns, and assess each deployment in AWS Well-Architected Tool by applying only the standard pillars.

❌ Incorrect

> **Explanation:** Reusable CDK constructs help standardize implementation, but using only the standard Well-Architected pillars misses GenAI-specific review considerations. The scenario requires consistent Bedrock, guardrail, logging, and retrieval implementation, which is better addressed by a GenAI-focused lens.

#### B. Publish reusable CloudFormation stacks for approved Bedrock integration patterns, and assess each deployment by storing checklist results in a shared repository.

❌ Incorrect

> **Explanation:** Reusable CloudFormation can standardize infrastructure, but static checklist files do not provide the same structured workload review, risk tracking, and improvement planning workflow. This approach is more prone to drift and inconsistent evidence across independently deployed teams.

#### C. Publish a shared Bedrock proxy service for approved Bedrock integration patterns, and assess each deployment by reviewing proxy invocation logs centrally.

❌ Incorrect

> **Explanation:** A shared proxy can centralize some controls, but it can become a coupling point that limits teams using different RAG sources and deployment patterns. Invocation logs provide operational evidence, but they do not replace architecture review evidence or a reusable deployment standard.

#### D. Publish reusable AWS CDK constructs for approved Bedrock integration patterns, and assess each deployment in AWS Well-Architected Tool by applying the Generative AI Lens.

✅ **Correct**

> **Explanation:** This creates standardized technical components that product teams can reuse across different deployment scenarios while still allowing pattern-specific configuration. AWS Well-Architected Tool with the Generative AI Lens provides a repeatable way to document risks, decisions, and improvement plans for each workload.

</details>

---

<details>
<summary><strong>Question 32</strong> — Answer: <strong>D</strong></summary>

### Question 32

A global video game studio&#x27;s trust and safety team is building a real-time NPC chat feature by using Amazon Bedrock. The feature must block harmful player prompts before they reach the foundation model, mask sensitive information in model responses, enforce studio-specific banned topics, and send only ambiguous moderation cases to a human review process. Normal conversations must stay on the synchronous request path with minimal added latency.<br>Which solution will meet these requirements with the LEAST operational overhead?

> **Answer:** D

#### A. Run each chat turn through a Step Functions Express workflow, invoke Lambda pre-checks, apply a Bedrock guardrail during inference, and branch to human review for ambiguous cases.

❌ Incorrect

> **Explanation:** Incorrect. Step Functions Express workflows can support synchronous orchestration, and this design still uses Bedrock guardrails. However, putting every normal chat turn through a workflow adds orchestration complexity and latency compared with keeping only exception handling in Step Functions.

#### B. Apply an Amazon Bedrock guardrail only to model responses in the gateway Lambda, add Lambda checks for player prompts, and start Step Functions only for human review exceptions.

❌ Incorrect

> **Explanation:** Incorrect. This preserves an exception-only review path, but it does not use managed guardrail evaluation for prompts before they reach the foundation model. Relying on custom prompt checks for the primary input safety control increases operational overhead and weakens coverage compared with applying guardrails to both inputs and outputs.

#### C. Run a custom Lambda moderation service before Bedrock, use Amazon Comprehend for entity detection, mask responses in Lambda, and start Step Functions only for low-confidence cases.

❌ Incorrect

> **Explanation:** Incorrect. This can implement a moderation path, but it shifts broad harmful-content filtering, topic controls, and output safety handling into custom logic. That increases development and tuning overhead compared with using managed Bedrock guardrails inline.

#### D. Apply an Amazon Bedrock guardrail to prompts and responses in the gateway Lambda, add Lambda checks for studio-specific policies, and start Step Functions only for human review exceptions.

✅ **Correct**

> **Explanation:** Correct. Amazon Bedrock guardrails provide managed filtering for harmful content, denied topics, word filters, and sensitive information handling across inputs and outputs. Lambda can add narrow custom checks that guardrails do not cover, while Step Functions is reserved for exception workflows so normal requests remain synchronous.

</details>

---

<details>
<summary><strong>Question 33</strong> — Answer: <strong>A</strong></summary>

### Question 33

An online legal research platform&#x27;s AI operations team runs a RAG assistant by using Amazon Bedrock managed knowledge bases backed by Amazon OpenSearch Serverless. The team must detect retrieval throttling and failures, identify OpenSearch Serverless indexing and search issues, and trace ingestion failures back to individual source documents while inspecting chunk creation, deletion, and failure statistics. The team wants to use managed AWS observability features and minimize custom instrumentation.<br>Which operational management approach will BEST meet these requirements?

> **Answer:** A

#### A. Configure CloudWatch dashboards and alarms for AWS/Bedrock/KnowledgeBases Retrieve metrics and AWS/AOSS ingestion and search metrics, and enable knowledge base ingestion log delivery to inspect document status and chunk statistics.

✅ **Correct**

> **Explanation:** This approach uses the documented runtime metrics for Bedrock managed knowledge bases and the documented CloudWatch metrics for OpenSearch Serverless. It also enables ingestion log delivery, which is required to inspect per-document crawl, sync, and index status, along with chunk statistics and document processing errors.

#### B. Configure CloudWatch dashboards and alarms for AWS/Bedrock/KnowledgeBases Retrieve metrics only, and use ingestion job summary statistics to infer document status and chunk failures.

❌ Incorrect

> **Explanation:** Bedrock managed knowledge base runtime metrics can detect Retrieve invocations, errors, and throttles, but they do not identify OpenSearch Serverless indexing or search path issues. Ingestion job summary statistics do not provide the per-document lifecycle status and chunk statistics that managed ingestion logs provide.

#### C. Configure CloudWatch dashboards and alarms for AWS/AOSS StorageUsedInS3 and SearchOCU metrics, and compare StorageUsedInS3 with index size reports to validate document ingestion and logical index growth.

❌ Incorrect

> **Explanation:** OpenSearch Serverless StorageUsedInS3 reflects physical S3 storage usage, including replication, metadata, and internal indexing overhead. It is not a reliable measure of logical index size or document ingestion correctness.

#### D. Configure CloudWatch dashboards and alarms for AWS/AOSS ingestion and search request metrics only, and use application request logs to infer Bedrock retrieval throttling and failures.

❌ Incorrect

> **Explanation:** OpenSearch Serverless metrics are useful for indexing and search operations, but they do not replace Bedrock knowledge base runtime metrics for managed Retrieve calls. Application request logs can show symptoms, but they do not provide the managed Bedrock throttle and error metrics or document-level ingestion lifecycle details.

</details>

---

<details>
<summary><strong>Question 34</strong> — Answer: <strong>C</strong></summary>

### Question 34

An airline operations center&#x27;s disruption-management AI team uses the Amazon Bedrock Converse API with Amazon Nova Pro to draft passenger rebooking explanations during irregular operations. Agents complain that full responses take too long, but the team must keep the same model and return partial text to the browser as soon as possible. Requests are interactive, not predictable enough for precomputed answers, and the team wants to benchmark first-token responsiveness and generation speed after deployment.<br>Which approach will best meet these requirements while preserving operational simplicity?

> **Answer:** C

#### A. Keep the Converse calls synchronous, request performanceConfig.latency set to optimized, and monitor InvocationLatency and token counts in CloudWatch.

❌ Incorrect

> **Explanation:** Latency optimized inference can improve runtime latency for supported models, and Amazon Nova Pro is supported by the documented preview feature. However, synchronous Converse does not return partial text while the response is being generated, and it does not emit TimeToFirstToken for first-token benchmarking.

#### B. Switch the client path to ConverseStream, add prompt cache checkpoints to static instructions, and monitor InvocationLatency and cache token counts in CloudWatch.

❌ Incorrect

> **Explanation:** Prompt caching can reduce latency and input-token cost when a supported model reuses a static prompt prefix that meets checkpoint requirements. It does not replace requesting latency optimized inference, and monitoring only InvocationLatency and cache token counts does not directly benchmark TimeToFirstToken or output tokens per second.

#### C. Switch the client path to ConverseStream, request performanceConfig.latency set to optimized, and monitor TimeToFirstToken, InvocationLatency, and token counts in CloudWatch.

✅ **Correct**

> **Explanation:** ConverseStream streams response chunks as they are generated, which improves perceived responsiveness for an interactive browser experience. Latency optimized inference is requested per invocation with performanceConfig.latency and does not require tuning or setup, while TimeToFirstToken is available for streaming traffic.

#### D. Switch the client path to ConverseStream, use the default performanceConfig.latency route, and monitor TimeToFirstToken, InvocationLatency, and token counts in CloudWatch.

❌ Incorrect

> **Explanation:** ConverseStream would satisfy the partial-output requirement and provide the streaming metrics needed for first-token and generation-speed benchmarking. However, leaving the request on the default standard latency route misses the documented per-invocation latency optimization that is available for the same supported model.

</details>

---

<details>
<summary><strong>Question 35</strong> — Answer: <strong>A</strong></summary>

### Question 35

A professional sports league&#x27;s officiating analytics team is validating a multi-step rules assistant built with Strands Agents. The assistant invokes statistics and rulebook tools, and the CI pipeline replays one synthetic session at a time from OpenTelemetry trace data before each deployment. The team needs caller-initiated scoring that returns results directly to the pipeline and compares the final agent response to an SME-approved expected response.<br>Which evaluation approach will meet these requirements?

> **Answer:** A

#### A. Call the Amazon Bedrock AgentCore Evaluations Evaluate API with OpenTelemetry sessionSpans, set evaluatorId to Builtin.Correctness, and pass expectedResponse values in evaluationReferenceInputs.

✅ **Correct**

> **Explanation:** This approach uses the on-demand scoring path, which is synchronous and caller initiated for a single session. The Evaluate API accepts OpenTelemetry trace input through sessionSpans, and Builtin.Correctness uses expectedResponse as its ground-truth reference.

#### B. Start a batch Amazon Bedrock AgentCore Evaluations job over CloudWatch Logs, set evaluatorId to Builtin.Correctness, and pass expectedResponse values in evaluationReferenceInputs.

❌ Incorrect

> **Explanation:** Batch evaluation is caller initiated but asynchronous and evaluates multiple sessions discovered from CloudWatch Logs. It is not the best fit for failing a pull request immediately, and AWS documents batch ground truth through sessionMetadata rather than evaluationReferenceInputs.

#### C. Create an online Amazon Bedrock AgentCore Evaluations configuration from application traces, set evaluatorId to Builtin.Correctness, and pass expectedResponse values in evaluationReferenceInputs.

❌ Incorrect

> **Explanation:** Online evaluation is intended for continuous, event-driven production monitoring rather than a caller-initiated CI check that returns synchronously. AWS documents that online evaluation does not support ground truth, so expectedResponse references do not fit this evaluation type.

#### D. Call the Amazon Bedrock AgentCore Evaluations Evaluate API with CloudWatch log events only, set evaluatorId to Builtin.Correctness, and pass expectedResponse values in sessionMetadata.

❌ Incorrect

> **Explanation:** The on-demand Evaluate API requires sessionSpans containing spans and corresponding events, not only raw log events. For on-demand evaluation, reference data is supplied through evaluationReferenceInputs, while sessionMetadata is associated with batch evaluation ground truth.

</details>

---

<details>
<summary><strong>Question 36</strong> — Answer: <strong>D</strong></summary>

### Question 36

A maritime logistics firm&#x27;s operations AI team runs an Amazon Bedrock assistant by using the Converse API through the bedrock-runtime endpoint. Each request contains small structured inputs and asks the model to return one of three short JSON decisions. During port congestion events, the workload receives token-based throttling even though most completed responses contain fewer than 150 tokens. The application sets maxTokens to 4,096 on every request to avoid truncation. The team must improve completed requests per minute while continuing to use the same model, the same Converse API integration, and on-demand throughput.<br>Which action will MOST directly improve throughput under these constraints?

> **Answer:** D

#### A. Increase client-side concurrency for the Converse calls, and retry throttled requests with exponential backoff.

❌ Incorrect

> **Explanation:** Retries with backoff are useful for resiliency when throttling occurs. Increasing concurrency can increase simultaneous token reservations and can make token-based throttling worse rather than improving sustained throughput.

#### B. Use a cross-Region inference profile for the Converse calls, and keep the 4,096-token ceiling for every request.

❌ Incorrect

> **Explanation:** Cross-Region inference can help supported on-demand traffic use model capacity across multiple Regions. It does not directly reduce the excessive token reservation created by the oversized maxTokens setting on each request.

#### C. Enable response streaming for the existing Converse calls, and keep the 4,096-token ceiling for every request.

❌ Incorrect

> **Explanation:** Streaming can improve perceived responsiveness because users can receive output earlier. It does not remove the initial token quota reservation pressure caused by an unnecessarily high maxTokens value.

#### D. Set task-specific maxTokens ceilings for the short JSON responses, and trim oversized prompt context before invocation.

✅ **Correct**

> **Explanation:** This is correct because Amazon Bedrock reserves token quota when the request starts by considering the input tokens plus the configured max_tokens value. A large maxTokens setting can reduce admitted throughput even when the model usually generates short responses.

</details>

---

<details>
<summary><strong>Question 37</strong> — Answer: <strong>A</strong></summary>

### Question 37

An auto insurance carrier&#x27;s claims intelligence team is building a RAG application on Amazon Bedrock. The ingestion backlog includes photos of completed claim forms, PDF repair estimates with tables, recorded adjuster-customer calls, and CSV policy exports. The team must create structured artifacts in Amazon S3 for FM consumption, preserve table and layout context from documents, improve recognition of insurer-specific terms in calls, redact PII from call transcripts before indexing, and avoid maintaining custom OCR or ASR code. The team already has lightweight CSV normalization logic packaged in a Python container and wants to reuse it without building a Spark ETL pipeline.<br>Which workflow will meet these requirements with the LEAST operational overhead?

> **Answer:** A

#### A. Use Amazon Bedrock Data Automation blueprints for claim photos and PDF estimates, use Amazon Transcribe with custom vocabulary and PII redaction for calls, and run SageMaker Processing with the existing container for CSV policy extracts.

✅ **Correct**

> **Explanation:** Correct. Bedrock Data Automation is designed to extract structured artifacts from documents and images for downstream GenAI workflows, including preserving useful document context. Amazon Transcribe custom vocabulary and PII redaction address the speech-specific requirements, while SageMaker Processing can run the existing containerized CSV normalization logic as a managed job.

#### B. Use Amazon Textract AnalyzeDocument for claim photos and PDF estimates, use Amazon Transcribe with custom vocabulary and PII redaction for calls, and run SageMaker Processing with the existing container for CSV policy extracts.

❌ Incorrect

> **Explanation:** Incorrect. Textract can extract text, forms, tables, and layout information from documents, so this is a plausible managed approach for the document inputs. However, the team would still need more post-processing to assemble FM-ready artifacts across claim photos and repair estimates than with Bedrock Data Automation blueprints.

#### C. Use Amazon Bedrock Data Automation blueprints for claim photos and PDF estimates, use Amazon Transcribe with custom vocabulary and PII redaction for calls, and run an AWS Glue Python job for CSV policy extracts.

❌ Incorrect

> **Explanation:** Incorrect. This workflow uses the right managed services for the document, image, and call inputs, and AWS Glue can process tabular data into S3. However, it adds an ETL service path for the CSV step instead of reusing the existing containerized normalization logic directly in a managed processing job.

#### D. Use Amazon Bedrock Data Automation blueprints for claim photos and PDF estimates, use Amazon Transcribe with a custom language model and PII redaction for calls, and run SageMaker Processing with the existing container for CSV policy extracts.

❌ Incorrect

> **Explanation:** Incorrect. This workflow uses managed services for all modalities and can improve speech recognition, but a custom language model requires preparing suitable training data and managing a heavier customization lifecycle. For insurer-specific terms such as product names, acronyms, and claim terminology, a custom vocabulary usually meets the stated need with less operational overhead.

</details>

---

<details>
<summary><strong>Question 38</strong> — Answer: <strong>B, C</strong></summary>

### Question 38

A global media streaming platform&#x27;s personalization team operates an Amazon Bedrock FM feature that uses Converse and ConverseStream through the bedrock-runtime endpoint in us-east-1 and eu-west-1. The team must build observability that supports operational dashboards for latency, token use, throttles, errors, and streaming responsiveness. The team also must preserve forensic records with per-request product, tenant, and experiment identifiers. Logs must remain in the same account and Region where inference occurs, and the team wants to avoid parsing attribution values from prompt text.<br>Which combination of steps will meet these requirements? (Select TWO.)

> **Answer:** B, C

#### A. Create CloudWatch dashboards and alarms from CloudTrail API events for invocation volume, latency, token counts, errors, throttles, and TimeToFirstToken.

❌ Incorrect

> **Explanation:** This option is incorrect because CloudTrail is an audit source for API activity, not the native Bedrock runtime metrics stream. It does not replace AWS/Bedrock metrics for latency, token usage, throttling, errors, and streaming responsiveness dashboards.

#### B. Enable Amazon Bedrock model invocation logging in each inference Region to CloudWatch Logs or S3, and send attribution values by using requestMetadata.

✅ **Correct**

> **Explanation:** This option is correct because model invocation logging is configured per account and Region, and supported destinations must be in the same account and Region. requestMetadata is the documented caller-supplied mechanism for adding per-request attribution to invocation log records for Converse and ConverseStream.

#### C. Create CloudWatch dashboards and alarms from AWS/Bedrock runtime metrics for invocation volume, latency, token counts, errors, throttles, and TimeToFirstToken.

✅ **Correct**

> **Explanation:** This option is correct because Amazon Bedrock publishes bedrock-runtime metrics in the AWS/Bedrock namespace. These metrics support operational views of usage, latency, token consumption, throttling, errors, and streaming responsiveness without requiring prompt parsing.

#### D. Export AWS/Bedrock metrics from both Regions to a central dashboard, and use the metric records as the forensic source for prompts, responses, and attribution.

❌ Incorrect

> **Explanation:** This option is incorrect because AWS/Bedrock metrics are appropriate for operational dashboards but are not invocation payload records. Metrics do not provide the request and response data or caller-supplied requestMetadata that model invocation logging can capture.

#### E. Record product, tenant, and experiment IDs in application logs with Bedrock request IDs, and correlate those logs to invocation records during investigations.

❌ Incorrect

> **Explanation:** This option is incorrect because application-side correlation can be useful but does not populate the documented requestMetadata field in Bedrock invocation log records. Relying on separate application logs increases investigation complexity and does not provide the same per-request attribution inside the Bedrock logging schema.

</details>

---

<details>
<summary><strong>Question 39</strong> — Answer: <strong>A, C</strong></summary>

### Question 39

A maritime logistics firm&#x27;s safety analytics team is building an Amazon Bedrock RAG assistant that answers questions from vessel maintenance manuals and incident procedures. The application uses a mix of knowledge base configurations, including managed knowledge bases, and must verify groundedness before returning answers to operations staff. The team wants to preserve source traceability and avoid treating retrieval metadata as a guaranteed factuality signal.<br>Which TWO implementation steps should the team take to reduce hallucinations while meeting these requirements? (Select TWO.)

> **Answer:** A, C

#### A. Use the Retrieve API for managed knowledge bases, evaluate returned chunks and relevance scores, and run semantic similarity checks against the retrieved content.

✅ **Correct**

> **Explanation:** This is correct because the Retrieve API queries a knowledge base and returns retrievalResults that include content, location, metadata, and a relevance score. For managed knowledge bases, the RetrieveAndGenerate API reference directs developers to use AgenticRetrieveStream or Retrieve instead.

#### B. Use the Retrieve API for all knowledge bases, combine relevance scores with source metadata, and approve generated answers when top-ranked chunks match the query.

❌ Incorrect

> **Explanation:** This is incorrect because KnowledgeBaseRetrievalResult.score is documented as the level of relevance of the result to the query, not as evidence that specific generated claims are supported. Relevance scores and metadata can help select candidate evidence, but the workflow still needs a groundedness comparison against the retrieved content.

#### C. Use RetrieveAndGenerate for non-managed knowledge bases, inspect citations with generated response spans and retrieved references, and suppress unsupported answer segments.

✅ **Correct**

> **Explanation:** This is correct because RetrieveAndGenerate can generate a response and return citations that connect response spans to retrieved source references. The citations provide structured grounding metadata that a verification layer can inspect before the application returns an answer.

#### D. Use RetrieveAndGenerate for managed knowledge bases, inspect output text and session identifiers, and approve answers when a session identifier is returned.

❌ Incorrect

> **Explanation:** This is incorrect because RetrieveAndGenerate cannot be used with managed knowledge bases. A session identifier supports session continuity, but it does not verify that the generated answer is grounded in the retrieved sources.

#### E. Use RetrieveAndGenerate for non-managed knowledge bases, require at least one citation, and skip comparison between answer spans and retrieved references.

❌ Incorrect

> **Explanation:** This is incorrect because citations are useful source traceability metadata, but their presence is not an automatic truth guarantee. A groundedness verification system should compare generated response parts with retrieved references rather than accepting any cited answer.

</details>

---

<details>
<summary><strong>Question 40</strong> — Answer: <strong>D, E</strong></summary>

### Question 40

A precision agriculture robotics vendor&#x27;s field-support AI team is building a diagnostic assistant for field technicians. The assistant must follow a structured reasoning loop: call an Amazon Bedrock model to choose the next diagnostic action, invoke existing tool APIs for observations, branch based on the results, and stop safely when a repair recommendation is unsafe. Some repair recommendations require a human engineer to approve the next step, and the approval can take several hours. A single diagnostic session can last several days, and compliance auditors must be able to review the workflow path after completion.<br>Which combination of implementation choices will meet these requirements? (Select TWO.)

> **Answer:** D, E

#### A. Implement the workflow as an Express state machine with CloudWatch Logs enabled, and run model calls, tool calls, and manual approvals from the same ASL definition.

❌ Incorrect

> **Explanation:** This is incorrect because Express Workflows can run for up to 5 minutes, which does not fit diagnostic sessions that can last several days. Express Workflows also support only Request Response service integrations, so they do not meet the callback approval requirement.

#### B. Implement every model and approval step with the .sync pattern, and rely on Step Functions to cancel downstream work whenever an execution is stopped.

❌ Incorrect

> **Explanation:** This is incorrect because the callback pattern, not .sync, is the appropriate integration pattern when an external human review must return a task token. The .sync pattern also has polling and event side effects, and Step Functions cancellation of an integrated task is best effort rather than guaranteed.

#### C. Implement manual approval as a Request Response task that returns an acknowledgement immediately and lets the external approval process finish before the next model call.

❌ Incorrect

> **Explanation:** This is incorrect because the Request Response pattern continues after the initial HTTP response and does not wait for the underlying job or approval process to finish. The workflow could advance without the human approval outcome that is needed for the next reasoning step.

#### D. Implement the reasoning loop as an ASL state machine that uses Task states for model and tool calls, Choice states for loop control, and Fail states for unsafe terminal outcomes.

✅ **Correct**

> **Explanation:** This is correct because Amazon States Language provides the state types needed to make the reasoning, action, observation, and stopping logic explicit. Task states perform work, Choice states decide the next transition, and Fail states stop an execution with an error.

#### E. Implement manual approval as a callback task that passes $$.Task.Token to a same-account component that calls SendTaskSuccess or SendTaskFailure after review.

✅ **Correct**

> **Explanation:** This is correct because the callback integration pattern pauses a Standard workflow until Step Functions receives the task token through SendTaskSuccess or SendTaskFailure. The same-account condition is important because task tokens must be returned by principals in the same AWS account.

</details>

---

<details>
<summary><strong>Question 41</strong> — Answer: <strong>B</strong></summary>

### Question 41

A global architecture firm&#x27;s design-knowledge team stores building codes, project standards, and design-review notes as unstructured files in Amazon S3. The team is building a RAG assistant with Amazon Bedrock. The solution must use a managed Knowledge Bases ingestion path that parses documents, chunks content, creates embeddings, and writes those embeddings to a supported vector index. The platform team has no existing vector database service, wants to minimize new operational ownership, and wants the initial design to remain production ready while the source repository stays in S3.<br>Which approach will BEST meet these requirements?

> **Answer:** B

#### A. Create an Amazon Bedrock knowledge base with an Amazon S3 data source and an RDS storage configuration for a dedicated vector index.

❌ Incorrect

> **Explanation:** This uses a documented S3 data source and a valid Knowledge Bases vector store type. However, it introduces relational database infrastructure for vector storage, which is a poorer fit for minimizing new operational ownership.

#### B. Create an Amazon Bedrock knowledge base with an Amazon S3 data source and an OPENSEARCH_SERVERLESS storage configuration for a dedicated vector index.

✅ **Correct**

> **Explanation:** This uses the managed Knowledge Bases ingestion workflow with the existing S3 repository and a valid storage configuration type. OpenSearch Serverless avoids introducing a separately provisioned relational database or external vector platform for the initial release.

#### C. Create an Amazon Bedrock knowledge base with an Amazon S3 data source and a MONGO_DB_ATLAS storage configuration for a vector index.

❌ Incorrect

> **Explanation:** This uses a documented S3 data source and a valid Knowledge Bases vector store type. However, it introduces an external vector storage platform when the team has no existing vector database service to operate or integrate.

#### D. Create an Amazon Bedrock knowledge base with a custom data source that reads the S3 objects and an OPENSEARCH_SERVERLESS storage configuration.

❌ Incorrect

> **Explanation:** This uses a valid Knowledge Bases storage type and can still rely on the managed embedding and indexing flow. However, using a custom data source adds source integration work when the documents already reside in a supported S3 repository.

</details>

---

<details>
<summary><strong>Question 42</strong> — Answer: <strong>C</strong></summary>

### Question 42

A live sports analytics provider runs a fan-facing commentary assistant on Amazon Bedrock. The assistant uses a specific foundation model that is available in only a subset of AWS Regions. During major events, the provider sees intermittent throttling and wants the assistant to keep generating fresh responses with the same model if the application&#x27;s home Region has a temporary Bedrock capacity issue. The team must minimize routing logic and operational overhead.<br>Which solution best meets these requirements?

> **Answer:** C

#### A. Wrap each Bedrock runtime call in an AWS Step Functions circuit breaker, and return cached commentary until the home Region becomes healthy.

❌ Incorrect

> **Explanation:** Incorrect. A circuit breaker with cached output is a valid graceful degradation pattern, but it does not meet the requirement to keep generating fresh responses with the same model. It also changes the user experience by serving stale content during the disruption.

#### B. Purchase Amazon Bedrock provisioned throughput for the model in the home Region, and increase exponential backoff settings for failed runtime calls.

❌ Incorrect

> **Explanation:** Incorrect. Provisioned throughput can help when predictable capacity is needed in a Region, but it does not provide managed failover across Regions during a home-Region disruption. Longer backoff can reduce retry pressure, but it does not keep the assistant generating fresh responses when regional capacity remains unavailable.

#### C. Invoke the model through an Amazon Bedrock cross-Region inference profile, and update the application to use the profile identifier in existing Bedrock runtime calls.

✅ **Correct**

> **Explanation:** Correct. A cross-Region inference profile lets Amazon Bedrock route supported model invocations across configured destination Regions, which can improve resilience and throughput without custom regional routing. The application can use the profile identifier in Bedrock runtime calls while continuing to target the same supported model.

#### D. Create separate Amazon Bedrock model integrations in each supported Region, and use Route 53 health checks to direct runtime calls to the closest healthy endpoint.

❌ Incorrect

> **Explanation:** Incorrect. This approach adds custom regional routing and operational complexity that the scenario asks to minimize. It also requires the team to manage regional endpoint selection itself instead of using Bedrock-managed routing for supported cross-Region profiles.

</details>

---

<details>
<summary><strong>Question 43</strong> — Answer: <strong>A</strong></summary>

### Question 43

An online gaming studio&#x27;s player-support security team is releasing an Amazon Bedrock chat assistant behind an API. The assistant must reduce FM misuse by screening unsafe requests before inference when possible, detecting prompt attacks in both nonstreaming and streaming model calls, redacting sensitive user data, and validating generated responses before they are returned to clients. The team wants a defense-in-depth design rather than relying on a single safeguard.<br>Which implementation will best meet these requirements?

> **Answer:** A

#### A. Use API Gateway validation and throttling, run a Lambda preprocessor that uses Amazon Comprehend and ApplyGuardrail with source INPUT, invoke Bedrock with guardrail input tags, and run Lambda plus ApplyGuardrail with source OUTPUT before returning responses.

✅ **Correct**

> **Explanation:** Correct. This design layers API controls, custom PII preprocessing, Bedrock Guardrails before and during model use, and output validation after generation. Using guardrail input tags is important for prompt attack filtering with InvokeModel and InvokeModelWithResponseStream.

#### B. Use API Gateway validation and throttling, call ApplyGuardrail with source INPUT for prompt attack checks, run contextual grounding checks against the prompt before invocation, set grounding thresholds to 1, and return masked responses directly.

❌ Incorrect

> **Explanation:** Incorrect. Contextual grounding checks require a grounding source, query, and model response, so they are output-oriented checks rather than prompt-only preprocessing controls. A grounding threshold of 1 is not a valid documented setting.

#### C. Use API Gateway validation and throttling, configure Bedrock denied topics for customer identifiers and word filters for unsafe subjects, invoke Bedrock without guardrail input tags, and run Lambda formatting checks before returning responses.

❌ Incorrect

> **Explanation:** Incorrect. Denied topics are for contextual topic blocking, not for capturing individual words, names, identifiers, or entity types. Omitting guardrail input tags can prevent prompt attack filtering from applying as intended for InvokeModel and InvokeModelWithResponseStream.

#### D. Use API Gateway validation and throttling, invoke Bedrock Guardrails only during model calls, use sensitive information Mask to protect all logs and traces, read ApplyGuardrail action as ALLOW or DENY, and suppress unsafe responses in Lambda.

❌ Incorrect

> **Explanation:** Incorrect. Sensitive information masking does not apply to model invocation logs, and guardrail trace output can contain the original PII value in the match field. ApplyGuardrail returns action values such as NONE and GUARDRAIL_INTERVENED, not ALLOW or DENY.

</details>

---

<details>
<summary><strong>Question 44</strong> — Answer: <strong>D</strong></summary>

### Question 44

A museum archive&#x27;s digital preservation team is building a RAG assistant by using Amazon Bedrock Knowledge Bases. Researchers often submit multi-intent questions that compare preservation guidance across several media types. Profiling shows that a single semantic retrieval call often returns strong results for one part of the question but misses evidence for the other parts. The application already performs final answer generation with a separate Amazon Bedrock model invocation because it must inject a strict JSON response schema and human review metadata.<br>Which approach will improve retrieval effectiveness while preserving application control over final generation?

> **Answer:** D

#### A. Use the Knowledge Bases RetrieveAndGenerate operation with query transformation enabled, return the generated response, and apply the JSON schema in a post-processing Lambda function.

❌ Incorrect

> **Explanation:** RetrieveAndGenerate combines retrieval with response generation, so it does not preserve the application&#x27;s existing final generation control point. A post-processing Lambda can reshape output, but it cannot provide the same control as generating directly with the required schema and metadata in the prompt.

#### B. Use Step Functions to invoke a Lambda function that decomposes the query, call the Knowledge Bases RetrieveAndGenerate operation for each subquery, and pass generated answers to the existing generation prompt.

❌ Incorrect

> **Explanation:** This can answer each subquery, but it adds generation before the application&#x27;s required final generation step. It also passes model-generated text instead of raw retrieved context, which reduces control over grounding and can make final synthesis harder to audit.

#### C. Use a Lambda function to expand the original query into a single broader query, call the Knowledge Bases Retrieve operation once, and pass the returned contexts to the existing generation prompt.

❌ Incorrect

> **Explanation:** Query expansion can help recall, but a single retrieval call can still be dominated by the most semantically prominent part of a multi-intent question. The scenario requires improving coverage across separate comparison targets, so decomposed retrieval is a better fit.

#### D. Use Step Functions to invoke a Lambda function that decomposes the query, call the Knowledge Bases Retrieve operation for each subquery, and pass merged contexts to the existing generation prompt.

✅ **Correct**

> **Explanation:** This approach separates query understanding from final response generation, which preserves the application&#x27;s existing prompt, schema, and review metadata. Calling Retrieve for each focused subquery improves coverage for multi-intent questions because each part can retrieve its own relevant evidence before the application performs synthesis.

</details>

---

<details>
<summary><strong>Question 45</strong> — Answer: <strong>A</strong></summary>

### Question 45

A regional energy utility&#x27;s grid operations AI team runs a multi-tenant incident-analysis assistant on Amazon Bedrock. Each request can include a small alert or several pages of retrieved outage history, so requests per minute has not correlated with throttling or cost. The team needs to allocate per-tenant capacity before model invocation, defer work that would exceed each tenant&#x27;s minute-level token budget, and avoid paying for capacity-estimation calls.<br>Which approach will meet these requirements with the MOST accurate resource allocation?

> **Answer:** A

#### A. Call CountTokens for the selected model with the planned request shape, combine the estimate with the output limit, and admit requests through per-tenant token buckets.

✅ **Correct**

> **Explanation:** This approach uses the model-specific token estimator before inference, which aligns allocation with the actual selected model and request format. Combining estimated input tokens with an output limit gives the admission controller a practical upper bound for minute-level token budgeting.

#### B. Calculate tokens with a shared tokenizer library, combine the estimate with historical averages, and admit requests through per-tenant request-rate buckets.

❌ Incorrect

> **Explanation:** A shared tokenizer can be inaccurate because tokenization is model-specific in Amazon Bedrock. Request-rate buckets also miss the key driver in this scenario, which is highly variable prompt and context length.

#### C. Invoke a smaller Bedrock model to summarize each request, combine the summary length with the output limit, and admit requests through per-tenant token buckets.

❌ Incorrect

> **Explanation:** Summarizing before admission adds an inference call and cost before the system decides whether the tenant has capacity. The summary token length also does not accurately represent the token usage of the original request sent to the selected model.

#### D. Send requests directly with a reduced maxTokens value during busy periods, track throttling responses, and adjust per-tenant request-rate buckets afterward.

❌ Incorrect

> **Explanation:** Reducing the output limit can control completion size, but it does not estimate the prompt and retrieved-context tokens before invocation. Relying on throttling feedback is reactive and does not defer work before model invocation as required.

</details>

---

<details>
<summary><strong>Question 46</strong> — Answer: <strong>B, C</strong></summary>

### Question 46

An emergency roadside assistance network&#x27;s digital dispatch team is adding an Amazon Bedrock based chat assistant to an API Gateway and Lambda application. Drivers may answer required questions over several turns, such as location, vehicle type, and service type. The front-end Lambda functions are stateless. The team has labeled historical chat utterances for supported intents such as towing, lockout, and fuel delivery. The solution must retain session context for about 30 days, route supported intents through auditable workflow states, ask deterministic follow-up questions when required values are missing, avoid managing model infrastructure, and avoid using the FM as the sole controller for workflow branching.<br>Which combination of actions will meet these requirements? (Select TWO.)

> **Answer:** B, C

#### A. Persist session records in ElastiCache for Valkey keyed by user ID and session ID; read recent turns, slot values, and cache expiration before each invocation.

❌ Incorrect

> **Explanation:** Incorrect. ElastiCache can reduce latency for frequently accessed data, but it is not the best system of record for 30-day conversational history and auditable state. Cache eviction, node replacement, and operational cache behavior make it a poor primary store for durable session context.

#### B. Persist session records in DynamoDB keyed by user ID and session ID; read recent turns, slot values, and TTL-controlled history before each Bedrock invocation.

✅ **Correct**

> **Explanation:** Correct. DynamoDB provides durable, low-latency storage for conversation state across stateless Lambda invocations. A TTL attribute can mark old session records for best-effort expiration after the retention window, while the application retrieves the needed context before calling the FM.

#### C. Classify utterances with an Amazon Comprehend custom classifier; route the intent and confidence through a Step Functions workflow that manages clarification branches.

✅ **Correct**

> **Explanation:** Correct. Amazon Comprehend custom classification can use the labeled utterances to produce an intent signal without requiring the team to host model infrastructure. Step Functions can make the branching and clarification workflow explicit, auditable, and easier to operate than embedding workflow state entirely in prompts.

#### D. Store full transcripts as versions in Amazon Bedrock Prompt Management; select the prompt version by session ID before each Bedrock invocation.

❌ Incorrect

> **Explanation:** Incorrect. Amazon Bedrock Prompt Management is intended for creating, storing, and versioning reusable prompt templates, not for maintaining per-user conversation history. Using prompt versions as session records would mix runtime state with template lifecycle management and would not provide a practical chat memory design.

#### E. Classify utterances by prompting the same Bedrock FM for an intent label; route the free-form response through Lambda condition checks for clarification branches.

❌ Incorrect

> **Explanation:** Incorrect. Using an FM to produce an intent label can be useful in some designs, but this scenario requires avoiding the FM as the sole controller for workflow branching. Free-form model output also adds parsing and consistency risk when required-field clarification needs predictable control flow.

</details>

---

<details>
<summary><strong>Question 47</strong> — Answer: <strong>A</strong></summary>

### Question 47

A global architectural design firm&#x27;s knowledge management team is launching a generative AI assistant for employees. The assistant must answer questions from SharePoint, Amazon S3 project archives, and Jira, and must take actions in approved business systems. The firm uses an enterprise identity provider that is already connected to AWS IAM Identity Center. The security team requires per-user authorization to be enforced from the source systems where possible, centralized user and group assignment, and minimal custom code for access-control decisions.<br>Which implementation will BEST meet these requirements?

> **Answer:** A

#### A. Deploy an Amazon Q Business application, connect it to IAM Identity Center, configure supported data connectors and plugins, and assign access by users and groups.

✅ **Correct**

> **Explanation:** This is correct because Amazon Q Business is designed for enterprise assistants that use IAM Identity Center for workforce identity and supported connectors for business data sources. Its data source connectors can use access control information so responses are limited by what the signed-in user is authorized to access.

#### B. Deploy an API Gateway front end, authorize requests with IAM roles, invoke Amazon Bedrock directly from Lambda, and restrict source access with bucket policies.

❌ Incorrect

> **Explanation:** This protects API access to the model, but it does not solve per-user authorization across SharePoint, Jira, and other enterprise systems. Bucket policies also do not represent document-level permissions from SaaS sources, so the design would need significant custom enforcement.

#### C. Deploy an Amazon Bedrock agent, federate users through Amazon Cognito, store document ACLs as vector metadata, and apply retrieval filters in each request.

❌ Incorrect

> **Explanation:** This can be built, but it requires custom ACL synchronization, custom request-time filtering logic, and careful handling of group changes across source systems. It does not provide the same managed enterprise authorization model and connector behavior required for minimal custom code.

#### D. Deploy an Amazon Kendra index, federate users through a SAML identity provider, connect the index to a Bedrock agent, and implement actions through Lambda.

❌ Incorrect

> **Explanation:** Amazon Kendra can support enterprise search patterns and user context filtering, but this design still requires more custom integration to create a full assistant with business actions. It is less aligned with the requirement for centralized assignment and minimal custom access-control decisions.

</details>

---

<details>
<summary><strong>Question 48</strong> — Answer: <strong>C</strong></summary>

### Question 48

A digital banking platform&#x27;s conversational AI team runs a customer-facing assistant on Amazon Bedrock. Red-team testing found harmful language in both user prompts and generated responses, plus jailbreak and prompt leakage attempts. Compliance requires blocking harmful content when the guardrail classification is MEDIUM or HIGH, but allowing LOW classifications to reduce false positives. The team also needs to observe prompt attack detections for 30 days before changing user-visible behavior, and must anonymize PII in text responses.<br>Which configuration will meet these requirements?

> **Answer:** C

#### A. Create an Amazon Bedrock guardrail in the Standard tier. Set Hate, Insults, Sexual, Violence, and Misconduct filters to Medium for prompts only, set Prompt Attack to Block, and configure word filters for PII values.

❌ Incorrect

> **Explanation:** Incorrect. Filtering only prompts does not address harmful model responses, which are part of the stated risk. Word filters are not the same as sensitive information filters, and blocking Prompt Attack does not support observing detections before enforcement.

#### B. Create an Amazon Bedrock guardrail in the Standard tier. Set Hate, Insults, Sexual, Violence, and Misconduct filters to Low for prompts and responses, set Prompt Attack to Block, and set sensitive information filters to Mask.

❌ Incorrect

> **Explanation:** Incorrect. Low filter strength blocks only HIGH classifications, so MEDIUM harmful content would not be blocked. Blocking Prompt Attack would also change user-visible behavior immediately rather than supporting an observation period.

#### C. Create an Amazon Bedrock guardrail in the Standard tier. Set Hate, Insults, Sexual, Violence, and Misconduct filters to Medium for prompts and responses, set Prompt Attack to Detect, and set sensitive information filters to Mask.

✅ **Correct**

> **Explanation:** Correct. Medium filter strength blocks content classified at MEDIUM or HIGH while allowing LOW classifications. Prompt Attack detection is a Standard tier content filter capability, and Mask is the guardrail action that anonymizes detected PII in supported text outputs.

#### D. Create an Amazon Bedrock guardrail in the Standard tier. Set Hate, Insults, Sexual, Violence, and Misconduct filters to High for prompts and responses, add jailbreaks as denied topics, and set sensitive information filters to Block.

❌ Incorrect

> **Explanation:** Incorrect. High filter strength blocks LOW, MEDIUM, and HIGH classifications, which is stricter than the stated tolerance and can increase false positives. Blocking sensitive information replaces content with blocked messaging rather than anonymizing PII with masking tags.

</details>

---

<details>
<summary><strong>Question 49</strong> — Answer: <strong>B, E</strong></summary>

### Question 49

A life sciences contract research organization&#x27;s AI platform team is designing a generative AI gateway on Amazon Bedrock. Internal applications already use Bedrock-native request patterns for chat orchestration and tool use. A newly acquired product uses an OpenAI-compatible SDK and must be onboarded with minimal first-release code changes. The platform team also expects one regulated document-review workload to have steady high volume, while exploratory workloads will remain unpredictable. The architecture must avoid locking all workloads into a single API style and must account for model capability, Regional availability, and throughput planning before production rollout.<br>Which TWO actions should the team include in the architecture? (Select TWO.)

> **Answer:** B, E

#### A. Select the highest-quality text FM in the preferred Region, purchase Provisioned Throughput, and validate endpoint API support during integration testing.

❌ Incorrect

> **Explanation:** Incorrect. Throughput planning should not be separated from model capability, endpoint compatibility, and Regional availability checks. A model that scores well in evaluation can still be unsuitable if it does not support the required API surface or deployment approach in the target Region.

#### B. Evaluate candidate FMs by modality, context window, tool-use support, endpoint API support, Region availability, and on-demand versus Provisioned Throughput needs.

✅ **Correct**

> **Explanation:** Correct. AWS guidance for choosing Amazon Bedrock models includes considering capabilities, supported APIs, Regional availability, and cost or throughput characteristics. This prevents selecting a model that meets quality goals but cannot be used through the required API style or capacity model.

#### C. Standardize every workload on the Converse API by building a gateway adapter that translates OpenAI-compatible requests before model invocation.

❌ Incorrect

> **Explanation:** Incorrect. Converse is a Bedrock-native API and can be a strong choice for many applications, but forcing all OpenAI-compatible traffic through a custom translation layer adds first-release integration work. This also removes the benefit of using Bedrock&#x27;s documented OpenAI-compatible API surface for clients that already depend on that style.

#### D. Route all traffic through InvokeModel with provider-specific payloads, and emulate any missing chat or OpenAI-compatible behaviors inside the gateway.

❌ Incorrect

> **Explanation:** Incorrect. InvokeModel is useful for direct model invocation, but using it as the only integration style pushes API compatibility logic into custom gateway code. This increases maintenance overhead and does not align with the requirement to avoid locking every workload into one API style.

#### E. Use Bedrock-native APIs through the Bedrock Runtime endpoint for internal workloads, and use a documented OpenAI-compatible Bedrock API path for the acquired product.

✅ **Correct**

> **Explanation:** Correct. Amazon Bedrock supports different inference API surfaces, and AWS states that the Bedrock Runtime endpoint remains appropriate for Bedrock-native InvokeModel or Converse use cases. The same application can use both endpoint patterns when different clients need different API compatibility.

</details>

---

<details>
<summary><strong>Question 50</strong> — Answer: <strong>B</strong></summary>

### Question 50

A maritime logistics provider&#x27;s knowledge management team is building an Amazon Bedrock Knowledge Base from vessel maintenance manuals stored in Amazon S3. Users must ask natural language questions and optionally narrow retrieval by vessel class, manual revision date, subsystem, and document owner. The team wants vessel class and subsystem to contribute to semantic context, but revision date and owner must be available only for filtering and must not affect semantic similarity. The solution must avoid custom ingestion code and keep metadata associated with each source document.<br>Which implementation best meets these requirements?

> **Answer:** B

#### A. Create per-document sidecar files in the same S3 location, name each fileName.extension.metadata.json, keep each file under 10 KB, and set includeForEmbedding for all metadata fields.

❌ Incorrect

> **Explanation:** Incorrect. This approach uses the documented sidecar location and naming pattern, but it marks revision date and owner for embedding participation. Those attributes must remain available only for filtering and must not influence semantic similarity.

#### B. Create per-document sidecar files in the same S3 location, name each fileName.extension.metadata.json, keep each file under 10 KB, and set includeForEmbedding only for semantic fields.

✅ **Correct**

> **Explanation:** Correct. Amazon Bedrock Knowledge Bases supports S3 document metadata through a separate sidecar file stored in the same S3 location as the source document and named with the source file name plus .metadata.json. Setting includeForEmbedding selectively lets vessel class and subsystem influence semantic similarity while keeping revision date and owner available as filter metadata only.

#### C. Create per-document sidecar files in the same S3 location, name each fileName.metadata.json, keep each file under 10 KB, and set includeForEmbedding only for semantic fields.

❌ Incorrect

> **Explanation:** Incorrect. The metadata sidecar file name must include the complete source document name, including the original file extension, followed by .metadata.json. Omitting the original extension does not follow the documented naming pattern even though the embedding configuration is otherwise aligned with the requirement.

#### D. Create separate Knowledge Bases for each vessel class and subsystem, store revision date and owner in sidecar files, and route retrieval to the selected Knowledge Base.

❌ Incorrect

> **Explanation:** Incorrect. Separate Knowledge Bases are a real architecture, but this fragments a corpus that requires per-document metadata and optional narrowing across the maintenance library. It also moves vessel class and subsystem handling into application routing rather than using document metadata to improve semantic context during retrieval.

</details>

---

<details>
<summary><strong>Question 51</strong> — Answer: <strong>A, C</strong></summary>

### Question 51

A professional sports league&#x27;s fan engagement AI team runs a public chatbot on Amazon Bedrock by calling the InvokeModel API directly from a backend service. The service builds each prompt from fixed system instructions, retrieved league policy content, and a free-form fan question. Recent red-team tests show attempts to override the system instructions, reveal hidden prompt text, and bypass safety behavior. The team wants runtime defenses that use managed Bedrock capabilities where possible and that block adversarial user input before it reaches the model.<br>Which combination of steps will meet these requirements? (Select TWO.)

> **Answer:** A, C

#### A. Configure the stored guardrail content policy with a Standard tier PROMPT_ATTACK filter, set an appropriate inputStrength, and set inputAction to BLOCK.

✅ **Correct**

> **Explanation:** Correct. Amazon Bedrock Guardrails supports prompt attack detection for jailbreaks, prompt injection, and prompt leakage through a content policy filter of type PROMPT_ATTACK. Because detecting attempts to reveal hidden prompt text maps to prompt leakage, the prompt attack filter must use the Standard tier, and inputAction BLOCK blocks matching user input.

#### B. Configure denied topics and word filters in the guardrail, and rely on those filters to classify prompt injection attempts.

❌ Incorrect

> **Explanation:** Incorrect. Denied topics and word filters can help enforce content policies, but they are not the documented prompt attack detection mechanism. Prompt injection and jailbreak detection require the prompt attack filter rather than relying only on keyword or topic rules.

#### C. Specify the configured guardrail identifier and version on each InvokeModel request, and wrap the fan question in Bedrock guardContent input tags.

✅ **Correct**

> **Explanation:** Correct. The backend must apply the configured guardrail to the runtime request, such as by specifying the guardrail identifier and guardrail version. For InvokeModel and InvokeModelWithResponseStream, Bedrock also requires guardContent tags around user input for prompt attack filtering to apply.

#### D. Redact PII from the fan question with Amazon Comprehend, and rely on the redacted prompt to prevent jailbreak behavior.

❌ Incorrect

> **Explanation:** Incorrect. PII redaction is useful for privacy controls and input sanitization, but it does not classify prompt injection, jailbreak, or prompt leakage attempts. It may be part of a broader defense-in-depth design, but it does not satisfy the runtime adversarial input detection requirement by itself.

#### E. Run adversarial prompt test cases in Step Functions during release validation, and send production prompts without guardContent tags.

❌ Incorrect

> **Explanation:** Incorrect. Automated adversarial testing is valuable for finding regressions before deployment, but it is not a runtime blocking control for live traffic. Sending InvokeModel requests without guardContent tags prevents prompt attack filtering from being applied to the user input in this use case.

</details>

---

<details>
<summary><strong>Question 52</strong> — Answer: <strong>D, E</strong></summary>

### Question 52

A national insurance carrier&#x27;s claims integration team is modernizing an existing service bus that already exposes HTTPS APIs to internal claims systems. The team is adding Amazon Bedrock capabilities through a small adapter service. One integration path will support a claims-assistant chat experience and should make it easy to switch among Bedrock models that support message-style conversations. Another integration path will call specialized Bedrock models for image generation and embedding generation, and those calls must preserve model-specific request parameters. The adapter must avoid routing failures caused by using the wrong Bedrock endpoint or payload contract.<br>Which TWO implementation actions should the team take? (Select TWO.)

> **Answer:** D, E

#### A. Route image and embedding requests through the Converse API so the adapter can use one message schema for every model.

❌ Incorrect

> **Explanation:** This is incorrect because Converse is the consistent interface for models that support messages, not a universal schema for every inference workload. AWS documents Invoke API usage for direct text, image, and embedding generation when model-specific request and response formats are needed.

#### B. Route every request through InvokeModel with a generic cross-model JSON body and omit contentType when accept is JSON.

❌ Incorrect

> **Explanation:** This is incorrect because InvokeModel request bodies are model-specific, so a generic body will not satisfy every selected model contract. The contentType header must be application/json for InvokeModel, while accept defaults to application/json if not specified.

#### C. Route all adapter traffic to the regional bedrock-runtime endpoint by using Chat Completions as the single payload contract.

❌ Incorrect

> **Explanation:** This is incorrect because using a real regional runtime endpoint does not make one API contract valid for every inference pattern. Chat Completions can support compatible chat integrations, but it does not replace InvokeModel when specialized models require model-specific image or embedding payloads.

#### D. Route specialized generation requests to InvokeModel with application/json request bodies that match each selected model schema.

✅ **Correct**

> **Explanation:** This is correct because InvokeModel provides direct model access and uses model-specific request bodies. The InvokeModel operation requires contentType to be application/json, and the adapter should validate payload size and schema before sending requests from enterprise systems.

#### E. Route message-style assistant requests to the regional bedrock-runtime endpoint by using the Converse API for supported chat models.

✅ **Correct**

> **Explanation:** This is correct because the Converse API is documented as a consistent interface across Amazon Bedrock models that support messages. The bedrock-runtime regional endpoint supports Converse, so the adapter can use a stable chat contract while still selecting among supported models.

</details>

---

<details>
<summary><strong>Question 53</strong> — Answer: <strong>A</strong></summary>

### Question 53

A biotech lab&#x27;s regulatory submissions team built an Amazon Bedrock agent that searches internal SOP knowledge bases and invokes Lambda-backed action groups to draft answers for auditors. During a pilot, reviewers see only the final natural-language responses and cannot reconstruct why the agent chose a knowledge base, invoked an action group, or stopped after a failed step. The team wants per-request transparency for reviewers without adding a separate orchestration framework. The team does not need to expose provider-internal foundation model chain-of-thought.<br>Which implementation will meet these requirements?

> **Answer:** A

#### A. Call InvokeAgent with enableTrace set to true. Persist returned trace events with each request and present the final response from chunk.bytes separately from the reviewer trace.

✅ **Correct**

> **Explanation:** This is correct because Amazon Bedrock agent tracing is controlled on the InvokeAgent request by setting enableTrace to true. The trace can show agent orchestration, action group activity, knowledge base steps, and failures, while the final response is returned separately in the chunk object&#x27;s bytes field.

#### B. Attach Automated Reasoning checks to a guardrail. Persist returned findings for each request and present policy-rule feedback as the reviewer trace.

❌ Incorrect

> **Explanation:** This is incorrect because Automated Reasoning checks validate outputs against policy rules and return findings in detect mode. They can provide policy-grounded verification feedback, but they do not trace why an agent selected a knowledge base, called an action group, or encountered a failure.

#### C. Call ConverseStream for the agent workflow. Persist returned reasoningContent blocks for each request and present reasoningText values as the reviewer trace.

❌ Incorrect

> **Explanation:** This is incorrect because reasoningContent is a content block for Converse and ConverseStream model conversations, not an agent orchestration trace. Reasoning content can also be redacted by the model provider, so it should not be treated as a reliable source for reviewer-visible agent step explanations.

#### D. Enable Bedrock model invocation logging to CloudWatch Logs. Persist the logged payloads for each request and present the logged model outputs as the reviewer trace.

❌ Incorrect

> **Explanation:** This is incorrect because model invocation logging is for supported bedrock-runtime operations, such as Converse and InvokeModel, and is not a replacement for Bedrock agent traces. Invocation logs can help with audit and troubleshooting when enabled, but they do not provide the agent orchestration trace needed to reconstruct knowledge base and action group decisions.

</details>

---

<details>
<summary><strong>Question 54</strong> — Answer: <strong>C, E</strong></summary>

### Question 54

A maritime logistics company&#x27;s operations AI team runs an Amazon Bedrock Knowledge Bases RAG application that uses an Amazon S3 data source containing port regulations, vessel handling procedures, and safety bulletins. The S3 objects are updated by multiple upstream systems throughout the day. The team must keep the vector store current, minimize unnecessary embedding-model usage, detect failed refreshes, and avoid creating a second source of truth outside the S3 bucket.<br>Which combination of steps should the team implement? (Select TWO.)

> **Answer:** C, E

#### A. Submit changed S3 documents by using direct document ingestion and run periodic data source syncs to reconcile the bucket later.

❌ Incorrect

> **Explanation:** Incorrect. Direct ingestion is a separate mechanism from syncing an S3 data source, and directly indexed changes are not reflected back into the S3 bucket. Mixing the two approaches for the same S3-backed knowledge base can create drift between the vector store and the S3 source of truth.

#### B. Delete and recreate the knowledge base vector store on a schedule to guarantee that all removed and changed objects disappear.

❌ Incorrect

> **Explanation:** Incorrect. Rebuilding the vector store is unnecessary operational overhead for routine data maintenance. Bedrock Knowledge Bases sync can remove deleted documents and re-index changed documents through its incremental data source processing.

#### C. Run a refresh workflow that starts a data source ingestion job for the knowledge base after source changes are published.

✅ **Correct**

> **Explanation:** Correct. Amazon Bedrock Knowledge Bases data source sync is incremental, but it must be initiated after source content changes. A sync processes documents added, modified, or deleted since the previous sync instead of reprocessing unchanged documents.

#### D. Modify only metadata sidecar files for CSV content when tags change so the next refresh avoids re-ingesting the documents.

❌ Incorrect

> **Explanation:** Incorrect. Metadata-only optimization applies only in limited cases and does not apply to CSV files. When CSV metadata files are updated, the associated CSV files are re-ingested.

#### E. Track each refresh workflow until the ingestion job reaches a terminal successful status before marking the update complete.

✅ **Correct**

> **Explanation:** Correct. The StartIngestionJob operation returns an ingestion job identifier that can be checked by using GetIngestionJob. Waiting for a completed job lets the system detect failures and prevents downstream validation from assuming that re-indexing has finished.

</details>

---

<details>
<summary><strong>Question 55</strong> — Answer: <strong>A</strong></summary>

### Question 55

A museum consortium&#x27;s visitor-experience engineering team is adding a GenAI question-answering feature to an existing web application. The frontend will call an HTTPS microservice and can wait for a complete response. The team wants the least complex serverless integration that preserves a common conversation request pattern when switching among Amazon Bedrock text models that support messages. The API and integration will be deployed with AWS CloudFormation.<br>Which implementation best meets these requirements?

> **Answer:** A

#### A. Create an API Gateway HTTP API with a Lambda proxy integration that specifies payloadFormatVersion 2.0. Grant API Gateway permission to invoke the function, and have Lambda call Converse on bedrock-runtime with bedrock:InvokeModel permission.

✅ **Correct**

> **Explanation:** This meets the requirement for a lightweight serverless HTTPS microservice while preserving a common message-style interface for supported Bedrock models. HTTP API Lambda proxy integrations created with CloudFormation must specify payloadFormatVersion, and API Gateway needs permission in the Lambda resource-based policy.

#### B. Create an API Gateway HTTP API with a Lambda proxy integration that specifies payloadFormatVersion 2.0. Grant API Gateway permission to invoke the function, and have Lambda call Converse on the Amazon Bedrock service endpoint with streaming permission.

❌ Incorrect

> **Explanation:** The API Gateway and Lambda portion is close, but Converse is available on the bedrock-runtime endpoint only. For a complete nonstreaming response through Converse, the required Bedrock permission is bedrock:InvokeModel, not the streaming-specific permission.

#### C. Create an API Gateway REST API with a Lambda proxy integration and a stage deployment. Grant API Gateway permission to invoke the function, and have Lambda call Converse on bedrock-runtime with bedrock:InvokeModel permission.

❌ Incorrect

> **Explanation:** This can front Lambda and call Amazon Bedrock correctly, but it is not the least complex fit for a lightweight RESTful endpoint. AWS positions REST APIs as more customizable and feature-rich, while HTTP APIs are the lower-latency lightweight option for this style of integration.

#### D. Create an API Gateway HTTP API with a Lambda proxy integration that specifies payloadFormatVersion 2.0. Grant API Gateway permission to invoke the function, and have Lambda call InvokeModel with one shared JSON body for all selected models.

❌ Incorrect

> **Explanation:** The HTTP API and Lambda integration pattern is suitable, but the inference call does not meet the common conversation interface requirement. InvokeModel uses model-specific inference parameters in the request body, so one JSON schema should not be assumed to work across all foundation models.

</details>

---

<details>
<summary><strong>Question 56</strong> — Answer: <strong>D</strong></summary>

### Question 56

An online brokerage&#x27;s compliance engineering team uses a generative AI application to draft trade-surveillance case dispositions. Cases above a risk threshold must pause for up to 5 business days until a human reviewer approves or rejects the disposition. The reviewer portal runs in a separate AWS account, but it can call APIs in the workload account. The solution must resume the workflow after the decision, avoid custom polling workers, and keep callback completion within the workload account.<br>Which implementation will meet these requirements with the LEAST custom orchestration code?

> **Answer:** D

#### A. Implement a Standard Step Functions workflow with an activity task. Use an activity worker in the workload account to obtain review tasks and call SendTaskSuccess after reviewer decisions.

❌ Incorrect

> **Explanation:** A Standard Workflow can support the required duration, and activity tasks are a valid Step Functions integration pattern. However, this design adds a custom worker component, while the callback pattern lets the reviewer action resume the workflow through an API endpoint.

#### B. Implement an Amazon Bedrock human model evaluation job with a work team. Store generated dispositions as a JSON Lines prompt dataset in S3 and use evaluator ratings as approvals.

❌ Incorrect

> **Explanation:** Bedrock human evaluation jobs are for rating or comparing model responses, not for pausing and resuming an individual production workflow. They also require evaluation job inputs such as prompt datasets and work teams rather than acting as a transactional approval callback.

#### C. Implement an Express Step Functions workflow with Wait and Choice states around a DynamoDB decision record. Send reviewer links to an API Gateway endpoint in the workload account that invokes Lambda to write the decision.

❌ Incorrect

> **Explanation:** This uses valid Express Workflow states and a valid API-based decision path. However, Express Workflows are limited to 5 minutes, so they cannot support a review window of up to 5 business days.

#### D. Implement a Standard Step Functions workflow with a callback Task state. Send reviewer links to an API Gateway endpoint in the workload account that invokes Lambda to call SendTaskSuccess or SendTaskFailure.

✅ **Correct**

> **Explanation:** This uses the Step Functions callback pattern to pause the workflow until a human decision arrives. Keeping API Gateway, Lambda, and the Step Functions callback API call in the workload account satisfies the same-account task token requirement.

</details>

---

<details>
<summary><strong>Question 57</strong> — Answer: <strong>C, D</strong></summary>

### Question 57

A precision agriculture equipment manufacturer’s connected-equipment AI team is choosing Amazon Bedrock foundation models for a field-support assistant. The assistant must answer text questions, stream responses to mobile clients, call application tools when needed, run in approved production Regions, and avoid models that could create near-term migration risk. Executives want a defensible selection process that weighs business quality, operational fit, and cost instead of relying only on public benchmark rankings.<br>Which TWO actions should the team take to select foundation models that best align with these requirements? (Select TWO.)

> **Answer:** C, D

#### A. Run a latency and token-cost bakeoff by using Converse-compatible prompts for models with tool use, then prioritize the fastest acceptable response profile.

❌ Incorrect

> **Explanation:** Incorrect. Using a common Converse-based test can make part of the comparison more consistent for models that support it, and latency and token cost are valid considerations. However, this approach does not fully evaluate workload quality, approved Region availability, lifecycle risk, inference type fit, or model-specific request behavior.

#### B. Use ListFoundationModels as the only selection source, then rank candidates by context window, service tier, quotas, and model-specific inference parameters.

❌ Incorrect

> **Explanation:** Incorrect. ListFoundationModels is useful for programmatic discovery, but it does not return every selection criterion, such as all catalog details, quotas, service tiers, context windows, or full parameter guidance. Treating it as the only source would miss important compatibility and operating constraints.

#### C. Build a candidate matrix from Bedrock model documentation and discovery APIs that compares modalities, API support, Region availability, inference types, and lifecycle status.

✅ **Correct**

> **Explanation:** Correct. Bedrock model selection requires checking more than general quality rankings, including modalities, endpoints and APIs, Region availability, inference support, and lifecycle state. The discovery APIs help programmatically shortlist models, while the model catalog provides details that the API response does not include.

#### D. Run Bedrock evaluation jobs on representative prompt datasets, then compare evaluation results with measured latency, throughput needs, and pricing for the shortlisted models.

✅ **Correct**

> **Explanation:** Correct. Bedrock evaluations provide a structured way to compare candidate models using automatic, human, or judge-based evaluation methods. Combining those quality results with operational measurements and pricing supports a balanced business and technical decision.

#### E. Use public benchmark results and Bedrock model cards to seed a shortlist, then choose the lowest priced model that supports text output and streaming.

❌ Incorrect

> **Explanation:** Incorrect. Public benchmarks and model cards can help create an initial shortlist, but choosing mainly on price and basic response capability skips workload-specific quality validation. This approach can also miss tool-use support, approved Region constraints, lifecycle status, and throughput requirements that affect production fit.

</details>

---

<details>
<summary><strong>Question 58</strong> — Answer: <strong>A, B</strong></summary>

### Question 58

A pharmaceutical manufacturing platform team operates a generative AI service that creates regulated document summaries for several internal applications. The service currently invokes one Amazon Bedrock text model, but the team must support multiple Bedrock models and one approved external model provider. The team needs to change routing by document type, tenant, cost tier, or temporary provider outage without redeploying client applications or changing application code. The public request and response contract must remain stable across providers.<br>Which combination of steps will meet these requirements? (Select TWO.)

> **Answer:** A, B

#### A. Store provider endpoints, model identifiers, routing rules, and failover flags in AWS AppConfig, and have the Lambda adapter load validated configuration at runtime.

✅ **Correct**

> **Explanation:** Correct. AWS AppConfig is designed for controlled runtime configuration changes, including validation and deployment strategies. Keeping routing and provider selection outside the code allows operators to change model choices without redeploying Lambda or client applications.

#### B. Front the inference service with Amazon API Gateway and route requests to an AWS Lambda provider adapter that normalizes provider-specific requests and responses.

✅ **Correct**

> **Explanation:** Correct. API Gateway provides a stable public API contract while Lambda can encapsulate provider-specific invocation details behind that contract. This lets clients keep the same request and response schema even when the backend model or provider changes.

#### C. Configure separate API Gateway stages for each provider, and require client applications to select the stage that matches the desired model backend.

❌ Incorrect

> **Explanation:** Incorrect. API Gateway stages can separate environments or configurations, but pushing provider selection to clients breaks the requirement for a stable provider-neutral contract. It also makes outage failover and tenant-specific routing dependent on client behavior rather than centralized policy.

#### D. Store provider choices in Lambda environment variables, and publish a new Lambda version whenever the selected model or endpoint changes.

❌ Incorrect

> **Explanation:** Incorrect. Lambda environment variables are configuration, but changing them and publishing versions is still an operational deployment path for provider selection. This approach is less flexible for frequent routing, failover, or tenant-specific changes than runtime configuration managed through AppConfig.

#### E. Configure Amazon Bedrock prompt routing for all requests, and pass the selected provider name from each client as the model identifier.

❌ Incorrect

> **Explanation:** Incorrect. Bedrock prompt routing can help choose among supported Bedrock model options, but it does not provide a general abstraction for an external HTTPS model provider. Requiring clients to pass provider-specific identifiers also exposes backend selection details to applications.

</details>

---

<details>
<summary><strong>Question 59</strong> — Answer: <strong>D</strong></summary>

### Question 59

A regional airline&#x27;s customer care team is deploying a generative AI assistant that drafts responses to passenger complaints. The assistant uses a supported text foundation model in Amazon Bedrock through the Converse API. The airline&#x27;s responsible AI policy requires inline enforcement before any draft is shown to an agent: disallowed compensation advice must be blocked, profanity and unsafe content must be filtered, PII in generated drafts must be masked, and the selected FM&#x27;s intended use, limitations, and evaluation results must be documented for governance review. The solution must minimize custom ML development and must fail closed when automated compliance checks do not pass.<br>Which implementation best meets these requirements?

> **Answer:** D

#### A. Configure inline Comprehend PII detection and regex filters for production Converse API calls, maintain a model card for the approved FM, and use a Lambda wrapper to block drafts that fail validation.

❌ Incorrect

> **Explanation:** Incorrect. Amazon Comprehend PII detection and regex filters can support inline checks for some sensitive strings and known policy phrases. They do not provide the full set of managed Bedrock guardrail controls for denied topics, harmful content categories, word filters, and sensitive information handling across supported model interactions.

#### B. Configure policy-focused prompt templates for production Converse API calls, maintain a model card for the approved FM, and use a Lambda wrapper to block drafts that fail validation.

❌ Incorrect

> **Explanation:** Incorrect. Prompt instructions can reduce unwanted behavior, but they are not a reliable enforcement boundary for prohibited topics, unsafe content, profanity, or PII handling. The Lambda wrapper can block detected failures, but without guardrails or equivalent managed policy controls it must implement too much of the responsible AI policy itself.

#### C. Configure an Amazon Bedrock guardrail for production invocations, record evaluation scorecards for the approved FM, and use a Lambda wrapper to block drafts that fail validation.

❌ Incorrect

> **Explanation:** Incorrect. This approach uses inline guardrail enforcement and fail-closed release logic, but evaluation scorecards alone do not satisfy the governance documentation requirement. The policy requires intended use and limitations to be documented with evaluation results, which is the role of a model card or equivalent governance artifact.

#### D. Configure an Amazon Bedrock guardrail for production invocations, maintain a model card for the approved FM, and use a Lambda wrapper to block drafts that fail validation.

✅ **Correct**

> **Explanation:** Correct. Amazon Bedrock guardrails provide inline controls for denied topics, content filtering, word filtering, and sensitive information handling for supported model invocations. A model card documents intended use, limitations, and evaluation results, while Lambda can enforce fail-closed application logic before a draft is released.

</details>

---

<details>
<summary><strong>Question 60</strong> — Answer: <strong>A</strong></summary>

### Question 60

A regional electric utility&#x27;s grid reliability AI team is implementing an Amazon Bedrock based assistant that recommends restoration actions during outages. Each request can go through several plan, tool-call, and revise cycles. Tools are AWS Lambda functions that read operational APIs. Safety reviewers require the workflow to stop after a fixed maximum number of cycles or after a high-risk tool result, prevent the FM path from accessing anything except approved read APIs, and avoid repeatedly calling an unhealthy operational API for several minutes after consecutive failures. The team wants a serverless design with explicit execution history and minimal custom orchestration code.<br>Which implementation best meets these requirements?

> **Answer:** A

#### A. Build an AWS Step Functions Standard workflow that tracks cycle count and risk flags with Choice and Fail states; invoke Lambda tool adapters with configured timeouts; store circuit-breaker state in DynamoDB; apply least-privilege IAM roles to each adapter.

✅ **Correct**

> **Explanation:** This approach uses Step Functions to make the planning loop explicit and to enforce deterministic stopping conditions through workflow state. Lambda timeouts bound individual tool calls, DynamoDB can hold shared circuit-breaker state across executions, and least-privilege IAM roles constrain each tool adapter.

#### B. Build a Lambda orchestrator that maintains the plan and revise loop in memory; invoke the same tool adapters with configured timeouts; cache failed API names in the execution context; attach a shared read-only IAM role.

❌ Incorrect

> **Explanation:** A Lambda orchestrator can implement loops, but the control logic and audit trail are hidden inside custom code rather than represented as workflow state transitions. The Lambda execution context is not a durable shared circuit-breaker store, and a shared role weakens per-tool resource boundaries.

#### C. Build an Amazon Bedrock agent with action groups for each tool; define parameter schemas and confirmation prompts; invoke Lambda action handlers with configured timeouts; attach least-privilege IAM roles and enable Bedrock Guardrails.

❌ Incorrect

> **Explanation:** Bedrock Agents action groups are appropriate for tool use, and guardrails can help control content, but this option does not provide deterministic workflow-level stopping after a fixed number of cycles. Guardrails also do not implement a downstream API circuit breaker based on consecutive operational failures.

#### D. Build a Step Functions Express workflow that uses Retry and Catch handlers around each tool call; invoke Lambda adapters with configured timeouts; alarm on downstream failures in CloudWatch; throttle invocations by adjusting reserved concurrency.

❌ Incorrect

> **Explanation:** Retry and Catch handlers are useful for transient failures, but they do not by themselves implement an open circuit that suppresses calls to one unhealthy downstream API for several minutes. Reserved concurrency throttles Lambda capacity broadly and does not enforce the stated maximum planning cycles or high-risk stop condition.

</details>

---

<details>
<summary><strong>Question 61</strong> — Answer: <strong>B</strong></summary>

### Question 61

A regional pharmacy benefits manager&#x27;s clinical AI team is standardizing an Amazon Bedrock assistant that drafts prior authorization summaries. Three internal applications will call the same chat model by using the Converse API. The team must centralize reusable role instructions, support runtime substitution of case details, keep JSON formatting guidance consistent across applications, maintain prompt versions for controlled rollout, and enforce responsible AI controls outside the prompt text.<br>Which implementation will meet these requirements with the LEAST duplication?

> **Answer:** B

#### A. Create a versioned managed prompt in Prompt Management with both chat and text PromptTemplateConfiguration sections, and select the needed template in each request. Invoke the prompt ARN with Converse by passing promptVariables, and enforce safety with a separate Guardrail.

❌ Incorrect

> **Explanation:** PromptTemplateConfiguration is a union, so a managed prompt template configuration can specify only one of chat or text. This design tries to combine both template types in the same configuration, which does not match the documented API structure.

#### B. Create a versioned chat prompt in Prompt Management with system instructions, messages that use {{caseSummary}} variables, and JSON formatting instructions. Invoke the prompt ARN with Converse by passing promptVariables, and enforce safety with a separate Bedrock Guardrail.

✅ **Correct**

> **Explanation:** This uses Prompt Management for the reusable instruction framework, including versioning, variables, system behavior, and response formatting guidance. It also keeps safety enforcement separate by using Bedrock Guardrails rather than relying on prompt wording as the control mechanism.

#### C. Create a versioned chat prompt in Prompt Management with system instructions, messages that define 25 inputVariables for all policy fields and response sections, and JSON formatting instructions. Invoke the prompt ARN with Converse, and enforce safety with a separate Guardrail.

❌ Incorrect

> **Explanation:** This is close to the required pattern, but it exceeds the documented limit for inputVariables in a chat prompt template. A ChatPromptTemplateConfiguration supports inputVariables with a maximum of 20, so the variable design must be consolidated or split.

#### D. Create a versioned chat prompt in Prompt Management with system instructions, messages that use {{caseSummary}} variables, and JSON formatting instructions. Invoke the prompt ARN with Converse, and override inferenceConfig and additionalModelRequestFields per application.

❌ Incorrect

> **Explanation:** This approach centralizes the prompt, but it misuses the Converse request when invoking a managed prompt by ARN. When using a Prompt Management prompt with Converse, fields such as inferenceConfig and additionalModelRequestFields should not be included in the request.

</details>

---

<details>
<summary><strong>Question 62</strong> — Answer: <strong>B</strong></summary>

### Question 62

A renewable energy grid operator&#x27;s AI reliability team is evaluating a generative AI assistant that drafts incident summaries from operator notes. The team has three Amazon Bedrock foundation models and two prompt versions under consideration. The team must compare the candidates against the same benchmark dataset, include automated and human quality judgments, account for token usage and latency, and expose only a limited production cohort before choosing the final configuration.<br>Which evaluation strategy will meet these requirements with the LEAST operational overhead?

> **Answer:** B

#### A. Invoke each model and prompt against the shared benchmark dataset with Bedrock automated evaluation metrics, record CountTokens and CloudWatch latency data by variant, then canary the top variant while collecting clickstream feedback.

❌ Incorrect

> **Explanation:** This approach uses the shared benchmark dataset, captures token and latency signals, and limits production exposure with a canary. It omits human quality judgments, which are important for subjective summary quality factors such as usefulness, tone, and operational suitability.

#### B. Create Bedrock model evaluation jobs for each model and prompt on the shared dataset with automated metrics and human review, add CountTokens and CloudWatch measurements to score price performance, then canary the selected variant while capturing feedback.

✅ **Correct**

> **Explanation:** This approach uses managed Bedrock evaluation capabilities to compare candidate models and prompts against the same dataset, including automated metrics and human evaluation. CountTokens and CloudWatch add token and latency data for price-performance analysis, and a canary limits production exposure while feedback is collected.

#### C. Create Bedrock model evaluation jobs for each model and prompt on the shared dataset with automated metrics and human review, add CountTokens and CloudWatch measurements to score price performance, then fully deploy the highest-scoring variant.

❌ Incorrect

> **Explanation:** This approach satisfies the offline comparison, human judgment, and price-performance portions of the requirement with relatively low operational overhead. It is incomplete because it promotes a variant directly to full production instead of validating it with a limited production cohort first.

#### D. Run an A/B test that samples a limited production cohort across all model and prompt combinations, collect user ratings with API Gateway and DynamoDB, use CloudWatch and CountTokens to rank price performance, then promote the best variant.

❌ Incorrect

> **Explanation:** This approach provides real production feedback from a limited cohort and can capture cost and latency signals by variant. It does not provide the same controlled benchmark comparison with automated quality judgments before live exposure, so production traffic becomes the primary test mechanism.

</details>

---

<details>
<summary><strong>Question 63</strong> — Answer: <strong>B</strong></summary>

### Question 63

A municipal benefits agency&#x27;s caseworker platform team is building an Amazon Bedrock based assistant that summarizes eligibility case notes stored in Amazon S3 and accepts free text follow-up questions from staff. The case files and questions can include names, government identifiers, phone numbers, and bank account details. The agency requires a managed way to identify sensitive data in stored source files, redact sensitive entities from free text before any FM invocation, reduce the chance that sensitive values appear in generated answers, and delete prompt and response artifacts after 30 days. The team wants to avoid training or operating a custom PII model.<br>Which architecture best meets these requirements?

> **Answer:** B

#### A. Configure Amazon Macie sensitive data discovery for source S3 buckets. Use API Gateway request validation with a JSON schema to reject malformed user text before invocation. Apply an Amazon Bedrock guardrail with denied topics and word filters to mask PII in responses. Configure S3 Lifecycle expiration on prompt and response artifact buckets.

❌ Incorrect

> **Explanation:** API Gateway request validation can enforce request shape, required fields, and schema constraints, but it does not perform named entity PII redaction. Denied topics and word filters are not the Bedrock guardrail feature designed to identify and mask sensitive information such as PII.

#### B. Configure Amazon Macie sensitive data discovery for source S3 buckets. Use a Lambda preprocessor with Amazon Comprehend PII detection to redact user text before invocation. Apply an Amazon Bedrock guardrail with sensitive information filters to mask PII in responses. Configure S3 Lifecycle expiration on prompt and response artifact buckets.

✅ **Correct**

> **Explanation:** This approach uses managed services at the correct points in the data flow. Macie discovers sensitive data in S3, Comprehend supports PII detection for runtime text redaction, Bedrock guardrails can apply sensitive information filters to model interactions, and S3 Lifecycle expiration enforces the 30-day retention requirement.

#### C. Configure Amazon Macie sensitive data discovery for source S3 buckets. Use a Lambda preprocessor with Amazon Comprehend PII detection to redact user text before invocation. Apply an Amazon Bedrock guardrail with sensitive information filters to mask PII in responses. Configure S3 Object Lock retention on prompt and response artifact buckets.

❌ Incorrect

> **Explanation:** This design uses appropriate managed controls for S3 discovery, pre-invocation redaction, and response filtering. However, S3 Object Lock retention prevents deletion or overwrite during a retention period and does not automatically delete artifacts after 30 days.

#### D. Configure Amazon Comprehend asynchronous analysis jobs for source S3 buckets. Use a Lambda preprocessor with Amazon Macie findings to redact user text before invocation. Apply an Amazon Bedrock guardrail with sensitive information filters to mask PII in responses. Configure S3 Lifecycle expiration on prompt and response artifact buckets.

❌ Incorrect

> **Explanation:** Amazon Comprehend can analyze text, but Amazon Macie findings are generated from supported data sources such as S3 objects and are not an inline redaction mechanism for arbitrary user input. This design does not reliably redact free text before the FM invocation.

</details>

---

<details>
<summary><strong>Question 64</strong> — Answer: <strong>A</strong></summary>

### Question 64

A clinical research consortium&#x27;s patient engagement team is building a low-latency chat assistant with Amazon Bedrock Converse for English and Spanish messages. User prompts and model responses can contain names, email addresses, phone numbers, patient IDs, and study-specific identifiers that match internal patterns. The assistant must preserve utility by masking sensitive values rather than dropping whole conversations, must protect both user input and text responses, and must retain safety audit records without storing raw identifiers in model invocation logs or guardrail trace fields. Batch-only redaction is not acceptable.<br>Which implementation best meets these requirements?

> **Answer:** A

#### A. Configure an Amazon Bedrock guardrail with sensitive information filters and custom regex filters, apply masking during inference, keep model invocation logging disabled for this workload, and store sanitized audit fields that omit original matches.

✅ **Correct**

> **Explanation:** Correct. Amazon Bedrock Guardrails can mask built-in PII and custom regex matches in user input and text model responses while preserving placeholders such as PII type names. Model invocation logging and guardrail trace match values require separate handling because guardrail masking does not sanitize those stored records.

#### B. Configure an Amazon Bedrock guardrail with sensitive information filters and custom regex filters, apply masking during inference, enable model invocation logging for this workload, and archive complete guardrail traces for audit review.

❌ Incorrect

> **Explanation:** Incorrect. Bedrock model invocation logging can collect request data, response data, and metadata when it is enabled, so it is not safe to assume guardrail masking removes all sensitive values from logs. Guardrail trace fields for PII matches can contain the original PII value, which conflicts with the requirement to avoid storing raw identifiers.

#### C. Call Amazon Comprehend DetectPiiEntities synchronously and custom regex filters before and after Converse, mask detected spans in application code, keep model invocation logging enabled, and store the logs for audit.

❌ Incorrect

> **Explanation:** Incorrect. DetectPiiEntities returns offsets that can support real-time masking logic for supported text, and custom regex can cover internal identifiers. However, model invocation logging can still capture model response data before application post-processing, which conflicts with the requirement to avoid storing raw identifiers in logs.

#### D. Call Amazon Comprehend ContainsPiiEntities synchronously for each user message, replace returned PII labels with placeholders, invoke the model without a guardrail, and log transformed prompts and responses for audit.

❌ Incorrect

> **Explanation:** Incorrect. ContainsPiiEntities returns PII labels with scores, not offsets for each occurrence, so it is not sufficient to replace individual sensitive values in the text. This approach also does not apply the same protection to model responses unless additional processing is added.

</details>

---

<details>
<summary><strong>Question 65</strong> — Answer: <strong>B</strong></summary>

### Question 65

A luxury hotel chain&#x27;s guest experience platform team is enhancing its CRM with a generative AI summary for each guest-service interaction. The CRM integration writes a compact event containing the interaction ID and transcript pointer to an Amazon SQS queue. A Lambda function calls Amazon Bedrock, writes the summary back to the CRM, and completes well within the Lambda timeout. The CRM API supports an idempotency key. Traffic arrives in bursts, summaries do not need to be returned to the original CRM request, and the team must minimize operational overhead while preventing duplicate CRM updates.<br>Which implementation should the team use?

> **Answer:** B

#### A. Configure an Amazon SQS event source mapping for the Lambda function. Treat batch delivery semantics as sufficient to prevent duplicate CRM summary writes.

❌ Incorrect

> **Explanation:** An SQS event source mapping is appropriate for the queue-based workload, but its delivery semantics are at least once. Treating batch delivery as duplicate prevention is unsafe because the same record can be processed more than once.

#### B. Configure an Amazon SQS event source mapping for the Lambda function. Use the interaction ID as the idempotency key when writing the CRM summary.

✅ **Correct**

> **Explanation:** This fits an asynchronous queue-based integration where Lambda polls SQS and invokes the function with batches. Because event source mappings process records at least once, using the interaction ID as an idempotency key protects the external CRM update from duplicate processing.

#### C. Invoke the Lambda function from the integration layer with InvocationType=Event. Write each generated summary to the CRM without an idempotency check.

❌ Incorrect

> **Explanation:** InvocationType=Event is asynchronous, but this option bypasses the existing SQS queue polling pattern and ignores duplicate-safe CRM writes. The requirement is not merely to decouple processing, it is also to prevent duplicate CRM updates when records can be processed more than once.

#### D. Invoke the Lambda function from the CRM webhook with InvocationType=RequestResponse. Return the generated summary through the CRM webhook response.

❌ Incorrect

> **Explanation:** RequestResponse is a synchronous Lambda invocation mode, so it holds the webhook flow open until processing finishes. The scenario does not require an immediate response and already uses a queue to absorb bursts, so this approach is a poorer fit for the stated integration pattern.

</details>

---

<details>
<summary><strong>Question 66</strong> — Answer: <strong>A</strong></summary>

### Question 66

An investment research publisher&#x27;s AI governance team is validating a market commentary assistant before a production release. One candidate uses an Amazon Bedrock model, and another candidate runs outside Amazon Bedrock. For the external candidate, the team has already generated responses for a fixed prompt set with expert reference responses. The team needs an automated assessment that goes beyond lexical overlap by scoring qualities such as relevance, factual accuracy, helpfulness, and coherence; includes an explanation for each prompt and response; writes the full report to S3; and does not call the external model during evaluation.<br>Which approach will meet these requirements?

> **Answer:** A

#### A. Create LLM-as-a-judge model evaluation jobs with applicationType ModelEvaluation. Store the prompt dataset and the external candidate&#x27;s single precomputed response per prompt as JSON Lines in S3, select built-in judge metrics, and configure the S3 output destination.

✅ **Correct**

> **Explanation:** Correct. An LLM-as-a-judge model evaluation uses a separate evaluator model to score generator responses and provide an explanation for each prompt and response pair. Amazon Bedrock can evaluate precomputed non-Bedrock responses directly, and the full report is written to the configured S3 destination.

#### B. Create RAG evaluation jobs with applicationType RagEvaluation. Store each candidate answer as retrieved context in the prompt dataset, select retrieve-only metrics, and configure the S3 output destination.

❌ Incorrect

> **Explanation:** Incorrect. RAG evaluation jobs are intended for knowledge bases or RAG sources, with retrieve-only metrics focused on retrieved context rather than standalone model answers. Treating generated answers as retrieved context would not produce the requested model-output assessment.

#### C. Create automatic model evaluation jobs with applicationType ModelEvaluation. Store the prompt dataset and external candidate responses as JSON Lines in S3, select one task type per job, and configure the S3 output destination.

❌ Incorrect

> **Explanation:** Incorrect. Automatic model evaluation jobs are task-based and use documented task and metric mappings such as BERTScore, F1, toxicity, robustness, or RWK rather than a judge model explanation for each response. They also require choosing one task type per job, which does not fit the requested multi-dimensional judge assessment.

#### D. Create LLM-as-a-judge model evaluation jobs with applicationType ModelEvaluation. Store both candidates&#x27; responses in one JSON Lines file with two modelResponses per prompt, select built-in judge metrics, and configure the S3 output destination.

❌ Incorrect

> **Explanation:** Incorrect. This uses the right evaluation mode but violates the prompt dataset constraints for bring-your-own inference responses. A model-as-judge evaluation job supports only one model response for each prompt and one unique modelIdentifier in a job.

</details>

---

<details>
<summary><strong>Question 67</strong> — Answer: <strong>C, D</strong></summary>

### Question 67

A telemedicine provider&#x27;s clinical documentation AI team operates an internal note-drafting service. The API layer is an Amazon API Gateway REST API, AWS Lambda calls the Amazon Bedrock Converse API directly, and the Lambda function writes only unstructured error strings. Support engineers spend hours correlating reports of wrong output, validation exceptions, and latency spikes. The team must improve triage across prompt versions, model invocations, and API hops. The solution must avoid storing raw PHI in logs and must not introduce a separate observability data store.<br>Which TWO actions will meet these requirements? (Select TWO.)

> **Answer:** C, D

#### A. Configure Amazon Bedrock agent tracing for preprocessing, orchestration, postprocessing, and guardrail traces, then use the traces to inspect every Lambda request without changing the direct FM invocation path.

❌ Incorrect

> **Explanation:** Incorrect. Bedrock agent tracing is for requests processed through Agents for Amazon Bedrock, where the service performs orchestration and tool use. The application calls the Converse API directly from Lambda, so agent traces would not capture every request on that path.

#### B. Enable Amazon Bedrock model invocation logging for full request and response payloads in CloudWatch Logs, then use CloudWatch Logs Insights queries to mask PHI values when engineers investigate incidents.

❌ Incorrect

> **Explanation:** Incorrect. Query-time masking does not prevent raw PHI from being stored in CloudWatch Logs. Model invocation logging can be useful for debugging, but the requirement is to avoid storing sensitive raw prompt and response payloads in the first place.

#### C. Enable X-Ray tracing on API Gateway and Lambda, instrument the Lambda AWS SDK client to create downstream Bedrock subsegments, and include the trace or correlation ID in the structured application logs.

✅ **Correct**

> **Explanation:** Correct. X-Ray helps identify where time is spent across API Gateway, Lambda, and downstream AWS SDK calls. Including the same trace or correlation identifier in logs lets engineers pivot between request traces and prompt-level troubleshooting details.

#### D. Emit structured JSON logs from the Lambda function with a correlation ID, prompt version, model ID, sanitized prompt and response attributes, latency, validation outcome, and Bedrock request metadata; analyze the fields with CloudWatch Logs Insights queries.

✅ **Correct**

> **Explanation:** Correct. Structured application logs make prompt version, model choice, validation failures, and latency searchable without requiring a new data store. Sanitizing or summarizing prompt and response attributes before logging helps the team investigate behavior without storing raw PHI.

#### E. Centralize AWS CloudTrail Lake queries for API Gateway, Lambda, and Bedrock events, then use the audit events as the primary source for prompt content, model response, and latency analysis.

❌ Incorrect

> **Explanation:** Incorrect. CloudTrail is designed for auditing API activity, such as who made a call and when, rather than serving as the main source for prompt bodies, model responses, or application-level quality signals. It complements observability, but it does not replace structured application logs and distributed tracing for this scenario.

</details>

---

<details>
<summary><strong>Question 68</strong> — Answer: <strong>C</strong></summary>

### Question 68

A municipal tax software provider runs a nightly generative AI classification workload on Amazon SageMaker AI. The workload reads millions of small JSON Lines records from Amazon S3 and writes the classification results back to Amazon S3. The current transform job sends one record per container request on GPU instances, and monitoring shows low GPU utilization even though GPU memory has significant headroom. The model container can process newline-delimited batches and return one result per input record. The provider wants the job to finish faster while keeping the existing offline processing pattern.<br>Which change will meet these requirements with the LEAST architectural change?

> **Answer:** C

#### A. Deploy a SageMaker Asynchronous Inference endpoint, submit each S3 record as an invocation, and collect the generated outputs in Amazon S3.

❌ Incorrect

> **Explanation:** Asynchronous Inference is useful for queued inference requests and large payloads when responses are not immediate. For a finite offline job that already uses S3 inputs and outputs, it adds endpoint and invocation management instead of optimizing the existing batch transform path.

#### B. Configure SageMaker Batch Transform to keep one record per request, increase the instance count, and keep per-instance concurrency unchanged.

❌ Incorrect

> **Explanation:** This can add parallelism across more instances, but it does not address the underutilization within each GPU instance. It is likely to increase cost before improving the request batching and concurrency that the existing instances can already support.

#### C. Configure SageMaker Batch Transform to use MultiRecord batching, increase MaxConcurrentTransforms, and tune MaxPayloadInMB for the container.

✅ **Correct**

> **Explanation:** This is correct because Batch Transform can send multiple records in each request when the container supports batched input and output. Increasing concurrent transforms and tuning payload size can raise per-instance utilization and throughput without replacing the offline S3-based workflow.

#### D. Deploy a SageMaker real-time endpoint with target tracking scaling, invoke it from parallel Lambda workers, and store responses in Amazon S3.

❌ Incorrect

> **Explanation:** A real-time endpoint is designed for low-latency online inference rather than an offline nightly batch job. Parallel Lambda workers can increase request volume, but this approach adds orchestration overhead and does not use Batch Transform&#x27;s built-in batching controls.

</details>

---

<details>
<summary><strong>Question 69</strong> — Answer: <strong>A</strong></summary>

### Question 69

A maritime logistics provider&#x27;s platform engineering team operates a centralized GenAI gateway that standardizes access to Amazon Bedrock prompts, guardrail checks, audit logging, and client throttling. Product teams submit prompt packages and gateway configuration through Git. The release process must run security, prompt regression, and guardrail integration tests before deployment, publish test results for each run, and automatically recover from a failed non-source deployment stage by returning to the last known good gateway configuration. The team wants to use native AWS CodePipeline and AWS CodeBuild capabilities with minimal custom orchestration and no unsupported rollback behavior.<br>Which implementation will meet these requirements?

> **Answer:** A

#### A. Create a CodePipeline with a source stage, a CodeBuild test action whose buildspec defines one to five report groups, and a deploy stage configured for automatic rollback after a successful baseline execution.

✅ **Correct**

> **Explanation:** This uses CodeBuild test reporting in the supported buildspec-driven model, which creates reports for each build run when one to five report groups are configured. It also uses CodePipeline automatic rollback on a non-source stage after there has been a prior successful execution in that stage, which is required for rollback to a known good stage execution.

#### B. Create a CodePipeline with a source stage configured for automatic rollback, a CodeBuild test action that uploads JUnit reports to S3, and a deploy stage that always reuses the current source revision.

❌ Incorrect

> **Explanation:** CodePipeline does not support rolling back a source stage, so this design relies on unsupported rollback behavior. Uploading JUnit files to S3 can preserve files, but it does not by itself use CodeBuild report groups as the native test reporting mechanism described in the requirement.

#### C. Create a CodePipeline with a source stage, a CodeBuild test action that emits secondary artifacts, and a deploy stage configured with both automatic retry and an onFailure rollback condition.

❌ Incorrect

> **Explanation:** An onFailure condition can use a retry result or a rollback result, but stage failure handling cannot simultaneously use both retry and rollback as the same onFailure result. Secondary artifacts can be useful for packaging test outputs or deployment bundles, but they do not fix the incompatible failure handling configuration.

#### D. Create a CodePipeline with a source stage, a CodeBuild test action whose buildspec defines six report groups, and a deploy stage configured for automatic rollback after the first failed execution.

❌ Incorrect

> **Explanation:** CodeBuild test reporting supports one to five report groups per build project, so defining six report groups is outside the documented limit. Automatic rollback also requires a prior successful execution in the stage, so a first failed execution has no successful stage execution to roll back to.

</details>

---

<details>
<summary><strong>Question 70</strong> — Answer: <strong>D</strong></summary>

### Question 70

A national news publisher&#x27;s editorial AI team is building an internal assistant that prepares article briefs. Each request must run a sequence of FM prompts: extract entities, classify the article topic, generate a short summary, and then choose one of several style prompts based on the classification result. Editors frequently revise the prompt sequence, and the team wants a managed AWS-native implementation that minimizes custom orchestration code while allowing the workflow to be defined and reviewed as configuration.<br>Which implementation will BEST meet these requirements?

> **Answer:** D

#### A. Implement the workflow by using AWS Step Functions Standard Workflows with Lambda tasks that invoke Amazon Bedrock models.

❌ Incorrect

> **Explanation:** Step Functions can orchestrate Lambda functions and service calls, so this design is viable for complex workflows. However, it requires more custom wrapper logic for prompt handoffs, conditional prompt routing, and workflow maintenance than the managed Bedrock workflow feature.

#### B. Implement the workflow by using Strands Agents with specialized agents for entity extraction, classification, and summarization.

❌ Incorrect

> **Explanation:** Strands Agents is useful for building agentic systems with tools, specialized agents, and model interactions. For a frequently revised deterministic prompt chain, it adds application framework code and runtime orchestration that is unnecessary for the stated requirements.

#### C. Implement the workflow by using AWS Agent Squad to route each request among task-specific Bedrock agents.

❌ Incorrect

> **Explanation:** Agent Squad is intended for orchestrating multiple agents and routing requests to the agent that best matches the task. The requirement is to execute a controlled prompt sequence with conditional branching, not to select one agent for an entire request.

#### D. Implement the workflow by using Amazon Bedrock Flows with prompt nodes that invoke models and condition nodes for branching.

✅ **Correct**

> **Explanation:** This approach uses a managed Bedrock orchestration capability that is designed for chaining prompts, models, and conditional logic. It minimizes custom code while allowing the workflow to be created visually or represented as a JSON definition.

</details>

---

<details>
<summary><strong>Question 71</strong> — Answer: <strong>B</strong></summary>

### Question 71

A legal research publisher&#x27;s editorial AI team runs a RAG assistant on Amazon Bedrock Knowledge Bases. The knowledge base is a custom knowledge base backed by a Pinecone vector store. After a large content migration, reviewers report that generated answers often cite paragraphs from the wrong jurisdiction. The team needs to determine whether the retrieval stage is returning poorly ranked chunks before changing prompts or generation settings. The team must keep the existing vector store during troubleshooting.<br>Which approach will MOST directly isolate the retrieval problem?

> **Answer:** B

#### A. Invoke the Retrieve operation with vectorSearchConfiguration metadata filters for jurisdiction and inspect only filtered chunks for the same prompt set.

❌ Incorrect

> **Explanation:** Incorrect. Metadata filters can be useful when the application already knows the intended jurisdiction and wants to constrain retrieval. Applying a jurisdiction filter first would mask whether the unfiltered retrieval stage is ranking the wrong jurisdiction too highly after the migration.

#### B. Invoke the Retrieve operation with vectorSearchConfiguration and inspect retrievalResults content, metadata, location, and score for a fixed test prompt set.

✅ **Correct**

> **Explanation:** Correct. Retrieve returns the source chunks without invoking a foundation model, so the team can evaluate retrieval ranking separately from generation behavior. The returned score, metadata, content, and location provide the evidence needed to diagnose whether the wrong jurisdiction is being retrieved or ranked too highly.

#### C. Invoke the Retrieve operation with overrideSearchType set to HYBRID and compare the returned chunks against semantic-only results for the same prompt set.

❌ Incorrect

> **Explanation:** Incorrect. Hybrid search is documented for an Amazon OpenSearch Serverless vector store that contains a filterable text field. For other custom vector store configurations, such as the stated Pinecone-backed knowledge base, only semantic search is available.

#### D. Invoke the RetrieveAndGenerate operation and inspect the returned citations for each generated answer in the same fixed test prompt set.

❌ Incorrect

> **Explanation:** Incorrect. RetrieveAndGenerate combines retrieval with model generation, so poor answers can come from retrieval quality, prompt behavior, or model synthesis. Citations are useful for traceability, but this path does not isolate the retrieval stage as directly as retrieving chunks and scores.

</details>

---

<details>
<summary><strong>Question 72</strong> — Answer: <strong>D</strong></summary>

### Question 72

An online legal research provider&#x27;s search AI team runs a customer-facing assistant by using Amazon Bedrock ConverseStream with a supported on-demand Claude model. Each request begins with the same long system instructions, citation rules, and jurisdiction taxonomy. The application then appends retrieved case snippets and the user&#x27;s question, which vary for each request. Profiling shows that repeated processing of the shared prompt material is increasing initial response latency and input-token cost. The team wants to reduce latency and cost without changing models or building a separate response cache.<br>Which caching configuration will meet these requirements?

> **Answer:** D

#### A. Move the workload to Amazon Bedrock batch inference, add CachePointBlock objects to each request payload, and use response streaming only for user-visible follow-up requests.

❌ Incorrect

> **Explanation:** Prompt caching is not supported with the Amazon Bedrock batch inference API. Moving the interactive assistant flow to batch inference would not use the documented prompt-caching path for ConverseStream or the invoke APIs.

#### B. Add a Bedrock prompt cache checkpoint after the retrieved snippets and user question, keep the checkpoint ttl at 1h, and rely on Bedrock to reuse the earlier prompt material.

❌ Incorrect

> **Explanation:** This places the checkpoint after retrieved snippets and user input, which are described as changing on each request. Changing the cached prefix in a later request causes a cache miss, so this configuration would provide little reuse for the repeated prompt material.

#### C. Add cache checkpoints every 1,024 tokens throughout the full request, set each CachePointBlock type to default, and use the same checkpoint layout for every supported foundation model.

❌ Incorrect

> **Explanation:** This assumes a universal checkpoint strategy across all supported foundation models. Bedrock prompt-cache limits are model-specific, and the current Claude table includes different minimum token requirements and a maximum checkpoint count per request.

#### D. Add a Bedrock prompt cache checkpoint after the shared instructions, citation rules, and taxonomy, keep that prefix unchanged across requests, and verify it meets the model-specific minimum token count.

✅ **Correct**

> **Explanation:** This uses Amazon Bedrock prompt caching on a supported on-demand model API and places the cache checkpoint at the reusable portion of the prompt. Because Bedrock caches a static contiguous prefix, keeping that prefix unchanged and meeting the model-specific minimum token requirement allows later requests to benefit from the cache.

</details>

---

<details>
<summary><strong>Question 73</strong> — Answer: <strong>C, D</strong></summary>

### Question 73

A global insurance claims platform team runs an interactive claims-assistance application by using Amazon Bedrock Knowledge Bases and a supported foundation model. Users report slow first responses during normal traffic. Amazon CloudWatch shows rare throttling, but high input token counts and elevated time to first token. API profiling shows that most requests reuse a long static claims-handling policy prompt, while retrieval often returns many overlapping passages from prior policy versions.<br>Which combination of actions will improve performance while reducing unnecessary model work? (Select TWO.)

> **Answer:** C, D

#### A. Route every request to a smaller foundation model with prompt routing, and keep the existing retrieved context in each request.

❌ Incorrect

> **Explanation:** Using smaller models can improve cost and latency for simple tasks, but routing every request the same way ignores task complexity. Keeping the oversized retrieved context also preserves the high input token count that is contributing to latency.

#### B. Buy Amazon Bedrock provisioned throughput for the current model, and leave retrieval depth and prompt construction unchanged.

❌ Incorrect

> **Explanation:** Provisioned throughput can help when an application needs predictable reserved model capacity or is constrained by throughput. The stated symptoms point to prompt and retrieval inefficiency rather than throttling or insufficient request capacity, so this leaves the main bottlenecks in place.

#### C. Tune Knowledge Bases retrieval parameters to return fewer metadata-filtered chunks, and use profiling results to remove redundant or obsolete context.

✅ **Correct**

> **Explanation:** This is correct because excessive retrieved context increases input tokens and model processing time. Metadata filtering and smaller retrieval sets can reduce prompt size while improving relevance when older or duplicate policy passages are being included.

#### D. Configure Amazon Bedrock prompt caching for reusable system instructions and shared policy context, and keep changing user input outside the cached prefix.

✅ **Correct**

> **Explanation:** This is correct because prompt caching can reduce repeated processing for static prompt prefixes on supported models. Keeping volatile user content outside the cached portion preserves cache reuse while allowing each request to remain personalized.

#### E. Move the workflow to a SageMaker asynchronous inference endpoint with SQS buffering, and have clients poll for generated answers.

❌ Incorrect

> **Explanation:** Asynchronous inference is useful when users can wait for results and the application does not need an immediate response. This claims-assistance workflow is interactive, and polling would not directly reduce the repeated prompt and retrieval work.

</details>

---

<details>
<summary><strong>Question 74</strong> — Answer: <strong>A</strong></summary>

### Question 74

An international architecture firm&#x27;s AI platform team is launching several internal design-assistant applications on Amazon Bedrock. The firm is not an existing AWS Audit Manager customer. The governance board has approved a standard Bedrock guardrail that includes denied topics and sensitive information filters. Application teams invoke Bedrock directly from their own production roles by using Converse, ConverseStream, InvokeModel, and InvokeModelWithResponseStream. The board wants a control that prevents production callers from bypassing the approved guardrail during inference, while preserving the existing Bedrock runtime APIs and avoiding a custom proxy layer.<br>Which approach best meets these requirements?

> **Answer:** A

#### A. Apply IAM policies to production Bedrock roles that require the approved bedrock:GuardrailIdentifier on supported runtime APIs, and require applications to pass the guardrail version.

✅ **Correct**

> **Explanation:** This approach enforces guardrail use at authorization time for the supported Bedrock runtime APIs in the scenario. Bedrock guardrails are applied during inference only when the request references the guardrail identifier and version, so requiring those values prevents direct callers from omitting the approved guardrail.

#### B. Enable Bedrock model invocation logs for all production accounts, then review prompts and responses to identify teams that bypass the approved guardrail.

❌ Incorrect

> **Explanation:** Model invocation logging can support after-the-fact monitoring, but it does not prevent a production request from bypassing the guardrail. The documentation also notes that blocked content can appear as plain text in model invocation logs when logging is enabled, so logging must be governed carefully.

#### C. Publish the approved guardrail version and document it in the platform standards, then monitor application deployments for teams that omit the guardrail configuration.

❌ Incorrect

> **Explanation:** Publishing and documenting a guardrail creates a standard, but it does not force callers to use that guardrail during inference. A caller can still invoke Bedrock without specifying the guardrail identifier and version unless permissions or application controls prevent that behavior.

#### D. Create an AWS Audit Manager assessment from Generative AI Best Practices Framework v2, then use assessment evidence as the production approval mechanism.

❌ Incorrect

> **Explanation:** AWS Audit Manager is no longer open to new customers, and the scenario states that the firm is not an existing customer. The Generative AI Best Practices Framework v2 helps collect evidence for governance activities, but AWS states that its controls do not verify compliance or guarantee audit success, and it is not a runtime enforcement mechanism.

</details>

---

<details>
<summary><strong>Question 75</strong> — Answer: <strong>C</strong></summary>

### Question 75

A national insurance carrier&#x27;s claims automation team is validating a generative AI assistant that drafts claim denial explanations. The team has two prompt templates stored as versions in Amazon Bedrock Prompt Management and uses the same foundation model for both templates. Before production release, the team must determine whether either prompt produces systematically different quality or tone for claimant cohorts represented in a test set, while minimizing custom model development and preserving operational metrics for compliance review.<br>Which approach will meet these requirements MOST effectively?

> **Answer:** C

#### A. Run an Amazon Bedrock evaluation with an LLM-as-a-judge on a randomized prompt dataset for both prompt versions, and publish aggregate results as CloudWatch metrics.

❌ Incorrect

> **Explanation:** This can compare overall output quality between prompt versions, but aggregate metrics can hide subgroup-specific disparities. A randomized dataset without cohort-level analysis does not satisfy the requirement to identify systematic differences across claimant cohorts.

#### B. Route live traffic between both prompt versions by using Amazon Bedrock Flows, and select the version with the highest overall user satisfaction score.

❌ Incorrect

> **Explanation:** This is a plausible A/B testing pattern, but it evaluates production feedback rather than completing the required pre-release fairness validation. Overall satisfaction scores also do not reliably expose cohort-specific differences in tone or quality.

#### C. Run an Amazon Bedrock evaluation with an LLM-as-a-judge on a stratified prompt dataset for both prompt versions, and publish cohort-level results as CloudWatch metrics.

✅ **Correct**

> **Explanation:** This approach evaluates the actual generative outputs for both prompt versions across defined claimant cohorts. Using an LLM-as-a-judge and cohort-level metrics supports systematic fairness comparison without building a custom evaluation model.

#### D. Run Amazon SageMaker Clarify bias reports on the claims source dataset, and select the prompt version with the lowest class imbalance metric.

❌ Incorrect

> **Explanation:** SageMaker Clarify is useful for bias and explainability analysis in ML workflows, especially around datasets and model predictions. It does not directly compare free-form Bedrock outputs from two prompt versions for cohort-specific differences in generated explanations.

</details>

---
