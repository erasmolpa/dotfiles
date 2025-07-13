#!/bin/bash
# Ensures Vim is ready with plugins, fzf integration, and dependencies
set -e

# Install vim-plug for Vim plugin management
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  echo "Installing vim-plug for Vim plugin management..."
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
  echo "vim-plug is already installed."
fi

# Run fzf install script for keybindings/completion
if command -v fzf &>/dev/null; then
  echo "Setting up fzf keybindings and completion..."
  "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
else
  echo "fzf not found. Please install with Homebrew first."
fi

echo "Vim dependencies and plugin manager are ready. Installing Vim plugins automatically..."
if vim --cmd 'echo len(filter(values(g:plugs), {k,v -> v.loaded})) == len(keys(g:plugs))' +qall &>/dev/null; then
  echo "✅ All Vim plugins already installed. Skipping."
else
  echo "Installing Vim plugins..."
  vim +PlugInstall +qall
  if [ $? -eq 0 ]; then
    echo "✅ Vim plugins installed successfully."
  else
    echo "⚠️  There was an issue installing Vim plugins. Please check your .vimrc and try manually with :PlugInstall."
  fi
fi
