#!/bin/bash

set -euo pipefail

# One password version
OP_VERSION=1.11.2

SYS_UNAME=$(uname -a)
echo "$SYS_UNAME"

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
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2> /dev/null &

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
    read reply < /dev/tty

    # Default?
    if [ -z "$reply" ]; then
      reply=$default
    fi

    # Check if the reply is valid
    case "$reply" in
      Y* | y*) return 0 ;;
      N* | n*) return 1 ;;
    esac

  done
}

# System dependant options that cannot be avoided for subsequent brew installs
if [[ "$OSTYPE" == "linux"* ]]; then
  DISTRIB=Other

  # rare, but some distros do not have this file
  if [[ -x "/etc/os-release" ]]; then
    DISTRIB=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
  fi

  # Options that apply to any linux system (WSL or otherwise)

  ## Linuxbrew preqs
  if [ -x "$(command -v apt)" ]; then
    sudo apt-get update
    sudo apt-get -y install build-essential procps curl file git gpg
  elif [[ -x "$(command -v yum)" ]]; then
    sudo yum update
    sudo yum -y groupinstall 'Development Tools'
    sudo yum -y install procps-ng curl file git gpg
    sudo yum -y install libxcrypt-compat
  elif [ -x "$(command -v opkg)" ]; then
    # TODO Prune way back installs on this branch; the types of things that run opkg don't need full stack dev tools
    sudo opkg update
    sudo opkg install curl file git git-http ca-certificates ldd zsh ruby gpg
  fi

  # 1password: Set up, but do not sign in so that chezmoi can encrypt sensitive stuff
  if [[ "$SYS_UNAME" == *'x86_64'* ]]; then
    curl -o 1password.zip "https://cache.agilebits.com/dist/1P/op/pkg/v$OP_VERSION/op_linux_amd64_v$OP_VERSION.zip"
  elif [[ "$SYS_UNAME" == *"arm64"* ]]; then
    curl -o 1password.zip "https://cache.agilebits.com/dist/1P/op/pkg/v$OP_VERSION/op_linux_arm64_v$OP_VERSION.zip"
  elif [[ "$SYS_UNAME" == *"arm"* ]]; then
    curl -o 1password.zip "https://cache.agilebits.com/dist/1P/op/pkg/v$OP_VERSION/op_linux_arm_v$OP_VERSION.zip"
  else
    echo "Cannot install 1password"
  fi  

  mkdir "$HOME/.bin"
  unzip 1password.zip -d "$HOME/.bin" && \
  rm 1password.zip

  chmod 755 "$HOME/.bin/op"
  chmod 755 "$HOME/.bin/op.sig"

  # add .bin to the path
  PATH=$PATH:./bin

  # specify the firewall friendly keyserver form
  gpg --keyserver hkp://keyserver.ubuntu.com:80 --receive-keys 3FEF9748469ADBE15DA7CA80AC2D62742012EA22 || exit
  gpg --verify "$HOME/.bin/op.sig" "$HOME/.bin/op" || exit

  op update

  if ! [[ -x "$(command -v op)" ]]; then
    echo "1password install failed for linux"
    exit -1
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
  if type xcode-select >&- && xpath=$(xcode-select --print-path) &&
    test -d "${xpath}" && test -x "${xpath}"; then
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
