import json
import ssl 
import os
import certifi
import re
from datetime import datetime
import logging
import subprocess

import aiohttp
import telegram
from fastapi import FastAPI, Request, Response, status
import uvicorn
import boto3
from dateutil import parser

### SETUP CONSTANTS AND GLOBALS ###

logger = logging.getLogger('uvicorn.info')
ssl_context = ssl.create_default_context(cafile=certifi.where())

REPO_FILES_ROOT: str = "https://raw.githubusercontent.com/CarlSchader/personal-monorepo/refs/heads/main/"

PORT: int = int(os.getenv("PORT", "8080"))
SSH_KEY_PATH = os.getenv("SSH_KEY_PATH", "")
logger.info(f"SSH_KEY_PATH: {SSH_KEY_PATH}")

DEFAULT_ASSET_ACCOUNT = "assets:personal:checking"

## trusted chat_ids

# this file is the same file used by remind service and any chat-ids in here we assume are trusterd
# and we will allow them to access sensitive commands and information.
CHAT_IDS_FILE = "/var/lib/personal-monorepo/chat-ids.txt"
trusted_chat_ids: set[int] = set()
if os.path.exists(CHAT_IDS_FILE):
    with open(CHAT_IDS_FILE, 'r') as f:
        trusted_chat_ids = set([int(line.strip()) for line in f.readlines()])


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
BUCKET: str = os.getenv("TELEGRAM_BUCKET", "telegram-documents")
BUCKET_REGION: str = os.getenv("TELEGRAM_BUCKET_REGION", "wnam")

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
    region_name=BUCKET_REGION,
)


## github token

FALLBACK_GITHUB_TOKEN_FILE_PATH: str = "/etc/personal-monorepo/github-token"

GITHUB_TOKEN: str = os.getenv("GITHUB_TOKEN", "")
if GITHUB_TOKEN == "" and os.path.exists(FALLBACK_GITHUB_TOKEN_FILE_PATH):
    with open(FALLBACK_GITHUB_TOKEN_FILE_PATH, 'r') as f:
        GITHUB_TOKEN = f.read().strip()
GITHUB_TOKEN = GITHUB_TOKEN.strip()

assert len(GITHUB_TOKEN) > 0, "github token is empty"


### END SETUP ###


def format_transaction_string(transaction: str) -> str:
    """
    This function takes in a user sent transaction string and attempts to format it correctly to be added to a ldger compatible .dat file
    """
    # Split the input by lines
    lines = transaction.strip().split('\n')
    
    if not lines:
        raise Exception("Invalid transaction format")

    # see if the transaction statrs with a date. if so parse it into date. Else, set date to now      
    # everything after the date is a transaction message. This should all exist on a single line like so:
    # [date] <transaction-string>
    first_line = lines[0].strip()
    parts = first_line.split(' ', 1)
    
    try:
        date = parser.parse(parts[0])
        description = parts[1]
    except (ValueError, IndexError):
        # If parsing fails, use current date
        date = datetime.now()
        description = first_line
    
    # Format the transaction header
    formatted_transaction = f"{date.strftime('%Y/%m/%d')} {description}\n"
    
    # Process account entries (indented lines)
    nonempty_lines: list[str] = []
    for line in lines[1:]:
        line = line.strip()
        if line:
            nonempty_lines.append(line)
        else:
            break

    if len(nonempty_lines) == 1:
        # append default account to the end
        nonempty_lines.append(DEFAULT_ASSET_ACCOUNT)
    elif len(nonempty_lines) < 1:
        raise Exception("Not enough accounts listed")

    for i, line in enumerate(nonempty_lines):
        logger.info(f"{i} {line}")
        if line:
            splits = line.split()

            if (i != len(nonempty_lines) - 1 and len(splits) != 2) or (i == len(nonempty_lines) - 1 and len(splits) != 1):
                raise Exception("Invalid transaction format: Each account entry must have exactly two parts (account and amount) inless it's the final account, then it can have just the account name.")

            if len(splits) == 2:
                account, amount = splits[0], splits[1]
                # make sure amount is valid
                if not (amount.startswith('$') and re.match(r'^\$-?\d+(\.\d{1,2})?$', amount)):
                    raise Exception(f"Invalid amount format: {amount}. Must be in format $X.XX or $-X.XX")
                
                formatted_transaction += f"  {account}  {amount}\n"
            else:
                account = splits[0]
                formatted_transaction += f"  {account}\n"

    
    return formatted_transaction


def help_string() -> str:
    return '''
        help: list help
        finances: you can type in ledger args or leave empty to read all transactions
        list: list all available markdown files
        <file>.md: read markdown file
        
        You can also send files and they'll be stored in R2.
    '''


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
    md_regex = r'\b([\w\-]+\.md)\b'
    
    if len(message_text) >= 8 and message_text[:8] == 'finances':
        # pull secrets/finances.dat
        subprocess_list: list[str] = [
            "network-decrypt",
            # "../repo-utils/network-decrypt.sh", # just for dev
            "https://raw.githubusercontent.com/CarlSchader/personal-monorepo/refs/heads/main/secrets.tar.gz.enc",
            "secrets/finances.dat",
        ]

        if len(SSH_KEY_PATH) > 0:
            subprocess_list += [SSH_KEY_PATH]

        network_decrypt_run = subprocess.run(
            subprocess_list, 
            capture_output=True,
        )

        finances_file_bytes: bytes = network_decrypt_run.stdout

        # ledger is a program that can query and format the finances file content
        if len(message_text) > 8: 
            ledger_args = message_text[8:].strip()
            ledger_run = subprocess.run(
                ['ledger', '-f', '-'] + ledger_args.split(), 
                input=finances_file_bytes,
                capture_output=True,
            )

            if ledger_run.returncode != 0:
                raise Exception(ledger_run.stderr.decode())

            await bot.send_message(text=ledger_run.stdout.decode(), chat_id=chat_id)
    
        else:
            await bot.send_message(text=finances_file_bytes.decode(), chat_id=chat_id)

    elif len(message_text) >= 11 and message_text[:11] == "transaction":
        if len(message_text) == 11:
            transaction_help_string = """
                Usage:
                transaction
                <date ex: 2025/05/11> <note ex: burrito>
                  <account ex: expenses:food:chipotle:burrito> <amount ex: $2.00>
                  ... more accounts
            """
            await bot.send_message(text=transaction_help_string, chat_id=chat_id)
        else:
            transaction_string = message_text[11:]
            formatted_transaction = '\n\n' + format_transaction_string(transaction_string) + '\n\n'

            # pull secrets/finances.dat
            network_decrypt_list: list[str] = [
                "network-decrypt",
                # "../repo-utils/network-decrypt.sh", # just for dev
                "https://raw.githubusercontent.com/CarlSchader/personal-monorepo/refs/heads/main/secrets.tar.gz.enc",
                "secrets/finances.dat",
            ]

            commit_secret_file_list = ['commit-secret-file', 'secrets/finances.dat', 'transaction', GITHUB_TOKEN]

            if len(SSH_KEY_PATH) > 0:
                network_decrypt_list += [SSH_KEY_PATH]
                commit_secret_file_list += [SSH_KEY_PATH]

            network_decrypt_run = subprocess.run(
                network_decrypt_list, 
                capture_output=True,
            )

            finances_file_bytes: bytes = network_decrypt_run.stdout
            new_finances_file_bytes: bytes = finances_file_bytes + formatted_transaction.encode()

            run = subprocess.run(commit_secret_file_list, input=new_finances_file_bytes, capture_output=True)
            if run.returncode != 0:
                raise Exception(run.stderr.decode())
            await bot.send_message(text="transaction recorded, use finances to view it", chat_id=chat_id)
    elif len(message_text) >= 6 and message_text[:6] == "append":
        if len(message_text) == 6 or len(message_text) == 7 and message_text[6] == ' ':
            append_help_string = """
                Usage:
                append <markdown file> <message>
            """
            await bot.send_message(text=append_help_string, chat_id=chat_id)
        else:
            message_text = message_text[7:].strip()
            markdown_file, message = message_text.split(' ', 1)
            if len(message) == 0:
                raise Exception("Invalid append command, must be: append <markdown file> <message>")
            
            if not re.search(md_regex, markdown_file):
                raise Exception("Invalid markdown file, must be: append <markdown file> <message>")

            md_content = await fetch_repo_file(markdown_file)
            md_content += ('\n' + message)
            subprocess_list = [ # This program reads stdin and writes to a file in the repo
                "commit-file",
                "--repo=carlschader/personal-monorepo",
                "--file=" + markdown_file,
                "--message=" + "appended to " + markdown_file,
                "--token=" + GITHUB_TOKEN,
            ]

            if len(SSH_KEY_PATH) > 0:
                subprocess_list += [SSH_KEY_PATH]

            subprocess.run(subprocess_list, input=md_content.encode())
            await bot.send_message(text="appended to " + markdown_file, chat_id=chat_id)
    elif re.search(md_regex, message_text):
        # Extract the markdown filename
        match = re.search(md_regex, message_text)
        if match:
            md_filename = match.group(1)
            # Fetch the markdown file from the repository
            md_content = await fetch_repo_file(md_filename)
            # Format the markdown for chat
            formatted_content = format_markdown_for_chat(md_content)

            await bot.send_message(text=formatted_content, chat_id=chat_id)
    else:
        await bot.send_message(text=help_string(), chat_id=chat_id)


async def handle_document(document, chat_id: int, tag: str | None = None):
    """
    If tag is set this will be used as the filename but the file extension will be inferred.
    """
    try:
        # Get file information from Telegram
        file = await bot.get_file(document['file_id'])
        
        file_path = file.file_path
        extension = file_path[file_path.rfind('.'):]
        if len(extension) == 0:
            extension = '.file'

        if not tag:
            file_name = document.get("file_name", datetime.now().strftime("%Y-%m-%d_%H:%M:%S") + extension)
        else:
            file_name = tag + extension
        
        # Download the file
        file_content = await file.download_as_bytearray()
        
        # Upload to S3
        s3_client.put_object(
            Bucket=BUCKET,
            Key=file_name,
            Body=file_content
        )
        
        # Notify user of successful upload
        await bot.send_message(
            chat_id=chat_id,
            text=f"Document '{file_name}' has been stored successfully."
        )
    except Exception as e:
        logger.error(f"Error storing document: {e}")
        await bot.send_message(
            chat_id=chat_id,
            text=f"Sorry, there was an error storing your document: {str(e)}"
        )


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
        logger.info("received update: " + json.dumps(update, indent=2))

        if not 'message' in update:
            logger.info("no message")
            return {"message": "no message"}
        message: dict = update['message']

        if 'chat' not in message and 'id' not in message['chat']:
            logger.info("no chat in message")
            return {'message': "no chat in message"}
        chat_id: int = int(message['chat']['id'])

        if chat_id not in trusted_chat_ids:
            logger.info(f"untrusted chat id used: {chat_id}")
            return {'message': f"untrusted chat id used: {chat_id}"}

        try:
            if 'text' in message: # handle text from user
                logger.info('received text')
                logger.info(f"SSH_KEY_PATH: {SSH_KEY_PATH}")
                message_text = message['text']
                await handle_text_message(message_text, chat_id) 
            
            if 'document' in message: # store the document in object storage
                logger.info('received document')
                document = message['document']
                await handle_document(document, chat_id)

            # photo property contains a list of documents of different resolution photos. The last index is the largest
            if 'photo' in message: 
                logger.info('received photo')
                document = message['photo'][-1]
                if 'caption' in message:
                    tag = message['caption']
                else:
                    tag = None
                await handle_document(document, chat_id, tag=tag)

        except Exception as e:
            logger.error(e)
            await bot.send_message(
                chat_id=chat_id,
                text=f"Sorry, there was an error processing your message: {str(e)}"
            )

    except Exception as e:
        logger.error(e)
        

    return {"message": "processed update"}


def main():
    uvicorn.run(app, host="0.0.0.0", port=PORT)

if __name__ == "__main__":
    main()
