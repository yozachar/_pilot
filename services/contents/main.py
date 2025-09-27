from fastapi import FastAPI

app = FastAPI(
    title="Contents Service",
    description="Manages articles, videos, and other content.",
    version="1.0.0",
)


@app.get("/contents")
def read_contents():
    return [
        {"id": 1, "title": "My First Article"},
        {"id": 2, "title": "Another Great Post"},
    ]
