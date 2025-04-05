import asyncio
import telegram
import os

async def main():
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
        bot.send_message(text="test", chat_id=BOT_CHAT_ID)


if __name__ == '__main__':
    import argparse

    

    asyncio.run(main())
