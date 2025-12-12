from src.llm.rag_pipeline import build_rag_pipeline
from langchain.schema import Document

def run_agent(question: str):
    docs = [
        Document(page_content="TransformerForge demonstrates LLM system design."),
        Document(page_content="RAG improves factual grounding."),
    ]

    rag = build_rag_pipeline(docs)
    return rag.run(question)