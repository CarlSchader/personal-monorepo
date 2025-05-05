import telegram
import asyncio

async def unregister_webhook(bot_token: str):
    bot = telegram.Bot(token=bot_token)
    await bot.delete_webhook()

async def execute_async():
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--bot-token", "-b", type=str, required=True)
    args = parser.parse_args()

    print(args.bot_token)

    await unregister_webhook(args.bot_token)

def main():
    asyncio.run(execute_async())

if __name__ == "__main__":
    main()
