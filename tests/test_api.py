"""
tests/test_api.py
────────────────────────────────────────────────────────────────────────────
Lightweight integration tests for the FastAPI layer.

Executed in CI after the native C++ and Java builds complete.
Uses FastAPI’s TestClient (no Docker needed) so it runs in <1s.
"""

from fastapi.testclient import TestClient
import importlib

# Dynamically import the FastAPI app after PYTHONPATH is set
app_module = importlib.import_module("src.python.inference")
client = TestClient(app_module.app)


def test_health_root():
    """Health-check endpoint returns 200 + JSON."""
    resp = client.get("/")
    assert resp.status_code == 200
    assert resp.json().get("status") == "ok"


def test_metrics_endpoint():
    """Metrics endpoint returns Prometheus plaintext."""
    resp = client.get("/metrics")
    assert resp.status_code == 200
    assert resp.headers["content-type"].startswith("text/plain")
    # Simple check: should include at least one metric line
    assert "process_cpu_seconds_total" in resp.text


def test_tiny_inference():
    """Ensure summarization path returns non-empty string."""
    data = {"text": "TransformerForge turns data and models into code."}
    resp = client.post("/summarize", json=data)
    assert resp.status_code == 200
    summary = resp.json().get("summary", "")
    assert isinstance(summary, str) and len(summary) > 0
