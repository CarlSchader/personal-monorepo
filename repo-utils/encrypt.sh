#!/bin/sh
# Encrypt the secret store

# check if the user supplied an arg
if [ -z "$1" ]; then
  echo "Error: Please provide the path to the secrets store directory"
  exit 1
fi

SECRETS_STORE_PATH="$1"

REPO_ROOT="$(dirname "$SECRETS_STORE_PATH")"

# check that the store exists. If it doesn't it probably needs to be unencrypted.
if [ ! -d "$SECRETS_STORE_PATH" ]; then
  echo "Error: Secrets store not found at $SECRETS_STORE_PATH"
  exit 1
fi

ENCRYPTED_SECRET_STORE_PATH="$SECRETS_STORE_PATH.tar.gz.enc"

if [ -d "$ENCRYPTED_SECRET_STORE_PATH" ]; then
  printf "\033[31mEncrypted secret store directory already exists, do you want to continue? This will overwrite the encrypted store [y/N]: \033[0m"
  read -r response
  if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
    echo "Operation cancelled."
    exit 0
  fi
fi

rm -rf "$ENCRYPTED_SECRET_STORE_PATH"

cd "$REPO_ROOT"

tar --no-xattrs -czvf "secrets.tar.gz" secrets
sops encrypt "secrets.tar.gz" --output "secrets.tar.gz.enc"

rm -rf "secrets.tar.gz"
