#!/bin/sh

# This is the only script which needs to be downloaded ahead of time and executed outside the repo
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/borland502/dotfiles/main/bootstrap.sh)"

# System dependant options that cannot be avoided for subsequent brew installs
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  local DISTRIB=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

  # Options that apply to any linux system (WSL or otherwise)

  if [[ ${DISTRIB} = "Ubuntu"* ]]; then

    if uname -a | grep -q '^Linux.*Microsoft'; then
      # ubuntu via WSL Windows Subsystem for Linux

    else
      # native ubuntu
    fi
  elif [[ ${DISTRIB} = "Debian"* ]]; then
    # debian
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS OSX prerequisite -- no harm if run again and it will also take care of git well enough for the initial stuff
  sudo xcode-select --install
fi

# install homebrew/linuxbrew
if ! [ -x "$(command -v brew)" ] ; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! [ -x "$(command -v brew)" ] ; then
  echo "brew did not install properly"
  exit -1
fi

# Most packages will be installed in the 00 script, but we need the rest of the files in order to proceed
if ! [ -x "$(command -v chezmoi)" ] ; then
    brew install chezmoi
fi

# chezmoi init --apply --verbose --dry-run git@github.com:borland502/dotfiles.git 
chezmoi init git@github.com:borland502/dotfiles.git
chezmoi diff

#TODO Pause script here for user go/nogo

chezmoi apply
