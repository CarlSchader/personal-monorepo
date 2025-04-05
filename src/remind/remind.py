import asyncio
import os
import argparse

import telegram

BOT_TOKEN: str = os.getenv("BOT_TOKEN", "")

assert len(BOT_TOKEN) > 0, "BOT_TOKEN not set"


async def send_telegram(bot: telegram.Bot, chat_id: str, message: str):
    await bot.send_message(text=message, chat_id=chat_id)


async def execute_async(message: str):
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
    parser = argparse.ArgumentParser(description='Send a message to a Telegram chat.')
    parser.add_argument('-m', '--message', type=str, required=True, help='The message to send.')
    args = parser.parse_args()

    message = args.message

    asyncio.run(execute_async(message))


if __name__ == '__main__':
    main()
