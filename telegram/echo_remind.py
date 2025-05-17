import asyncio
import sys
import argparse
import os

import telegram


## CONSTANTS
FALLBACK_TOKEN_FILE_PATH = "/etc/personal-monorepo/bot-token"
CHAT_IDS_FILE = "/var/lib/personal-monorepo/chat-ids.txt"


async def execute_async():
    parser = argparse.ArgumentParser(description='Send a message to a Telegram chat.')
    parser.add_argument("message", type=str, nargs="+")
    parser.add_argument('-b', '--bot-token', type=str, required=False, help=f'bot token. If not specified BOT_TOKEN environment variable is used, if environment variable not set then {FALLBACK_TOKEN_FILE_PATH} is read')
    args = parser.parse_args()

    bot_token: str | None = None
    if args.bot_token is not None and args.bot_token != "": 
        bot_token = args.bot_token 
        print("using arg")
    elif os.getenv("BOT_TOKEN", "") != "":
        bot_token = os.getenv("BOT_TOKEN", "")
        print("using environment variable")
    if os.path.exists(FALLBACK_TOKEN_FILE_PATH):
        # finally check for an etc file
        with open(FALLBACK_TOKEN_FILE_PATH, "r") as f:
            bot_token = f.read().strip()
            print(f"using file at {FALLBACK_TOKEN_FILE_PATH}")

    # check if file exists and if not create it and all parent directories
    if not os.path.exists(CHAT_IDS_FILE):
        os.makedirs(os.path.dirname(CHAT_IDS_FILE), exist_ok=True)
        with open(CHAT_IDS_FILE, 'w') as f:
            f.write("")

    chat_ids: list[int] = []
    with open(CHAT_IDS_FILE, 'r') as f:
        chat_ids = [int(line.strip()) for line in f.readlines() if len(line.strip()) > 0]

    
    message = ' '.join(args.message)
    bot = telegram.Bot(bot_token)

    for chat_id in chat_ids:
        print(f"sending to chat_id: {chat_id}")
        await bot.send_message(text=message, chat_id=chat_id)


def main():
    asyncio.run(execute_async())

if __name__ == "__main__":
    main()
