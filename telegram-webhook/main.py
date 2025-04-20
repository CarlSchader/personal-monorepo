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

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
