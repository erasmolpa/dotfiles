#!/usr/bin/env bash
# bootstrap/post-setup.sh — Post-setup updates and optional security checks.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$SCRIPT_DIR/.." && pwd)"
export DOTFILES

echo "[+] Updating Homebrew..."
brew update && brew upgrade

if command -v pipx &>/dev/null; then
  echo "[+] Upgrading pipx packages..."
  pipx upgrade-all || true
fi

if command -v npm &>/dev/null; then
  echo "[+] Updating global npm packages..."
  npm update -g || true
fi

echo "[+] Security / code diagnostics..."
if command -v pre-commit &>/dev/null && [[ -f "$DOTFILES/.pre-commit.yml" ]]; then
  (cd "$DOTFILES" && pre-commit run --all-files) || true
fi
if command -v trivy &>/dev/null; then
  (cd "$DOTFILES" && trivy fs .) || true
fi
if command -v brew &>/dev/null; then
  brew doctor || true
fi

if command -v python3 &>/dev/null && python3 -m pip --version &>/dev/null; then
  echo "[+] Writing state/python-installed.txt from pip freeze..."
  mkdir -p "$DOTFILES/state"
  python3 -m pip freeze 2>/dev/null | sort -u >"$DOTFILES/state/python-installed.txt" || true
fi

echo "[OK] Post-setup complete. Review any warnings above."
echo "    Try: $DOTFILES/bin/macctl doctor"
