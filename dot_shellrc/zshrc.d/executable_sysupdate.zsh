#!/usr/bin/env zsh

function sysupdate {

  #Homebrew update and prune outdated cache
  brew update
  brew upgrade
  brew cleanup -s

  #now diagnostic
  brew doctor
  brew missing

  # NPM global update
  npm update -g
  npm install -g npm

  # Python3 updates (will error if you have nothing to update)
  pip3 install -U $(pip3 freeze | awk '{split($0, a, "=="); print a[1]}')

  # misc updates
  tldr --update

  # OSX Specific updates
  if [[ -x "$(command -v softwareupdate)" ]]; then
    softwareupdate --all --install --force
  fi

}
