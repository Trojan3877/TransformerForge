# ─────────────────────────────────────────────────────────────────────
# TransformerForge — Makefile
#
#  Quick targets:
#    make build-cpp        Compile C++ fast-attention lib
#    make build-java       Build DataLoader shaded jar
#    make build-ui         Build Tailwind/React dashboard
#    make test             PyTest + coverage
#    make dev              Hot-reload FastAPI on :8000
#    make build            Build Docker image
#    make run              Run Docker image
#    make helm-up          Helm upgrade/install release
#    make tf-apply         Terraform apply EKS + Helm
# ─────────────────────────────────────────────────────────────────────

IMAGE_TAG       ?= trojan3877/transformerforge:latest
HELM_CHART      ?= infra/helm/transformerforge
HELM_RELEASE    ?= transformerforge
KUBE_NS         ?= forge
TF_DIR          ?= infra/terraform
PYTHON          ?= python3

.PHONY: build-cpp
build-cpp:
	g++ -O3 -std=c++17 -fPIC -shared src/cpp/fast_attention.cpp -o src/cpp/libfastattn.so

.PHONY: build-java
build-java:
	cd src/java && mvn -q package -DskipTests

.PHONY: build-ui
build-ui:
	cd ui && npm ci --silent && npm run build

.PHONY: test
test: build-cpp
	coverage run -m pytest -q
	coverage report -m

.PHONY: lint
lint:
	$(PYTHON) -m pip install --quiet ruff mypy
	ruff src/python tests
	mypy src/python --ignore-missing-imports

.PHONY: dev
dev: build-cpp
	uvicorn src.python.inference:app --reload --port 8000

# ───────── Docker ───────────────────────────────────────────────────
.PHONY: build
build:
	docker build -t $(IMAGE_TAG) .

.PHONY: run
run:
	docker run -p 8000:8000 $(IMAGE_TAG)

# ───────── Helm ────────────────────────────────────────────────────
.PHONY: helm-up
helm-up:
	helm upgrade --install $(HELM_RELEASE) $(HELM_CHART) \
	  --namespace $(KUBE_NS) --create-namespace

.PHONY: helm-uninstall
helm-uninstall:
	helm uninstall $(HELM_RELEASE) --namespace $(KUBE_NS)

# ───────── Terraform ───────────────────────────────────────────────
.PHONY: tf-init
tf-init:
	cd $(TF_DIR) && terraform init

.PHONY: tf-plan
tf-plan:
	cd $(TF_DIR) && terraform plan

.PHONY: tf-apply
tf-apply:
	cd $(TF_DIR) && terraform apply

.PHONY: tf-destroy
tf-destroy:
	cd $(TF_DIR) && terraform destroy
