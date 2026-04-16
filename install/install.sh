#!/bin/bash
# install.sh — Automated setup for macOS dotfiles (helpers, wizards, Brewfile, etc.)
set -e

# 1. Install Oh My Zsh if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "[+] Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
fi

# 2. Install Homebrew if missing
if ! command -v brew >/dev/null 2>&1; then
  echo "[+] Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 3. Symlink dotfiles and helpers
DOTFILES="$HOME/.dotfiles/repo_dotfiles"
ln -sf "$DOTFILES/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES/.mackup.cfg" "$HOME/.mackup.cfg"
ln -sf "$DOTFILES/.macos" "$HOME/.macos"
ln -sf "$DOTFILES/helpers" "$HOME/.oh-my-zsh/custom/helpers"
ln -sf "$DOTFILES/wizards" "$HOME/.oh-my-zsh/custom/wizards"

# 4. Install Brewfile dependencies
if [ -f "$DOTFILES/Brewfile" ]; then
  echo "[+] Installing Brewfile packages..."
  brew bundle --file="$DOTFILES/Brewfile"
fi

# 5. Run language/tool install scripts if present
if [ -d "$DOTFILES/installation_scripts" ]; then
  for script in "$DOTFILES"/installation_scripts/*.sh; do
    [ -x "$script" ] && "$script"
  done
fi

# 6. Create project directories
mkdir -p "$HOME/Code" "$HOME/Herd" "$HOME/Library"

# 7. Clone personal repos if clone.sh exists
if [ -f "$DOTFILES/clone.sh" ]; then
  zsh "$DOTFILES/clone.sh"
fi

# 8. Print completion message
cat <<EOF
[✔] Dotfiles and tools installed!
Open a new terminal or run: source ~/.zshrc
EOF
