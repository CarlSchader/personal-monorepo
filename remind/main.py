import asyncio
import aiohttp
import os
from datetime import datetime, timedelta
from dateutil import parser

import telegram

UPCOMING_WARNING_DISTANCE = timedelta(days=7)

TODOS_URL = "https://raw.githubusercontent.com/CarlSchader/personal-monorepo/refs/heads/main/todos.md"

CHAT_IDS_FILE = "/var/lib/personal-monorepo/chat-ids.txt"

# check if file exists and if not create it and all parent directories
if not os.path.exists(CHAT_IDS_FILE):
    os.makedirs(os.path.dirname(CHAT_IDS_FILE), exist_ok=True)
    with open(CHAT_IDS_FILE, 'w') as f:
        f.write("")

chat_ids: list[int] = []
with open(CHAT_IDS_FILE, 'r') as f:
    chat_ids = [int(line.strip()) for line in f.readlines() if len(line.strip()) > 0]

class MarkdownLog:
    def __init__(self, message: str, timestamp: datetime | None):
        self.message = message
        self.timestamp = timestamp

    @staticmethod
    def from_line(line: str) -> 'MarkdownLog':
        stripped = line.strip()
        words = stripped .split(' ')
        try:
            timestamp_string = words[-1]
            timestamp = parser.parse(timestamp_string)
            log_message = ' '.join(words[1:-1])
        except:
            timestamp = None
            log_message = ' '.join(words[1:])

        return MarkdownLog(log_message, timestamp)

    def formatted(self) -> str:
        if self.timestamp is not None:
            formatted_time = self.timestamp.strftime("%a %b %d")
            return f"- {formatted_time} {self.message}"
        else:
            return f"- {self.message}"


async def generate_markdown_reminder_string(markdown_url: str) -> str:
    async with aiohttp.ClientSession() as ses:
        async with ses.get(markdown_url) as res:
            if res.status < 200 or res.status >= 300:
                raise Exception(f"error retrieving : {markdown_url}")
            return await res.text() 


async def send_telegram(bot: telegram.Bot, chat_id: str, message: str):
    await bot.send_message(text=message, chat_id=chat_id)


async def execute_async(bot_token: str):
    # fetch markdown
    todo_markdown = (await generate_markdown_reminder_string(TODOS_URL)).strip()

    todo_logs = [MarkdownLog.from_line(line) for line in todo_markdown.split('\n') if len(line.strip()) > 0]

    # find timestamped logs
    time_warning_logs: list[MarkdownLog] = [
        log for log in todo_logs 
        if log.timestamp is not None and log.timestamp - datetime.now() <= UPCOMING_WARNING_DISTANCE and log.timestamp - datetime.now() > timedelta(seconds=1)
    ]

    # find over due logs
    over_due_logs: list[MarkdownLog] = [
        log for log in todo_logs 
        if log.timestamp is not None and log.timestamp - datetime.now() <= timedelta(seconds=1)
    ]    
    time_warning_formatted = '\n\t'.join([log.formatted() for log in time_warning_logs])
    over_due_formatted = '\n\t'.join([log.formatted() for log in over_due_logs])
    todo_formatted = '\n\t'.join([log.formatted() for log in todo_logs])

    # format reminder message
    # current_timestamp = datetime.now().strftime("%a %b %d %I %p")
    
    message = f"Carl you've got shit to do\n\n" if len(time_warning_logs) > 0 else f"Nice lil reminder\n\n"
    message += "Upcoming\n"
    message += f"\t{time_warning_formatted}\n\n"
    message += "OVERDUE\n"
    message += f"\t{over_due_formatted}\n\n"
    # message += "Todos\n"
    # message += f"\t{todo_formatted}\n\n"
        
    bot = telegram.Bot(bot_token)
    async with bot:
        updates = await bot.get_updates()

        if len(updates) == 0:
            print("No new chats found")
        else:
            new_chat_ids = [
                update.message.from_user.id for update in updates 
                if update.message is not None and update.message.from_user is not None # Not sure if optional chaining is possible here instead
            ]

            for chat_id in new_chat_ids:
                if chat_id not in chat_ids:
                    chat_ids.append(chat_id)

            with open(CHAT_IDS_FILE, 'w') as f:
                for chat_id in chat_ids:
                    f.write(f"{chat_id}\n")
                    

        for chat_id in chat_ids:
            print(f"sending to chat_id: {chat_id}")
            # send message
            await bot.send_message(text=message, chat_id=chat_id)


def main():
    import argparse

    parser = argparse.ArgumentParser(description='Send a message to a Telegram chat.')
    parser.add_argument('-b', '--bot-token-path', type=str, required=False, help='Location to file containing bot toke. If not specified BOT_TOKEN environment variable is used')
    args = parser.parse_args()

    if args.bot_token_path is not None: 
        with open(args.bot_token_path, 'r') as f:
            bot_token = f.read()
    else:
        bot_token = os.getenv("BOT_TOKEN", "")

    assert len(bot_token) > 0, "no telegram bot token given"


    asyncio.run(execute_async(bot_token))


if __name__ == '__main__':
    main()
