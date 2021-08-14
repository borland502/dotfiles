#!/bin/bash

# This is the only script which needs to be downloaded ahead of time and executed outside the repo
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/borland502/dotfiles/main/bootstrap.sh)"

# TODO Flag for the level of installation

###############################################################################
# Prompts from Slay: https://github.com/minamarkham/formation/blob/master/twirl
###############################################################################
ask_for_sudo() {

    # Ask for the administrator password upfront.

    sudo -v &> /dev/null

    # Update existing `sudo` time stamp
    # until this script has finished.
    #
    # https://gist.github.com/cowboy/3118588

    # Keep-alive: update existing `sudo` time stamp until script has finished.  This does not work with homebrew's few priviliged installs
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

    echo "Password cached"
}

ask_for_sudo

ask() {
    # https://djm.me/ask
    local prompt default reply

    while true; do

        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -n "  [?] $1 [$prompt] "

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read reply </dev/tty

        # Default?
        if [ -z "$reply" ]; then
            reply=$default
        fi

        # Check if the reply is valid
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

# System dependant options that cannot be avoided for subsequent brew installs
if [[ "$OSTYPE" == "linux"* ]]; then
    local DISTRIB=Other

    # rare, but some distros do not have this file
    if [[ -x "/etc/os-release" ]]; then
      DISTRIB=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    fi

  # Options that apply to any linux system (WSL or otherwise)

  ## Linuxbrew preqs
  if [ -x "$(command -v apt)"]; then
    sudo apt-get update
    sudo apt-get -y install build-essential procps curl file git
  elif [ -x "$(command -v yum)"]; then
    sudo yum update
    sudo yum -y groupinstall 'Development Tools'
    sudo yum -y install procps-ng curl file git
    sudo yum -y install libxcrypt-compat
  elif [ -x "$(command -v opkg)"]; then
    # TODO Prune way back installs on this branch; the types of things that run opkg don't need full stack dev tools
    sudo opkg update
    sudo opkg install -y build-essential procps curl file git ca-certificates ldd zsh
  fi     

  #if [[ ${DISTRIB} = "Ubuntu"* ]]; then
    #if uname -a | grep -q '^Linux.*Microsoft'; then
      # ubuntu via WSL Windows Subsystem for Linux
    #else
      # native ubuntu
    #fi
  #elif [[ ${DISTRIB} = "Debian"* ]]; then
    # debian
  #fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS OSX prerequisite -- no harm if run again and it will also take care of git well enough for the initial stuff
  # -----------------------------------------------------------------------------
  # XCode -- From Slay (https://github.com/minamarkham/formation/blob/master/slay)
  # -----------------------------------------------------------------------------
  if type xcode-select >&- && xpath=$( xcode-select --print-path ) &&
    test -d "${xpath}" && test -x "${xpath}" ; then
    echo "Xcode already installed. Skipping."
  else
    step "Installing Xcode…"
    xcode-select --install
    echo "Xcode installed!"
  fi

  if [ ! -d "$HOME/.bin/" ]; then
    mkdir "$HOME/.bin"
  fi
fi

# install homebrew/linuxbrew
if ! [ -x "$(command -v brew)" ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! [ -x "$(command -v brew)" ]; then
  echo "brew did not install properly"
  exit -1
fi

# Most packages will be installed in the 00 script, but we need the rest of the files in order to proceed
if ! [[ -x "$(command -v chezmoi)" ]]; then
    brew install chezmoi
fi

if ! [[ -d "$HOME/.local/share/chezmoi" ]]; then
  # chezmoi init --apply --verbose --dry-run git@github.com:borland502/dotfiles.git 
  chezmoi init git@github.com:borland502/dotfiles.git
  chezmoi diff
fi

  #TODO Pause script here for user go/nogo
chezmoi apply  