#!/bin/bash

# === Parse arguments ===
while getopts "u:e:" opt; do
  case $opt in
    u) GIT_USER="$OPTARG" ;;
    e) GIT_EMAIL="$OPTARG" ;;
    *) echo "Usage: $0 -u <username> -e <email>" && exit 1 ;;
  esac
done

if [[ -z "$GIT_USER" || -z "$GIT_EMAIL" ]]; then
  echo "Both -u (username) and -e (email) are required."
  echo "Usage: $0 -u <username> -e <email>"
  exit 1
fi

# === Generate SSH key if not already present ===
if [ ! -f ~/.ssh/id_rsa ]; then
  echo "[*] Generating new SSH key for $GIT_EMAIL"
  ssh-keygen -t rsa -b 4096 -C "$GIT_EMAIL" -f ~/.ssh/id_rsa -N ""
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa
  echo "[+] SSH key created and added to ssh-agent."
else
  echo "[=] SSH key already exists at ~/.ssh/id_rsa — skipping generation."
fi

# === Configure Git identity ===
echo "[*] Setting global Git config for user.name and user.email"
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"

# === Output the public key for GitHub use ===
echo "[*] Your SSH public key (add it to GitHub/Bitbucket/GitLab):"
echo
cat ~/.ssh/id_rsa.pub
echo
echo "[+] Done!"

