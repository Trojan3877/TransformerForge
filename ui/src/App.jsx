// ui/src/App.jsx
// -----------------------------------------------------------------------------
// Tailwind dashboard for TransformerForge.
// Fetches /metrics (Prometheus text) every 5 seconds and displays key KPIs.
// -----------------------------------------------------------------------------

import { useEffect, useState } from "react";

const Card = ({ title, value }) => (
  <div className="bg-white dark:bg-zinc-800 rounded-2xl shadow p-4 flex flex-col">
    <h3 className="text-sm font-semibold text-zinc-500">{title}</h3>
    <span className="mt-1 text-2xl font-bold">{value}</span>
  </div>
);

function parsePrometheus(text) {
  const lines = text.split("\n");
  const out = {};
  for (const line of lines) {
    if (line.startsWith("#") || line.trim() === "") continue;
    const [name, val] = line.split(" ");
    out[name] = parseFloat(val);
  }
  return out;
}

export default function App() {
  const [metrics, setMetrics] = useState({});

  useEffect(() => {
    const fetchMetrics = async () => {
      try {
        const res = await fetch("/metrics");
        const txt = await res.text();
        setMetrics(parsePrometheus(txt));
      } catch (err) {
        console.error(err);
      }
    };
    fetchMetrics();
    const id = setInterval(fetchMetrics, 5000);
    return () => clearInterval(id);
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-br from-zinc-50 to-zinc-100 dark:from-zinc-900 dark:to-zinc-800 p-8">
      <h1 className="text-3xl font-extrabold mb-6 text-zinc-700 dark:text-zinc-200">
        TransformerForge • Live Metrics
      </h1>
      <div className="grid gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
        <Card
          title="P95 Latency (ms)"
          value={metrics["inference_latency_p95_ms"] ?? "—"}
        />
        <Card
          title="Rouge-L"
          value={metrics["eval_rougeL"]?.toFixed(2) ?? "—"}
        />
        <Card
          title="BLEU-4"
          value={metrics["eval_bleu4"]?.toFixed(2) ?? "—"}
        />
        <Card
          title="Pass@3"
          value={metrics["eval_pass3"]?.toFixed(2) ?? "—"}
        />
        <Card
          title="Cost / 1k Tokens ($)"
          value={metrics["cost_per_1k_tokens_usd"]?.toFixed(4) ?? "—"}
        />
        <Card
          title="Requests / min"
          value={metrics["inference_rpm"] ?? "—"}
        />
      </div>
    </div>
  );
}
