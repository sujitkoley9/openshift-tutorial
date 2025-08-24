# main.py
from fastapi import FastAPI


app = FastAPI(
    title="Core API",
    description="This is the Core API service",
    version="1.0.0"
)

@app.get("/")
async def root():
    return {"message": "Welcome to Core API"}
