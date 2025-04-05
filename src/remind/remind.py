import asyncio
import aiohttp
import os
from datetime import datetime, timedelta
from dateutil import parser
from typing import Tuple

import telegram

UPCOMING_WARNING_DISTANCE = timedelta(days=7)

TODOS_URL = "https://raw.githubusercontent.com/CarlSchader/personal-monorepo/refs/heads/main/todos.md"
SARONIC_URL = "https://raw.githubusercontent.com/CarlSchader/personal-monorepo/refs/heads/main/saronic.md"

BOT_TOKEN: str = os.getenv("BOT_TOKEN", "")

assert len(BOT_TOKEN) > 0, "BOT_TOKEN not set"


class MarkdownLog:
    def __init__(self, message: str, timestamp: datetime):
        self.message = message
        self.timestamp = timestamp

    @staticmethod
    def from_line(line: str) -> 'MarkdownLog':
        stripped = line.strip()
        words = stripped .split(' ')
        timestamp_string = words[-1]
        log_message = ' '.join(words[1:-1])

        return MarkdownLog(log_message, parser.parse(timestamp_string))

    def formatted(self) -> str:
        formatted_time = self.timestamp.strftime("%a %b $d")
        return f"{formatted_time}\t{self.message}"


async def generate_markdown_reminder_string(markdown_url: str) -> str:
    async with aiohttp.ClientSession() as ses:
        async with ses.get(markdown_url) as res:
            if res.status < 200 or res.status >= 300:
                raise Exception(f"error retrieving : {markdown_url}")
            return await res.text() 


async def send_telegram(bot: telegram.Bot, chat_id: str, message: str):
    await bot.send_message(text=message, chat_id=chat_id)


async def execute_async():
    # fetch markdown
    todo_markdown = (await generate_markdown_reminder_string(TODOS_URL)).strip()
    saronic_markdown = (await generate_markdown_reminder_string(SARONIC_URL)).strip()

    todo_logs = [MarkdownLog.from_line(line) for line in todo_markdown.split('\n') if len(line.strip()) > 0]
    saronic_logs = [MarkdownLog.from_line(line) for line in saronic_markdown.split('\n') if len(line.strip()) > 0]

    # find timestamped logs
    time_warning_logs: list[MarkdownLog] = [log for log in todo_logs + saronic_logs if log.timestamp - datetime.now() <= UPCOMING_WARNING_DISTANCE]
   

    # format reminder message
    current_timestamp = datetime.now().strftime("%a %b $d %I:%M %p")
    message = f"""
        Reminder {current_timestamp}

        Upcoming!
        {'\n'.join([log.formatted() for log in time_warning_logs])}
        
        Todo
        {'\n'.join([log.formatted() for log in todo_logs])}

        Work Shit
        {'\n'.join([log.formatted() for log in saronic_logs])}
        
        Don't forget to do this stuff.
    """ 

    bot = telegram.Bot(BOT_TOKEN)
    async with bot:
        updates = await bot.get_updates()

        if len(updates) == 0:
            bot_info = await bot.get_me()
            print("NO CHATS FOUND -- BOT INFO:")
            print(bot_info)
            exit(1)
        
        chat_ids = [
            update.message.from_user.id for update in updates 
            if update.message is not None and update.message.from_user is not None # Not sure if optional chaining is possible here instead
        ]
        
        print(f"SUBSCRIBER COUNT: {len(chat_ids)}")

        for chat_id in chat_ids:
            # send message
            await bot.send_message(text=message, chat_id=chat_id)


def main():
    # import argparse

    # parser = argparse.ArgumentParser(description='Send a message to a Telegram chat.')
    # parser.add_argument('-m', '--message', type=str, required=True, help='The message to send.')
    # args = parser.parse_args()

    # message = args.message

    # asyncio.run(execute_async(message))

    asyncio.run(execute_async())


if __name__ == '__main__':
    main()
