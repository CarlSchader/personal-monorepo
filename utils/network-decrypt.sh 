#!/bin/sh

# check if the user supplied two args
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: network-decrypt <url> <file_path> [ssh_key_path]"
  echo "if ssh_key_path isn't given then we fallback to ~/.ssh/id_ed25519 then ~/.ssh/id_rsa"
  exit 1
fi

URL=$1
FILE_PATH=$2

if [ ! -z "$3" ]; then
  export SOPS_AGE_SSH_PRIVATE_KEY_FILE=$3
fi

curl -L $URL | sops decrypt | tar -xzO $FILE_PATH
