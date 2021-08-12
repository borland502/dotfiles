#!/bin/sh

# install homebrew/linuxbrew
if ! [ -x "$(command -v brew)" ] ; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# TODO: Package installer script
if ! [ -x "$(command -v chezmoi)" ] ; then
    brew install chezmoi
fi

# chezmoi init --apply --verbose --dry-run git@github.com:borland502/dotfiles.git 
chezmoi init git@github.com:borland502/dotfiles.git
chezmoi diff
