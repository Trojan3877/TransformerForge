###############################################################################
# TransformerForge — Multi-Stage Dockerfile
# ---------------------------------------------------------------------------
# Stage 1 (builder)  :  • Maven builds Java DataLoader
#                       • g++ compiles libfastattn.so
# Stage 1b (ui)      :  • Node builds Tailwind/React dashboard
# Stage 2 (runtime)  :  • python:3.11-slim with compiled artifacts
###############################################################################

#############################  Stage 1 : builder ##############################
FROM maven:3.9.7-eclipse-temurin-17 AS builder

# ── Build Java DataLoader ───────────────────────────────────────────────────
WORKDIR /build/java
COPY src/java/pom.xml .
RUN mvn -q dependency:go-offline            # cache deps
COPY src/java/src src/java/src
RUN mvn -q package -DskipTests              # creates target/dataloader-…-shaded.jar

# ── Compile C++ fast-attention kernel ──────────────────────────────────────
WORKDIR /build
COPY src/cpp/fast_attention.cpp ./fast_attention.cpp
RUN g++ -O3 -std=c++17 -fPIC -shared fast_attention.cpp -o libfastattn.so

############################ Stage 1b : UI builder ############################
FROM node:20-alpine AS ui-builder
WORKDIR /ui
COPY ui/package*.json ./
RUN npm ci --silent
COPY ui .
RUN npm run build                           # generates /ui/dist

#############################  Stage 2 : runtime ##############################
FROM python:3.11-slim AS runtime
LABEL maintainer="Corey Leath <coreyleath10@gmail.com>"

WORKDIR /app

# ── Minimal system deps ─────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
        libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# ── Copy compiled artifacts ─────────────────────────────────────────────────
COPY --from=builder /build/libfastattn.so            /usr/local/lib/libfastattn.so
COPY --from=builder /build/java/target/dataloader-*.jar /app/dataloader.jar
COPY --from=ui-builder /ui/dist                      /app/static

# ── Python dependencies ─────────────────────────────────────────────────────
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ── Application code ────────────────────────────────────────────────────────
COPY src/python src/python

ENV PYTHONPATH=/app/src/python \
    PYTHONUNBUFFERED=1 \
    LANG=C.UTF-8

EXPOSE 8000
CMD ["uvicorn", "src.python.inference:app", "--host", "0.0.0.0", "--port", "8000"]
