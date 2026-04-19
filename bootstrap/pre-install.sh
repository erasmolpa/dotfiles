#!/usr/bin/env bash
# bootstrap/pre-install.sh — Minimal bootstrap for a machine without Homebrew or this repo.
# Typical use: run from a copy of this script, or after curl (see README).
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "[+] Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"${HOME}/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

if ! command -v git >/dev/null 2>&1; then
  echo "[+] Installing git..."
  brew install git
fi

DOTFILES_TARGET="${DOTFILES_TARGET:-$HOME/.dotfiles}"
if [[ ! -d "$DOTFILES_TARGET/.git" ]]; then
  echo "[+] Cloning dotfiles into $DOTFILES_TARGET ..."
  git clone https://github.com/erasmolpa/dotfiles.git "$DOTFILES_TARGET"
else
  echo "[=] $DOTFILES_TARGET already exists; skipping clone."
fi

echo "[OK] Pre-install finished. Next: cd $DOTFILES_TARGET && ./bootstrap/setup.sh"
