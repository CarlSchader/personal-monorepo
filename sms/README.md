# SMS CLI Tool

A simple command-line tool to send SMS messages using email-to-SMS gateways. This tool is free to use and doesn't require any paid SMS service.

## Setup

1. Install the requirements:
```bash
pip install -r requirements.txt
```

2. Create a `.env` file in the same directory with your email credentials:
```
SMS_EMAIL=your.email@gmail.com
SMS_PASSWORD=your_app_password
```

Note: If using Gmail, you'll need to create an App Password:
1. Go to your Google Account settings
2. Navigate to Security > 2-Step Verification > App passwords
3. Generate a new app password and use it in the .env file

## Usage

```bash
# Send an SMS
python send_sms.py --phone "1234567890" --carrier verizon --message "Hello from CLI!"

# Get help
python send_sms.py --help
```

Supported carriers:
- AT&T (att)
- T-Mobile (tmobile)
- Verizon (verizon)
- Sprint (sprint)

## Options

- `-p, --phone`: Phone number to send SMS to (required)
- `-c, --carrier`: Carrier of the phone number (required, choices: att, tmobile, verizon, sprint)
- `-m, --message`: Message to send (required)

## Environment Variables

- `SMS_EMAIL`: Your email address
- `SMS_PASSWORD`: Your email password or app password
- `SMS_SMTP_SERVER`: SMTP server (default: smtp.gmail.com)
- `SMS_SMTP_PORT`: SMTP port (default: 587) 