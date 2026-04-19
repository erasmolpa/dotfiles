#!/usr/bin/env bash
# install.sh — Repository entrypoint; delegates to bootstrap/setup.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

if [[ ! -d ".git" ]]; then
  echo "[+] Initializing git repository in $REPO_ROOT ..."
  git init
  if [[ ! -f .gitignore ]]; then
    echo -e "# Ignore sensitive files\ncredentials\nconfig" >.gitignore
  fi
  git add .
  git commit -m "Initial commit: dotfiles backup" || true
fi

exec "$REPO_ROOT/bootstrap/setup.sh" "$@"
