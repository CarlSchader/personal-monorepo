import telegram
import asyncio

async def register_webhook(bot_token: str, url: str, secret_token: str):
    bot = telegram.Bot(token=bot_token)
    await bot.set_webhook(url=url, secret_token=secret_token)

async def execute_async():
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--bot-token", "-b", type=str, required=True)
    parser.add_argument("--url", "-u", type=str, required=True)
    # secret token is how we verify the webhook incoming requests
    parser.add_argument("--secret-token", "-s", type=str, required=True)
    args = parser.parse_args()

    print(args.bot_token)
    print(args.secret_token)
    print(args.url)

    await register_webhook(args.bot_token, args.url, args.secret_token)

def main():
    asyncio.run(execute_async())

if __name__ == "__main__":
    main()
