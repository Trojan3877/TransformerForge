## 6 – Failure Domains & Rollback

| Component | Failure Scenario | Automatic Mitigation | Manual Rollback |
|-----------|------------------|----------------------|-----------------|
| **Snowflake** | Network outage or table lock on `MODEL_REGISTRY` | `train.py` retries 3×, then logs to S3 `/failed-registry/` | Re-run `scripts/register_model.py` with the saved JSON |
| **SageMaker Job** | Spot interruption, exceeding max runtime | Built-in SageMaker retry; CI alerts via SNS e-mail | Re-launch with same `--job_suffix` flag |
| **Blue-Green Deploy** | New (“blue”) pods fail readiness | Ansible playbook keeps “green” pods live until health passes | `ansible-playbook deploy.yml -e force_rollback=true` |
| **K8s HPA Surge** | Over-scaling drains node quotas | HPA cooldown (300 s) + maxReplicas cap | Patch `HPA` to lower `maxReplicas` |

A full incident runbook lives in `docs/runbooks/`.
