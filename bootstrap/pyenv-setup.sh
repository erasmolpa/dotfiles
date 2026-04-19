#!/usr/bin/env bash
# bootstrap/pyenv-setup.sh — pyenv + uv + default Python (idempotent; no pip packages here).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$DOTFILES"

if ! command -v python3 >/dev/null 2>&1; then
  echo "[+] Installing Python via Homebrew..."
  brew install python || true
fi

if ! command -v pyenv >/dev/null 2>&1; then
  echo "[+] Installing pyenv..."
  brew install pyenv
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "[+] Installing uv..."
  brew install uv
fi

if [[ -d .git ]] && [[ -f .pre-commit.yml ]] && command -v pre-commit >/dev/null 2>&1; then
  echo "[+] pre-commit install (hooks)..."
  pre-commit install || true
fi

if command -v pyenv >/dev/null 2>&1; then
  if ! pyenv versions --bare | grep -qx '3.9.2'; then
    pyenv install 3.9.2
  fi
  pyenv global 3.9.2 || true
fi

grep -qxF 'export PYENV_ROOT="$HOME/.pyenv"' "${HOME}/.bash_profile" 2>/dev/null || echo 'export PYENV_ROOT="$HOME/.pyenv"' >>"${HOME}/.bash_profile"
grep -qxF 'export PATH="$PYENV_ROOT/bin:$PATH"' "${HOME}/.bash_profile" 2>/dev/null || echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >>"${HOME}/.bash_profile"

echo "[✔] pyenv-setup done (pip packages: macctl apply --only=python)."
