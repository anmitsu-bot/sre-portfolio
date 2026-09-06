from fastapi import FastAPI
import time

app = FastAPI()


@app.get("/")
def root():
    return {
        "message": "SRE Portfolio API"
    }


@app.get("/health")
def health():
    return {
        "status": "ok"
    }


@app.get("/slow")
def slow():
    time.sleep(2)

    return {
        "status": "slow"
    }