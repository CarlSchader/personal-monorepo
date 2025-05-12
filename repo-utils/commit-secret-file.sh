#!/bin/sh

STDIN_CONTENTS=$(cat)
SECRET_STORE_BLOB_URL="https://raw.githubusercontent.com/CarlSchader/personal-monorepo/refs/heads/main/secrets.tar.gz.enc"
SOPS_CONFIG_BLOB_URL="https://raw.githubusercontent.com/CarlSchader/personal-monorepo/refs/heads/main/.sops.yaml"
REPO="carlschader/personal-monorepo"

mkdir -p /var/tmp/personal-monorepo

cd /var/tmp/personal-monorepo

# check if the user supplied two args
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: commit-secret-file <secret_file_path> <commit_message> <github_token> [ssh_key_path]"
  echo "if ssh_key_path isn't given then we fallback to ~/.ssh/id_ed25519 then to ~/.ssh/id_rsa"
  exit 1
fi

SECRET_FILE_PATH=$1
COMMIT_MESSAGE=$2
GITHUB_TOKEN=$3

if [ ! -z "$4" ]; then
  export SOPS_AGE_SSH_PRIVATE_KEY_FILE=$4
else
  if [ -f ~/.ssh/id_ed25519 ]; then
    export SOPS_AGE_SSH_PRIVATE_KEY_FILE=~/.ssh/id_ed25519
  elif [ -f ~/.ssh/id_rsa ]; then
    export SOPS_AGE_SSH_PRIVATE_KEY_FILE=~/.ssh/id_rsa
  else
    echo "No SSH key found at ~/.ssh/id_ed25519 or ~/.ssh/id_rsa"
    exit 1
  fi
fi

curl -L $SECRET_STORE_BLOB_URL | sops decrypt | tar -xzf - -C ./

# decrypt, decompress, and extract the entire secret store blob and save the directory in secrets
curl -LO $SOPS_CONFIG_BLOB_URL

# update the secret file with the new secret file contents from stdin
echo -n "$STDIN_CONTENTS" > $SECRET_FILE_PATH

tar --no-xattrs -czvf secrets.tar.gz secrets
sops encrypt secrets.tar.gz --output secrets.tar.gz.enc

# pass encrypted blob into commit-file to replace the secret store in github
cat secrets.tar.gz.enc | commit-file --repo "$REPO" --file secrets.tar.gz.enc --message "$COMMIT_MESSAGE" --token "$GITHUB_TOKEN"
