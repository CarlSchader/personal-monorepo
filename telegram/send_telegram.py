import asyncio
import telegram
import os

async def send_telegram(bot: telegram.Bot, chat_id: str, message: str):
    await bot.send_message(text=message, chat_id=chat_id)

async def main(message: str):
    BOT_TOKEN = os.getenv("BOT_TOKEN")

    assert BOT_TOKEN is not None

    bot = telegram.Bot(BOT_TOKEN)
    async with bot:
        updates = await bot.get_updates()
        print(updates)
        
        chat_ids = [update.message.from_user.id for update in updates]
        
        for chat_id in chat_ids:
            # send message
            bot.send_message(text="test", chat_id=chat_id)


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Send a message to a Telegram chat.')
    parser.add_argument('-m', '--message', type=str, required=True, help='The message to send.')
    args = parser.parse_args()

    asyncio.run(main(args.message))
