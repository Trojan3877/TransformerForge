# ⚡ TransformerForge

![Capstone](https://img.shields.io/badge/Project-Capstone-blueviolet?style=for-the-badge)
![Build](https://github.com/Trojan3877/TransformerForge/actions/workflows/ci.yml/badge.svg?style=for-the-badge)
![Coverage](https://codecov.io/gh/Trojan3877/TransformerForge/branch/main/graph/badge.svg?style=for-the-badge)
![Dependabot](https://img.shields.io/github/dependabot/updates/Trojan3877/TransformerForge?style=for-the-badge)
![Scorecard](https://api.securityscorecards.dev/projects/github.com/Trojan3877/TransformerForge/badge?style=for-the-badge)
![Telemetry](https://img.shields.io/badge/Telemetry-OTEL-green?style=for-the-badge)
![Docs](https://img.shields.io/badge/Docs-GitHub%20Pages-informational?style=for-the-badge)
[→ OpenAPI spec](docs/openapi.json) — import into Postman in one click
![Build](…ci.yml…) 
![UI Build](…ui-build.yml…) 
![Container Scan](…container-scan.yml…)
![UI Build](https://github.com/Trojan3877/TransformerForge/actions/workflows/ui-build.yml/badge.svg)
![Container Scan](https://github.com/Trojan3877/TransformerForge/actions/workflows/container-scan.yml/badge.svg)
![Docs](https://img.shields.io/badge/Docs-GitHub%20Pages-informational?style=for-the-badge)

> **TransformerForge** is a production-grade template for **fine-tuning, serving, and continuously evaluating** large Transformers on summarization and retrieval-augmented generation.  
> Python orchestrates SageMaker jobs; C++ flash-attention and Java Delta loaders boost performance; Docker → Helm → EKS deploys the stack. Metrics stream to Snowflake, dashboards run on Tailwind React, and blue-green upgrades happen via Ansible—meeting the engineering bar at OpenAI, Databricks, and Netflix.

---

## 🌟 Features  
* **Multi-language core** — Python, C++, Java.  
* **End-to-end MLOps** — Docker, Helm, Terraform, Ansible, CI/CD.  
* **Observability first** — Prometheus metrics, OTEL traces, nightly Snowflake exports.  
* **Quantifiable KPIs** — P95 latency < 60 ms, Rouge-L ≥ 0.45, cost/1kT tokens logged.

---

## 🏗 Architecture  
![Flow-Chart](docs/flowchart.png)

---

## 🚀 Quick Start

```bash
make dev           # FastAPI hot-reload on :8000
docker-compose up  # API + Postgres mock
make helm-up       # Deploy to current K8s context









# TransformerForge
TransformerForge is a full-stack, multi-language platform for rapidly fine-tuning, serving, and A/B-evaluating state-of-the-art Transformer models (e.g., Llama 3, GPT-J, Mistral) on summarization and RAG workloads.

![image](https://github.com/user-attachments/assets/86d85de3-93a1-477f-9113-40f85512a1a2)
