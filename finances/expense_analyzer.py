#!/usr/bin/env python3

import sys
import os
import subprocess
import argparse
from datetime import datetime
from dateutil import parser
import matplotlib.pyplot as plt
import io
import re


def parse_arguments():
    parser = argparse.ArgumentParser(description='Analyze expenses and generate a pie chart')
    parser.add_argument('--start-date', '-s', required=True, help='Start date in YYYY-MM-DD format')
    parser.add_argument('--end-date', '-e', required=True, help='End date in YYYY-MM-DD format')
    parser.add_argument(
        '--url', help='URL to fetch the encrypted data from',
        default="https://raw.githubusercontent.com/CarlSchader/personal-monorepo/refs/heads/main/secrets.tar.gz.enc",
    )
    parser.add_argument('--file-path', default='secrets/finances.dat',
                        help='Path within the archive to the finances data')
    parser.add_argument('--ssh-key-path', help='Path to SSH key for decryption')
    parser.add_argument('--expenses-only', action='store_true',
                        help='Only consider expenses (ignore transfers and payments)')
    return parser.parse_args()


def decrypt_data(url, file_path, ssh_key_path=None):
    """Decrypt the data using the network-decrypt script"""
    cmd = ['network-decrypt', url, file_path]
    if ssh_key_path:
        cmd.append(ssh_key_path)

    try:
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error decrypting data: {e}", file=sys.stderr)
        print(f"Error output: {e.stderr}", file=sys.stderr)
        sys.exit(1)


def parse_ledger_data(data_str):
    """Parse the ledger format data"""
    transactions = []
    current_transaction = None

    # Split the data into lines
    lines = data_str.strip().split('\n')

    for line in lines:
        # Skip empty lines
        if not line.strip():
            continue

        # If the line starts with a date, it's a new transaction
        if re.match(r'^\d{4}/\d{2}/\d{2}', line):
            # Save the previous transaction if it exists
            if current_transaction:
                transactions.append(current_transaction)

            # Parse the date and description
            parts = line.strip().split(' ', 1)
            date = parts[0].replace('/', '-')  # Convert to YYYY-MM-DD
            description = parts[1] if len(parts) > 1 else ''

            # Create a new transaction
            current_transaction = {
                'date': date,
                'description': description,
                'entries': []
            }
        # If the line is indented, it's an entry for the current transaction
        elif line.startswith('  ') and current_transaction:
            # Split the line into account and amount
            parts = line.strip().split()

            # The account is everything except the last part (the amount)
            account = ' '.join(parts[:-1])

            # The amount is the last part
            amount_str = parts[-1]

            # Parse the amount (remove $ and handle negative values)
            if amount_str.startswith('$'):
                amount_str = amount_str[1:]

            # If there's no amount, it's an implicit balancing entry
            if not re.match(r'^\$?[\-+]?[\d\.]+$', amount_str):
                current_transaction['entries'].append({
                    'account': account,
                    'amount': None  # Implicit amount
                })
                continue

            try:
                amount = float(amount_str)
            except ValueError:
                print(f"Warning: Could not parse amount: {amount_str}", file=sys.stderr)
                amount = 0.0

            current_transaction['entries'].append({
                'account': account,
                'amount': amount
            })

    # Add the last transaction
    if current_transaction:
        transactions.append(current_transaction)

    return transactions


def filter_by_date_range(transactions, start_date, end_date):
    """Filter transactions by date range"""
    start = parser.parse(start_date)
    end = parser.parse(end_date)

    filtered_transactions = []
    for transaction in transactions:
        try:
            transaction_date = datetime.strptime(transaction['date'], '%Y-%m-%d')
            if start <= transaction_date <= end:
                filtered_transactions.append(transaction)
        except ValueError:
            print(f"Warning: Could not parse date: {transaction['date']}", file=sys.stderr)

    return filtered_transactions


def extract_expenses(transactions, expenses_only=True):
    """Extract expenses from transactions"""
    expenses = {}

    for transaction in transactions:
        for entry in transaction['entries']:
            account = entry['account']
            amount = entry['amount']

            # Skip entries without an amount
            if amount is None:
                continue

            # Only process expense accounts if expenses_only is True
            if expenses_only and not account.startswith('expenses:'):
                continue

            # Skip non-expense entries (like transfers)
            if not account.startswith('expenses:'):
                continue

            # For expenses, amount is usually negative from the account perspective,
            # but positive in the ledger. We want to represent it as a positive value.
            if amount < 0:
                amount = abs(amount)

            # Split the account into categories
            categories = account.split(':')[1:]  # Skip 'expenses'

            # Use the first category as the main category
            if categories:
                category = categories[0].replace('-', ' ').title()

                if category in expenses:
                    expenses[category] += amount
                else:
                    expenses[category] = amount

    return expenses


def generate_pie_chart(expenses):
    """Generate a pie chart of expenses by category"""
    if not expenses:
        print("No expenses found in the specified date range", file=sys.stderr)
        return None

    # Calculate total expenses
    total_expenses = sum(expenses.values())

    # Create a figure with two subplots - one for the pie chart and one for the legend
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 8), gridspec_kw={'width_ratios': [3, 1]})

    labels = list(expenses.keys())
    values = list(expenses.values())

    # Sort by value for better visualization
    sorted_data = sorted(zip(labels, values), key=lambda x: x[1], reverse=True)
    labels = [item[0] for item in sorted_data]
    values = [item[1] for item in sorted_data]

    # Generate custom labels with both percentage and actual values
    def autopct_format(values):
        def my_format(pct):
            total = sum(values)
            val = int(round(pct*total/100.0))
            return f'${val:.2f}\n({pct:.1f}%)'
        return my_format

    # Generate the pie chart
    wedges, texts, autotexts = ax1.pie(
        values,
        labels=labels,
        autopct=autopct_format(values),
        startangle=90,
        textprops={'fontsize': 9}
    )

    ax1.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle

    # Add a title with the total expenses
    ax1.set_title(f'Expenses by Category\nTotal: ${total_expenses:.2f}')

    # Create a legend with detailed breakdown
    ax2.axis('off')  # Turn off axis
    legend_text = f"Total Expenses: ${total_expenses:.2f}\n\nBreakdown:\n"
    for label, value in sorted_data:
        percentage = (value / total_expenses) * 100
        legend_text += f"{label}: ${value:.2f} ({percentage:.1f}%)\n"

    ax2.text(0, 0.5, legend_text, va='center', ha='left', fontsize=10)

    # Adjust layout to make room for the legend
    plt.tight_layout()

    # Save the plot to a bytes buffer
    buf = io.BytesIO()
    plt.savefig(buf, format='png', dpi=150)
    buf.seek(0)

    return buf


def main():
    args = parse_arguments()

    # Decrypt the data
    data_str = decrypt_data(args.url, args.file_path, args.ssh_key_path)

    # Parse the ledger data
    transactions = parse_ledger_data(data_str)

    # Filter by date range
    filtered_transactions = filter_by_date_range(transactions, args.start_date, args.end_date)

    # Extract expenses
    expenses = extract_expenses(filtered_transactions, args.expenses_only)

    # Generate pie chart
    pie_chart_buffer = generate_pie_chart(expenses)

    if pie_chart_buffer:
        # Write the PNG data directly to stdout
        sys.stdout.buffer.write(pie_chart_buffer.getvalue())


if __name__ == '__main__':
    main()
