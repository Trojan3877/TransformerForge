"""
inference.py
────────────────────────────────────────────────────────────────────────────
Serves TransformerForge’s summarization + RAG endpoints.

• /                 → health check JSON
• /metrics          → Prometheus text
• /summarize        → POST {text: str}   → {"summary": str}
────────────────────────────────────────────────────────────────────────────
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import prometheus_client as prom
from prometheus_client import Counter, Summary
from transformers import pipeline, AutoTokenizer, AutoModelForSeq2SeqLM
import torch
import os

# ────────────────────── Prometheus Metrics ─────────────────────────
REQ_COUNTER = Counter("inference_total", "Total inference requests")
LATENCY_SUM = Summary("inference_latency_seconds", "Latency in seconds")

# ────────────────────── FastAPI init + OTEL ────────────────────────
app = FastAPI(title="TransformerForge API", version="0.1.0")

# OpenTelemetry auto-instrument
try:
    from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
    from opentelemetry import trace
    from opentelemetry.sdk.trace import TracerProvider
    from opentelemetry.sdk.trace.export import BatchSpanProcessor
    from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter

    provider = TracerProvider()
    processor = BatchSpanProcessor(
        OTLPSpanExporter(endpoint=os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4318/v1/traces"))
    )
    provider.add_span_processor(processor)
    trace.set_tracer_provider(provider)
    FastAPIInstrumentor.instrument_app(app, tracer_provider=provider)
except ImportError:
    print("🔬 OpenTelemetry not installed; tracing disabled.")

# ────────────────────── Load Summarizer Model ──────────────────────
MODEL_NAME = os.getenv("BASE_MODEL", "facebook/bart-large-cnn")
DEVICE = 0 if torch.cuda.is_available() else -1
summarizer = pipeline(
    "summarization",
    model=AutoModelForSeq2SeqLM.from_pretrained(MODEL_NAME),
    tokenizer=AutoTokenizer.from_pretrained(MODEL_NAME),
    device=DEVICE
)

# ────────────────────── Request schema ─────────────────────────────
class TextIn(BaseModel):
    text: str
    max_length: int | None = 128
    min_length: int | None = 30

# ────────────────────── Endpoints ──────────────────────────────────
@app.get("/")
def health():
    return {"status": "ok"}

@app.get("/metrics")
def metrics():
    return prom.generate_latest(), 200, {"Content-Type": prom.CONTENT_TYPE_LATEST}

@app.post("/summarize")
@LATENCY_SUM.time()
def summarize(payload: TextIn):
    REQ_COUNTER.inc()
    if not payload.text.strip():
        raise HTTPException(status_code=400, detail="Text cannot be empty")
    summary = summarizer(
        payload.text,
        max_length=payload.max_length,
        min_length=payload.min_length,
        truncation=True,
    )[0]["summary_text"]
    return {"summary": summary.strip()}
