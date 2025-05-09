import json
import ssl 
import os
import certifi
import re
import logging

import aiohttp
import telegram
from fastapi import FastAPI, Request, Response, status
import uvicorn
import boto3

### SETUP CONSTANTS AND GLOBALS ###

logger = logging.getLogger('uvicorn.info')
ssl_context = ssl.create_default_context(cafile=certifi.where())

REPO_FILES_ROOT: str = "https://raw.githubusercontent.com/CarlSchader/personal-monorepo/refs/heads/main/"

PORT: int = int(os.getenv("PORT", "8080"))


## telegram bot token

FALLBACK_TOKEN_FILE_PATH: str = "/etc/personal-monorepo/bot-token"

BOT_TOKEN: str = os.getenv("BOT_TOKEN", "")
if BOT_TOKEN == "" and os.path.exists(FALLBACK_TOKEN_FILE_PATH):
    with open(FALLBACK_TOKEN_FILE_PATH, 'r') as f:
        BOT_TOKEN = f.read().strip()
BOT_TOKEN = BOT_TOKEN.strip()

assert len(BOT_TOKEN) > 0, "bot token is empty"

bot = telegram.Bot(BOT_TOKEN)


## telegram webhook secret

FALLBACK_SECRET_FILE_PATH: str = "/etc/personal-monorepo/webhook-secret"

WEBHOOK_SECRET: str = os.getenv("WEBHOOK_SECRET", "")
if WEBHOOK_SECRET == "" and os.path.exists(FALLBACK_TOKEN_FILE_PATH):
    with open(FALLBACK_SECRET_FILE_PATH, 'r') as f:
        WEBHOOK_SECRET = f.read().strip()
WEBHOOK_SECRET = WEBHOOK_SECRET.strip()

assert len(WEBHOOK_SECRET) > 0, "webhook secret is empty"


## object storage

OBJECT_STORAGE_ENDPOINT: str = "https://8ffc049de8a865c3922d3097c069a717.r2.cloudflarestorage.com"
FALLBACK_ACCESS_KEY_ID_FILE_PATH: str = "/etc/personal-monorepo/access-key-id"
FALLBACK_SECRET_ACCESS_KEY_PATH: str = "/etc/personal-monorepo/secret-access-key"

ACCESS_KEY_ID: str = os.getenv("ACCESS_KEY_ID", "")
if ACCESS_KEY_ID == "" and os.path.exists(FALLBACK_ACCESS_KEY_ID_FILE_PATH):
    with open(FALLBACK_ACCESS_KEY_ID_FILE_PATH, 'r') as f:
        ACCESS_KEY_ID = f.read().strip()
ACCESS_KEY_ID = ACCESS_KEY_ID.strip()

assert len(ACCESS_KEY_ID) > 0, "access-key-id is empty"

SECRET_ACCESS_KEY: str = os.getenv("SECRET_ACCESS_KEY", "")
if SECRET_ACCESS_KEY == "" and os.path.exists(FALLBACK_SECRET_ACCESS_KEY_PATH):
    with open(FALLBACK_SECRET_ACCESS_KEY_PATH, 'r') as f:
        SECRET_ACCESS_KEY = f.read().strip()
SECRET_ACCESS_KEY = SECRET_ACCESS_KEY.strip()

assert len(SECRET_ACCESS_KEY) > 0, "secret-access-key is empty"

s3_client = boto3.client(
    's3',
    endpoint_url=OBJECT_STORAGE_ENDPOINT,
    aws_access_key_id=ACCESS_KEY_ID,
    aws_secret_access_key=SECRET_ACCESS_KEY,
)


### END SETUP ###

async def fetch_repo_file(repo_sub_path: str) -> str:
    aiohttp_connector = aiohttp.TCPConnector(ssl=ssl_context)
    async with aiohttp.ClientSession(connector=aiohttp_connector) as session:
        url = REPO_FILES_ROOT + repo_sub_path
        logger.info(f"fetching file: {url}")
        async with session.get(url) as response:
            if response.status == 200:
                return await response.text()
            else:
                raise Exception(f"Error fetching file: {response.status}")


def format_markdown_for_chat(markdown: str) -> str:
    """
    Given a string sourced from a .md file. 
    Format it to post in the bot chat.
    """
    # Format markdown for Telegram chat
    # Telegram supports basic markdown formatting
    # Remove any HTML tags, adjust headers, and ensure proper spacing
    lines = markdown.strip().split('\n')
    formatted_text = []
    
    for line in lines:
        # Handle headers
        if line.startswith('#'):
            # Count the number of # symbols
            header_level = 0
            for char in line:
                if char == '#':
                    header_level += 1
                else:
                    break
            
            # Format headers according to Telegram markdown
            header_text = line[header_level:].strip()
            if header_level <= 2:
                formatted_text.append(f"*{header_text}*\n")
            else:
                formatted_text.append(f"_{header_text}_\n")
        
        # Handle code blocks
        elif line.strip().startswith('```'):
            formatted_text.append('`code block`\n')
        
        # Handle bullet points
        elif line.strip().startswith('- ') or line.strip().startswith('* '):
            formatted_text.append(f"• {line.strip()[2:]}\n")
        
        # Regular text
        else:
            formatted_text.append(f"{line}\n")
    
    return ''.join(formatted_text)


async def handle_text_message(message_text: str, chat_id: int):
    message_text = message_text.lower().strip()
    # check if message contains <word>.md where word can include dashes, underscores, numbers, and symbols
    regex = r'\b([\w\-]+\.md)\b'
    if re.search(regex, message_text):
        # Extract the markdown filename
        match = re.search(regex, message_text)
        if match:
            md_filename = match.group(1)
            # Fetch the markdown file from the repository
            md_content = await fetch_repo_file(md_filename)
            # Format the markdown for chat
            formatted_content = format_markdown_for_chat(md_content)

            async with bot:
                await bot.send_message(text=formatted_content, chat_id=chat_id)


app = FastAPI()

@app.middleware('http')
async def check_webhook_secret(request: Request, call_next): 
    request_secret: str = request.headers.get("X-Telegram-Bot-Api-Secret-Token", "")
    logger.info(f"request_secret: {request_secret}")
    logger.info(f"webhook_secret: {WEBHOOK_SECRET}")
    if request_secret != WEBHOOK_SECRET:
        response = Response(content='{"error": "unauthorized"}', media_type="application/json")
        response.status_code = status.HTTP_401_UNAUTHORIZED
    else:
        response = await call_next(request)
    return response

@app.get("/")
@app.get("/health")
async def root():
    return {"message": "healthy"}

@app.post("/webhook")
async def webhook(request: Request):
    try:
        update: dict = await request.json()
        logger.info(json.dumps(update, indent=2))

        if not 'message' in update:
            return {"message": "no message"}
        message: dict = update['message']

        if 'chat' not in message and 'id' not in message['chat']:
            return {'message': "no chat in message"}
        chat_id: int = int(message['chat']['id'])

        if 'text' in message: # handle text from user
            message_text = message['text']
            await handle_text_message(message_text, chat_id) 

    except Exception as e:
        logger.error(e)

    return {"message": "processed update"}


def main():
    uvicorn.run(app, host="0.0.0.0", port=PORT)

if __name__ == "__main__":
    main()
