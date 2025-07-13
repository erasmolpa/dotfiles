#!/bin/sh
## SEE https://jimkang.medium.com/install-go-on-mac-with-homebrew-5fa421fc55f5

if ! command -v go >/dev/null 2>&1; then
  echo "Installing Go..."
  brew update && brew install golang
else
  echo "Go already installed. Skipping."
fi

echo 'setup GO workspace'
mkdir -p $HOME/go/{bin,src,pkg}

echo 'setup GO Environment'
export GOPATH=$HOME/go
export GOROOT="$(brew --prefix golang)/libexec"
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"

echo 'installing GO Version Manager'
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

gvm listall