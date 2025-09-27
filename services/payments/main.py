from fastapi import FastAPI

app = FastAPI(
    title="Payments Service",
    description="Handles charges, subscriptions, and billing.",
    version="1.0.0",
)


@app.post("/charge")
def create_charge(amount: int, currency: str = "usd"):
    return {
        "status": "success",
        "charge_id": "ch_12345",
        "amount": amount,
        "currency": currency,
    }
