#!/bin/sh
# Decrypt the secret store

# check if the user supplied an arg
if [ -z "$1" ]; then
  echo "Error: Please provide the path to the encrypted secrets store"
  exit 1
fi

ENCRYPTED_SECRETS_STORE_PATH="$1"

# check that the store exists. If it doesn't it probably needs to be unencrypted.
if [ ! -f "$ENCRYPTED_SECRETS_STORE_PATH" ]; then
  echo "Error: Encrypted secrets store not found at $ENCRYPTED_SECRETS_STORE_PATH"
  exit 1
fi

REPO_ROOT="$(dirname ENCRYPTED_SECRETS_STORE_PATH)"

SECRET_STORE_DIR="$REPO_ROOT/secrets"

if [ -d "$SECRET_STORE_DIR" ]; then
  printf "\033[31mSecret store directory already exists, do you want to continue? This will overwrite the store [y/N]: \033[0m"
  read -r response
  if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
    echo "Operation cancelled."
    exit 0
  fi
fi

rm -rf "$SECRET_STORE_DIR"
mkdir "$SECRET_STORE_DIR"
sops decrypt "$ENCRYPTED_SECRETS_STORE_PATH" | tar -xzvf - -C "$REPO_ROOT"
