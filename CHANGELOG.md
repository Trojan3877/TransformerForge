# Changelog
All notable changes to **TransformerForge** will be documented in this file.

The project follows **Semantic Versioning 2.0.0** and the 
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.

---

## [Unreleased]
### Added
- Helm chart autoscaling via HPA and optional KEDA `ScaledObject`.
- Ansible blue-green playbook with secret rotation (`infra/ansible/deploy.yml`).
- Tailwind/React live metrics dashboard (`ui/src/App.jsx`).
- Multi-stage Dockerfile with Java, C++, UI build stages.
- Java Delta-Lake DataLoader + shaded JAR.
- C++17 flash-attention kernel (`libfastattn.so`) and Python wrapper.
- SageMaker fine-tune launcher with Snowflake registry.
- GitHub Actions CI pipeline (Java + C++ + Python) + Codecov.
- Terraform Snowflake module (`snowflake.tf`).
- MIT License, Code of Conduct, Contributing guide.
- Integration test suite and Makefile.
- Docker-compose stack for one-command local spin-up.

### Changed
- README rebranded to **TransformerForge** with new badges and roadmap.
- Helm `values.yaml` tuned for 2-replica default and CPU autoscaling.

### Removed
- (Nothing yet)

---

## [0.1.0] — 2025-07-01
### Added
- Initial public release of TransformerForge scaffold: README, directory layout, requirements, minimal API, and CI badge.

[Unreleased]: https://github.com/Trojan3877/TransformerForge/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Trojan3877/TransformerForge/releases/tag/v0.1.0
