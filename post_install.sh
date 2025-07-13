#!/bin/bash

# This script runs after install.sh to finalize and optimize your setup.
# - Updates all Homebrew, pipx, and npm global packages
# - Runs diagnostics and security checks
# - Reminds user to check AI/agent tools

set -e

echo "🔄 Updating Homebrew..."
brew update && brew upgrade

if command -v pipx &>/dev/null; then
  echo "🔄 Updating pipx packages..."
  pipx upgrade-all || true
fi

if command -v npm &>/dev/null; then
  echo "🔄 Updating global npm packages..."
  npm update -g || true
fi

echo "🔎 Running security and system diagnostics..."
if command -v pre-commit &>/dev/null; then
  pre-commit run --all-files || true
fi
if command -v trivy &>/dev/null; then
  trivy fs . || true
fi
if command -v brew &>/dev/null; then
  brew doctor || true
fi

echo "✅ Post-install checks complete! Review above for any issues."

# Generate a requirements.txt file with installed pip packages
echo "Generating requirements.txt file with installed pip packages..."
pip freeze > "$PWD/requirements.txt"

echo "👉 Next: Test your AI/agent tools (ollama, llama.cpp, Copilot, etc.) and review README for workflows."
