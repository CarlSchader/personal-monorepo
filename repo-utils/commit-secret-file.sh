#!/bin/sh

STDIN_CONTENTS=$(cat)
SECRET_STORE_BLOB_URL="https://raw.githubusercontent.com/CarlSchader/personal-monorepo/refs/heads/main/secrets.tar.gz.enc"

mkdir -p /var/tmp/personal-monorepo/secrets

# check if the user supplied two args
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: commit-secret-file <secret_file_path> <github_token> [ssh_key_path]"
  echo "if ssh_key_path isn't given then we fallback to ~/.ssh/id_ed25519 then ~/.ssh/id_rsa"
  exit 1
fi

SECRET_FILE_PATH=$1
GITHUB_TOKEN=$2

if [ ! -z "$3" ]; then
  export SOPS_AGE_SSH_PRIVATE_KEY_FILE=$3
fi

# decrypt, decompress, and extract the entire secret store blob and save the directory in /var/tmp/personal-monorepo/secrets
sudo curl -L $SECRET_STORE_BLOB_URL | sops decrypt | tar -xzf - -C /var/tmp/personal-monorepo/

# update the secret file with the new secret file contents from stdin
sudo echo "$STDIN_CONTENTS" > /var/tmp/personal-monorepo/$SECRET_FILE_PATH

# re-archive, compress, and encrypt the secret store blob
NEW_SECRET_STORE_BLOB=$(sudo tar -czf - /var/tmp/personal-monorepo | sops encrypt)
echo "$NEW_SECRET_STORE_BLOB"
exit 0
