# AWS Certified AI Practitioner (AIF-C01) — Cheatsheet

**Format:** 65 questions (50 scored + 15 unscored), 90 minutes, $100, passing score 700/1000. No coding required — conceptual/scenario-based.

## Domain Weights
| Domain | Weight |
|---|---|
| 1. Fundamentals of AI and ML | 20% |
| 2. Fundamentals of Generative AI | 24% |
| 3. Applications of Foundation Models | 28% |
| 4. Guidelines for Responsible AI | 14% |
| 5. Security, Compliance, and Governance for AI | 14% |

---

## Domain 1: AI/ML Fundamentals
- **AI** ⊃ **ML** ⊃ **Deep Learning**. Deep learning uses neural networks.
- **Training vs. Inference**: fitting a model vs. using it to predict.
- **Learning types**: Supervised (labeled — classification/regression), Unsupervised (unlabeled — clustering), Reinforcement (reward/penalty).
- **Key metrics**: Accuracy, Precision, Recall, F1, AUC-ROC (classification); RMSE, MAE (regression); BLEU/ROUGE (text).
- **Overfitting** (memorizes training data) vs. **Underfitting** (too simple).
- **AWS ML stack (by abstraction level)**:
  - *AI Services (no ML expertise)*: Rekognition (vision), Transcribe (speech-to-text), Polly (text-to-speech), Translate, Comprehend (NLP), Textract (docs), Lex (chatbots), Personalize, Forecast, Kendra (search), Fraud Detector.
  - *ML Services*: SageMaker (build/train/deploy — full ML lifecycle), SageMaker Canvas (no-code ML).
  - *ML Frameworks/Infra*: EC2, Deep Learning AMIs, Trainium/Inferentia chips.

## Domain 2: Generative AI Fundamentals
- **Foundation Model (FM)**: large pre-trained model adaptable to many tasks.
- **LLM**: FM for text.
- **Transformer architecture**: attention mechanism, tokens, embeddings.
- **Prompt engineering**: zero-shot, one-shot, few-shot, chain-of-thought.
- **Inference parameters**: Temperature (creativity/randomness), Top-p/Top-k (sampling diversity), max tokens, length penalty.
- **RAG (Retrieval Augmented Generation)**: grounds model with external/current data — reduces hallucination, avoids retraining.
- **Fine-tuning** vs. **Continued pre-training** vs. **RAG** vs. **Prompt engineering** — know when to use each (cost/complexity increases in that order for customization depth).
- **Embeddings & vector databases**: OpenSearch, Aurora (pgvector), Kendra — used for semantic search/RAG.
- **Diffusion models**: image generation (e.g., Stable Diffusion, Titan Image Generator).
- **Amazon Bedrock**: fully managed service to access multiple FMs (Anthropic Claude, Amazon Titan, Meta Llama, Mistral, Cohere, AI21, Stability AI) via one API. Key features: Knowledge Bases (RAG), Agents (task orchestration), Guardrails (safety filters), Model Evaluation, fine-tuning/customization.
- **Amazon Q**: generative AI assistant (Q Business, Q Developer).
- **PartyRock**: no-code playground built on Bedrock.

## Domain 3: Applications of Foundation Models
- **Use case selection**: match FM capability to business problem; consider cost, latency, context window, modality.
- **SageMaker JumpStart**: pre-built/pre-trained models and solution templates, one-click deploy.
- **Model customization spectrum**: Prompt engineering → RAG → Fine-tuning (instruction/domain-adaptation) → Continued pre-training → Train from scratch.
- **Fine-tuning types**: Instruction-based (labeled prompt/response pairs), Domain adaptation (unlabeled domain text).
- **Evaluation**: Human evaluation vs. automatic benchmarks (ROUGE, BLEU, BERTScore); Bedrock Model Evaluation jobs.
- **Cost factors**: on-demand vs. provisioned throughput, input/output token pricing, model size trade-offs.
- **Agents**: multi-step task orchestration, tool/API calling.

## Domain 4: Responsible AI
- **Bias & fairness**: bias can come from training data, sampling, or algorithm design. Mitigate via diverse data, SageMaker Clarify (bias detection & explainability).
- **Explainability**: SageMaker Clarify, model cards.
- **Transparency**: AWS AI Service Cards — publicly documented intended use, limitations, and design choices per service.
- **Hallucination**: model generates plausible but false content — mitigate with RAG, grounding, guardrails, human review.
- **Toxicity/harmful content**: Bedrock Guardrails filter denied topics, PII, profanity, harmful content.
- **Human-in-the-loop**: Amazon A2I (Augmented AI) for human review of low-confidence predictions.
- **Environmental/sustainability**: consider compute efficiency, AWS sustainability pillar.

## Domain 5: Security, Compliance, Governance
- **Shared Responsibility Model**: AWS secures "of the cloud" (infrastructure); customer secures "in the cloud" (data, access, config).
- **IAM**: least privilege, roles, policies for controlling access to AI services/Bedrock models.
- **Data protection**: encryption at rest (KMS) and in transit (TLS); Bedrock does not use customer prompts/outputs to train base models by default.
- **PrivateLink/VPC endpoints**: keep traffic off public internet.
- **Governance**: SageMaker Model Cards & Model Registry for tracking lineage/versioning.
- **Compliance**: AWS Artifact (compliance reports), AWS Config, CloudTrail (audit logging), AWS Audit Manager.
- **Regulations to be aware of conceptually**: GDPR, HIPAA (not tested in depth, just AWS's compliance posture).

---

## Quick Service Cheat Table
| Need | Service |
|---|---|
| Chatbot | Lex |
| Image/video analysis | Rekognition |
| Speech → text | Transcribe |
| Text → speech | Polly |
| Translation | Translate |
| Text analysis (sentiment, entities) | Comprehend |
| Extract text/data from docs | Textract |
| Enterprise search | Kendra |
| Recommendations | Personalize |
| Time-series forecasting | Forecast |
| Fraud detection | Fraud Detector |
| Access multiple FMs / GenAI apps | Bedrock |
| Full custom ML lifecycle | SageMaker |
| No-code ML | SageMaker Canvas |
| Bias/explainability | SageMaker Clarify |
| Human review of predictions | Augmented AI (A2I) |
| GenAI assistant for work | Amazon Q |

## Exam Tips
- Questions are scenario-based with multiple "technically correct" answers — pick the *best fit* for cost/simplicity/managed-service preference.
- AWS favors managed/serverless solutions (Bedrock, AI services) over "build it yourself" (raw EC2 + open-source models) unless the scenario demands customization.
- Know *when* to use RAG vs. fine-tuning — RAG for current/proprietary knowledge without retraining; fine-tuning for changing model behavior/style/domain expertise.
- Responsible AI and security domains combine for 28% — don't neglect them just because they're "soft skills."
