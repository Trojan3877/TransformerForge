from fastapi import FastAPI
from pydantic import BaseModel
from src.llm.agent import run_agent

app = FastAPI(
    title="TransformerForge LLM Platform",
    description="Llama 3 + RAG + LangChain AI System",
    version="1.0.0"
)

class Query(BaseModel):
    question: str

@app.post("/query")
def query_llm(payload: Query):
    response = run_agent(payload.question)
    return {"response": response}