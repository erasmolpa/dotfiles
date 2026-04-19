#!/usr/bin/env bash
# bootstrap/setup.sh — macOS bootstrap: Oh My Zsh, Homebrew, config symlinks, macctl apply.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$SCRIPT_DIR/.." && pwd)"
export DOTFILES

CANONICAL="$HOME/.dotfiles"
if [[ "$DOTFILES" != "$CANONICAL" ]]; then
  echo "[!] Warning: repository is at $DOTFILES but .zshrc expects DOTFILES=$CANONICAL."
  echo "    Clone or move this repo to $CANONICAL to keep paths consistent."
fi

chmod +x "$DOTFILES"/bin/macctl "$DOTFILES"/bootstrap/*.sh "$DOTFILES"/modules/*.sh "$DOTFILES"/scripts/*.sh 2>/dev/null || true

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "[+] Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "[+] Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

echo "[+] Linking config/ into \$HOME ..."
ln -sf "$DOTFILES/config/zsh/.zshrc" "$HOME/.zshrc"
[[ -f "$DOTFILES/.mackup.cfg" ]] && ln -sf "$DOTFILES/.mackup.cfg" "$HOME/.mackup.cfg"
[[ -f "$DOTFILES/config/mac/.macos" ]] && ln -sf "$DOTFILES/config/mac/.macos" "$HOME/.macos"
[[ -f "$DOTFILES/config/git/.gitconfig" ]] && ln -sf "$DOTFILES/config/git/.gitconfig" "$HOME/.gitconfig"
[[ -f "$DOTFILES/config/git/.gitignore_global" ]] && ln -sf "$DOTFILES/config/git/.gitignore_global" "$HOME/.gitignore_global"
[[ -f "$DOTFILES/config/mac/.bash_profile" ]] && ln -sf "$DOTFILES/config/mac/.bash_profile" "$HOME/.bash_profile"

echo "[+] macctl apply --only=brew ..."
"$DOTFILES/bin/macctl" apply --only=brew

echo "[+] Creating work directories..."
mkdir -p "$HOME/Work/mine" "$HOME/Code" "$HOME/Herd" "$HOME/Library"

if [[ -f "$DOTFILES/bootstrap/clone-repos.sh" ]]; then
  echo "[+] Cloning optional personal repositories..."
  bash "$DOTFILES/bootstrap/clone-repos.sh"
fi

if [[ -f "$DOTFILES/bootstrap/pyenv-setup.sh" ]]; then
  bash "$DOTFILES/bootstrap/pyenv-setup.sh"
fi

echo "[+] macctl apply --only=golang,python,node,vim,ia ..."
"$DOTFILES/bin/macctl" apply --only=golang,python,node,vim,ia

if [[ -f "$DOTFILES/config/mac/.macos" ]]; then
  echo "[i] macOS defaults: apply manually if desired:"
  echo "    source $DOTFILES/config/mac/.macos"
fi

cat <<EOF

[OK] Dotfiles setup complete.
    Open a new terminal or run:  source ~/.zshrc
    Preview changes:            $DOTFILES/bin/macctl plan
    Post-update (optional):     $DOTFILES/bootstrap/post-setup.sh
EOF
