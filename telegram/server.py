import re
import aiohttp
import logging

from fastapi import FastAPI, Request
import uvicorn

logger = logging.getLogger('uvicorn.info')

REPO_FILES_ROOT = "https://raw.githubusercontent.com/CarlSchader/personal-monorepo/refs/heads/main/"


async def fetch_repo_file(repo_sub_path: str) -> str:
    async with aiohttp.ClientSession() as session:
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

app = FastAPI()

@app.get("/")
@app.get("/health")
async def root():
    return {"message": "healthy"}

@app.post("/webhook")
async def webhook(request: Request):
    try:
        body: dict = await request.json()
        message: str = body["message"]["text"]
        logger.info(f"received message: {message}")
        
        message = message.lower().strip()

        # check if message contains <no_whitespace_word>.md
        if re.search(r'\b\w+\.md\b', message):
            # Extract the markdown filename
            match = re.search(r'\b(\w+\.md)\b', message)
            if match:
                md_filename = match.group(1)
                # Fetch the markdown file from the repository
                md_content = await fetch_repo_file(md_filename)
                # Format the markdown for chat
                formatted_content = format_markdown_for_chat(md_content)
                logger.info(formatted_content)
    except Exception as e:
        logger.error(e)

    return {"message": "Webhook received"}


def main():
    uvicorn.run(app, host="0.0.0.0", port=8080)


if __name__ == "__main__":
    main()
