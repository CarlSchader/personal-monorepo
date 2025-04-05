import asyncio
import telegram
import os

async def send_telegram(bot: telegram.Bot, chat_id: str, message: str):
    await bot.send_message(text=message, chat_id=chat_id)

async def main(message: str):
    BOT_TOKEN = os.getenv("BOT_TOKEN")
    BOT_CHAT_ID = os.getenv("BOT_CHAT_ID")

    assert BOT_TOKEN is not None

    bot = telegram.Bot(BOT_TOKEN)
    async with bot:
        # set BOT_CHAT_ID if not set and alert the user
        if BOT_CHAT_ID is None:
            bot_info = await bot.get_me()
            BOT_CHAT_ID = bot_info.id
            print(f"export BOT_CHAT_ID=\"{BOT_CHAT_ID}\"")

        # send message
        await send_telegram(bot, BOT_CHAT_ID, message)


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Send a message to a Telegram chat.')
    parser.add_argument('-m', '--message', type=str, required=True, help='The message to send.')
    args = parser.parse_args()

    asyncio.run(main(args.message))
