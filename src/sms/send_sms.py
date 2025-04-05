#!/usr/bin/env python3
import os
import argparse
import smtplib
from email.message import EmailMessage

# Dictionary of carrier gateways
CARRIERS = {
    'att':    '@txt.att.net',
    'tmobile': '@tmomail.net',
    'verizon': '@vtext.com',
    'sprint':  '@messaging.sprintpcs.com'
}

def load_config():
    """Load configuration from environment variables."""
    return {
        'email': os.getenv('SMS_EMAIL', "carlschader@gmail.com"),
        'password': os.getenv('SMS_PASSWORD', "test-password"),
        'smtp_server': os.getenv('SMS_SMTP_SERVER', 'smtp.gmail.com'),
        # 'smtp_server': os.getenv('SMS_SMTP_SERVER', 'vtext.com'),
        'smtp_port': int(os.getenv('SMS_SMTP_PORT', '587'))
    }

def send_sms(phone_number: str, carrier: str, message: str, config: dict) -> bool:
    """Send SMS via email gateway."""
    if carrier.lower() not in CARRIERS:
        print(f"Error: Carrier {carrier} not supported. Supported carriers: {', '.join(CARRIERS.keys())}")
        return False
    
    # Create email
    msg = EmailMessage()
    msg.set_content(message)
    
    # Format the phone email address
    to_email = f"{phone_number}{CARRIERS[carrier.lower()]}"

    print(to_email)

    msg['Subject'] = ''
    msg['From'] = config['email']
    msg['To'] = to_email
    
    try:
        # Create SMTP connection
        server = smtplib.SMTP(config['smtp_server'], config['smtp_port'])
        server.starttls()
        server.login(config['email'], config['password'])
        
        # Send message
        server.send_message(msg)
        server.quit()
        return True
    except Exception as e:
        print(f"Error sending SMS: {str(e)}")
        return False

def main():
    """Main function to handle CLI arguments and send SMS."""
    parser = argparse.ArgumentParser(
        description='Send SMS messages via email gateway.',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument('-p', '--phone', 
                       required=True,
                       help='Phone number to send SMS to')
    parser.add_argument('-c', '--carrier',
                       required=True,
                       choices=CARRIERS.keys(),
                       help='Carrier of the phone number')
    parser.add_argument('-m', '--message',
                       required=True,
                       help='Message to send')

    args = parser.parse_args()
    config = load_config()
    print(config)
    
    # Validate configuration
    if not all([config['email'], config['password']]):
        print("Error: Please set SMS_EMAIL and SMS_PASSWORD environment variables")
        return
    
    # Remove any non-numeric characters from phone number
    phone = ''.join(filter(str.isdigit, args.phone))
    
    if send_sms(phone, args.carrier, args.message, config):
        print("SMS sent successfully!")
    else:
        print("Failed to send SMS")

if __name__ == '__main__':
    main() 
