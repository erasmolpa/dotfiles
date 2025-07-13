#!/bin/sh
## SEE https://jimkang.medium.com/install-go-on-mac-with-homebrew-5fa421fc55f5

brew update&& brew install golang

echo 'setup GO workspace'
mkdir -p $HOME/go/{bin,src,pkg}

echo 'setup GO Environment'
export GOPATH=$HOME/go
export GOROOT="$(brew --prefix golang)/libexec"
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"

echo 'installing GO Version Manager'
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

gvm listall