from fastapi import FastAPI, Request, logger
import uvicorn


app = FastAPI()

@app.get("/")
async def root():
    return {"message": "healthy"}

@app.post("/webhook")
async def webhook(request: Request):
    logger.info(request)
    return {"message": "Webhook received"}

@app.post("/hello-webhook")
async def hello_webhook(request: Request):
    print("hello")
    return {"message": "Hello webhook received"}

def main():
    uvicorn.run(app, host="0.0.0.0", port=88)

if __name__ == "__main__":
    main()
