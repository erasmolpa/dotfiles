#!/bin/bash
# post-install.sh — Post-setup update, diagnostics, and security automation
set -e

# 1. Update all major package managers
brew update && brew upgrade
pipx upgrade-all || true
npm update -g || true

# 2. Run security/code checks if pre-commit is present
if [ -f "$HOME/.dotfiles/repo_dotfiles/.pre-commit.yml" ]; then
  pre-commit run --all-files || true
fi

# 3. Print diagnostics
brew doctor || true

# 4. Print completion message
cat <<EOF
[✔] Post-install complete! System updated and checked.
EOF
