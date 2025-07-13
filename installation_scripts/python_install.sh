#!/bin/sh

brew update&& brew install python
brew update&& brew install pyenv

## SEE https://www.freecodecamp.org/news/python-version-on-mac-update/
echo 'setup pyenv path'
/usr/local/bin:/usr/bin:/bin
# installing python
pyenv install 3.9.2

echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile

echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc

pyenv global 3.9.2
