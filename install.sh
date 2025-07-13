#!/bin/bash

# One-time git repo initialization for dotfiles
if [ ! -d ".git" ]; then
  echo "Initializing git repository for dotfiles..."
  git init
  echo -e "# Ignore sensitive files\ncredentials\nconfig" > .gitignore
  git add .
  git commit -m "Initial commit: Backup of dotfiles and configuration"
  echo "Git repository initialized and first commit created."
else
  echo "Git repository already initialized."
fi

echo "🔧 Setting up your Mac..."

# Ensure all scripts are executable
chmod +x clone.sh python_config.sh golang_config.sh ia_config.sh

# Check for Oh My Zsh and install if we don't have it
if ! command -v omz >/dev/null 2>&1; then
  echo "Installing Oh My Zsh..."
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
else
  echo "Oh My Zsh already installed. Skipping."
fi

# Check for Homebrew and install if we don't have it
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew already installed. Skipping."
fi

# Symlink .zshrc and .mackup.cfg from repo to $HOME
ln -sf "$PWD/.zshrc" "$HOME/.zshrc"
ln -sf "$PWD/.mackup.cfg" "$HOME/.mackup.cfg"

# Update Homebrew recipes and install bundle dependencies (skip if already installed)
echo "Updating Homebrew recipes..."
brew update

echo "Ensuring homebrew/bundle is tapped..."
brew tap homebrew/bundle || echo "homebrew/bundle already tapped."

echo "Checking and installing Brewfile dependencies..."
brew bundle check --file "$PWD/Brewfile" || brew bundle --file "$PWD/Brewfile"

# Create project directories
mkdir -p "$HOME/Work/mine"

# Pre-install bootstrap (optional, for clean installs)
if [ -f pre_install.sh ]; then
  echo "🚀 Running pre_install.sh..."
  ./pre_install.sh
fi

# Clone Github repositories
./clone.sh

# (Optional) Set macOS preferences
if [ -f .macos ]; then
  echo "ℹ️  To apply macOS preferences, run: source ./.macos"
fi

# Configure Python
echo "🐍 Configuring Python environment..."
./installation_scripts/python_install.sh

# Configure Go
echo "🔵 Configuring Go environment..."
./installation_scripts/golang_install.sh

# Configure AI/DevOps tools
echo "🤖 Configuring AI/DevOps tools..."
./installation_scripts/ia_install.sh

echo "✅ All done! Your Mac is ready."