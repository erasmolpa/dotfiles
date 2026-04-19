#!/usr/bin/env bash
# bootstrap/clone-repos.sh — Optional personal repositories (dotfiles live at ~/.dotfiles).
set -euo pipefail

WORK="${WORK:-$HOME/Work}"
echo "[+] Cloning optional repositories under $WORK/mine ..."

mkdir -p "$WORK/mine"

if [[ ! -d "$WORK/mine/profile/.git" ]]; then
  git clone https://github.com/erasmolpa/profile.git "$WORK/mine/profile"
else
  echo "[=] profile already cloned; skipping."
fi
