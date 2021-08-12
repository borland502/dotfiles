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

  # Python3 updates (will error if you have nothing to update)
  pip3 install -U $(pip3 freeze | awk '{split($0, a, "=="); print a[1]}')

  # misc updates
  tldr --update

  # Mac Store update
  echo “you can hit mas upgrade to upgrade theses apps from the app store:”
  mas outdated

}
