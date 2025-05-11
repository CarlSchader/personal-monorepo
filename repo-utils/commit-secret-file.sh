#!/bin/sh

STDIN_CONTENTS=$(cat)
SECRET_STORE_BLOB_URL="https://raw.githubusercontent.com/CarlSchader/personal-monorepo/refs/heads/main/secrets.tar.gz.enc"
REPO="carlschader/personal-monorepo"

mkdir -p /var/tmp/personal-monorepo/secrets

# check if the user supplied two args
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: commit-secret-file <secret_file_path> <commit_message> <github_token> [ssh_key_path]"
  echo "if ssh_key_path isn't given then we fallback to ~/.ssh/id_ed25519 then ~/.ssh/id_rsa"
  exit 1
fi

SECRET_FILE_PATH=$1
COMMIT_MESSAGE=$2
GITHUB_TOKEN=$3

if [ ! -z "$4" ]; then
  export SOPS_AGE_SSH_PRIVATE_KEY_FILE=$4
fi

# decrypt, decompress, and extract the entire secret store blob and save the directory in /var/tmp/personal-monorepo/secrets
curl -L $SECRET_STORE_BLOB_URL | sops decrypt | tar -xzf - -C /var/tmp/personal-monorepo/

# update the secret file with the new secret file contents from stdin
echo -n "$STDIN_CONTENTS" > /var/tmp/personal-monorepo/$SECRET_FILE_PATH

# re-archive, compress, and encrypt the secret store blob
NEW_SECRET_STORE_BLOB=$(tar -czvf - /var/tmp/personal-monorepo/secrets | sops encrypt --filename-override=secrets.tar.gz)

# pass encrypted blob into commit-file to replace the secret store in github
echo -n "$NEW_SECRET_STORE_BLOB" | commit-file --repo "$REPO" --file secrets.tar.gz.enc --message "$COMMIT_MESSAGE" --token "$GITHUB_TOKEN"
