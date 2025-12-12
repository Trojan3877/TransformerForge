from langchain_community.llms import Ollama

def get_llama():
    return Ollama(
        model="llama3",
        temperature=0
    )