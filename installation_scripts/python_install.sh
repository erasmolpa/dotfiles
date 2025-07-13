#!/bin/sh

if ! command -v python3 >/dev/null 2>&1; then
  echo "Installing Python..."
  brew update && brew install python
else
  echo "Python already installed. Skipping."
fi

if ! command -v pyenv >/dev/null 2>&1; then
  echo "Installing pyenv..."
  brew update && brew install pyenv
else
  echo "pyenv already installed. Skipping."
fi

# Ensure uv is installed
if ! command -v uv >/dev/null 2>&1; then
  echo "Installing uv (Python package manager)..."
  brew install uv
else
  echo "uv already installed. Skipping."
fi

# Install pre-commit with uv
if ! command -v pre-commit >/dev/null 2>&1; then
  echo "Installing pre-commit with uv..."
  uv pip install pre-commit
else
  echo "pre-commit already installed. Skipping."
fi

# Activate pre-commit hooks if in a git repo and config exists
if [ -d .git ] && [ -f .pre-commit.yml ]; then
  echo "Activating pre-commit hooks..."
  pre-commit install
else
  echo "No git repo or .pre-commit.yml found, skipping pre-commit hook activation."
fi

## SEE https://www.freecodecamp.org/news/python-version-on-mac-update/
echo 'setup pyenv path'
/usr/local/bin:/usr/bin:/bin
# installing python
if ! pyenv versions | grep -q "3.9.2"; then
  pyenv install 3.9.2
else
  echo "Python 3.9.2 already installed in pyenv. Skipping."
fi

echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile

echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc

pyenv global 3.9.2
