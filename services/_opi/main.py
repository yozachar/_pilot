import httpx
from fastapi import FastAPI
from fastapi.openapi.utils import get_openapi

app = FastAPI(title="Aggregated API")

SERVICE_URLS = {
    "users": "http://localhost:8001",
    "contents": "http://localhost:8002",
    "payments": "http://localhost:8003",
}


async def fetch_openapi_spec(service_name: str, url: str):
    """Fetches the OpenAPI spec from a downstream service."""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{url}/openapi.json")
            response.raise_for_status()
            return response.json()
    except (httpx.RequestError, httpx.HTTPStatusError) as e:
        print(f"Could not fetch OpenAPI spec for {service_name}: {e}")
        return None


@app.get("/openapi.json", include_in_schema=False)
async def get_open_api_endpoint():
    """Serves the aggregated OpenAPI schema."""
    if app.openapi_schema:
        return app.openapi_schema

    openapi_schema = get_openapi(
        title="Monorepo API Gateway",
        version="1.0.0",
        description="One API to rule them all.",
        routes=app.routes,
    )
    openapi_schema["paths"] = {}

    for service_name, url in SERVICE_URLS.items():
        spec = await fetch_openapi_spec(service_name, url)
        if spec:
            # Add paths from the service, prefixing them to avoid clashes
            for path, path_item in spec.get("paths", {}).items():
                openapi_schema["paths"][f"/{service_name}{path}"] = path_item

    app.openapi_schema = openapi_schema
    return app.openapi_schema
