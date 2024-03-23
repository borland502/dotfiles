#!/usr/bin/env zsh

#Homebrew update and prune outdated cache
if [[ $(command -v brew) ]]; then
  brew update
  brew upgrade
  brew cleanup -s

  #now diagnostic
  brew doctor
  brew missing
fi

if [[ $(command -v npm) ]]; then
  # NPM global update
  npm update -g
  npm install -g npm
fi

if [[ $(command -v pip3) ]]; then
  # Python3 updates (will error if you have nothing to update)
  pip3 install -U $(pip3 freeze | awk '{split($0, a, "=="); print a[1]}')
fi

if [[ $(command -v tldr) ]]; then
  # misc updates
  tldr --update
fi

# OSX Specific updates
if [[ -x "$(command -v softwareupdate)" ]]; then
  softwareupdate --all --install --force
fi

if [[ "$(command -v zi)" ]]; then
  zi update --all
fi
