# Telegram Webhook Server

A FastAPI-based webhook server for handling Telegram bot updates. This project provides a simple and secure way to receive and process Telegram bot messages through webhooks.

## Features

- FastAPI-based web server for handling Telegram webhooks
- Secure webhook registration with secret token verification
- Simple and extensible architecture
- Health check endpoint

## Prerequisites

- Python 3.10 or higher
- A Telegram Bot Token (obtain from [@BotFather](https://t.me/BotFather))
- A publicly accessible URL for webhook registration

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd telegram-webhook
```

2. Create and activate a virtual environment:
```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -e .
```

## Usage

### Starting the Webhook Server

Run the FastAPI server:
```bash
python main.py
```

The server will start on `http://0.0.0.0:8000` with the following endpoints:
- `GET /`: Health check endpoint
- `POST /webhook`: Telegram webhook endpoint

### Registering the Webhook

Use the provided script to register your webhook with Telegram:

```bash
python register-webhook.py \
    --bot-token YOUR_BOT_TOKEN \
    --url https://your-domain.com/webhook \
    --secret-token YOUR_SECRET_TOKEN
```

Replace:
- `YOUR_BOT_TOKEN`: Your Telegram bot token
- `https://your-domain.com/webhook`: Your publicly accessible webhook URL
- `YOUR_SECRET_TOKEN`: A secret token for webhook verification

## Development

The project uses:
- FastAPI for the web server
- python-telegram-bot for Telegram integration
- uvicorn as the ASGI server

### Project Structure

- `main.py`: FastAPI application and webhook handler
- `register-webhook.py`: Script for registering webhooks with Telegram
- `pyproject.toml`: Project configuration and dependencies

## Security

- Webhook requests are verified using a secret token
- Make sure to use HTTPS for your webhook URL
- Keep your bot token and secret token secure

## License

[Add your license here]

## Contributing

[Add contribution guidelines here]
