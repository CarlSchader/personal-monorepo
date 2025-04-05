import asyncio
import telegram
import os

async def main():
    BOT_TOKEN = os.getenv("BOT_TOKEN")

    assert BOT_TOKEN is not None

    bot = telegram.Bot(BOT_TOKEN)
    async with bot:
        updates = await bot.get_updates()
        print(updates)
        
        chat_ids = [update.message.from_user.id for update in updates]
        
        for chat_id in chat_ids:
            # send message
            bot.send_message(text="test", chat_id=BOT_CHAT_ID)


if __name__ == '__main__':
    import argparse

     

    asyncio.run(main())
