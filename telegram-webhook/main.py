from register_webhook import main as register_webhook_entrypoint

from fastapi import FastAPI, Request
import uvicorn

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "healthy"}

@app.post("/webhook")
async def webhook(request: Request):
    data = await request.json()
    print(data)
    return {"message": "Webhook received"}

def main():
    uvicorn.run(app, host="0.0.0.0", port=88)

if __name__ == "__main__":
    main()
