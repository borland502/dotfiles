#!/usr/bin/env bash
set -e

# Script outline and structure borrowed from https://raw.githubusercontent.com/home-assistant/supervised-installer/master/installer.sh

declare -a MISSING_PACKAGES

function info { echo -e "[info] $*"; }
function warn  { echo -e "[warn] $*"; }
function error { echo -e "[error] $*"; exit 1; }

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

# get sudo permission early in the install
# https://askubuntu.com/questions/15853/how-can-a-script-check-if-its-being-run-as-root
if [[ $EUID -ne 0 ]]; then
    echo "Enter credentials for sensitive installs"
    ask_for_sudo
fi

ARCH=$(uname -m)

# os and dist detection https://unix.stackexchange.com/questions/6345/how-can-i-get-distribution-name-and-version-number-in-a-simple-shell-script
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    # shellcheck disable=SC1091
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    # shellcheck disable=SC1091
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, WSL, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

if [ -z "$OSTYPE" ]; then
  # rare, but some distros (wsl) do not have this file so sub in the $OS var
  if [[ -x "/etc/os-release" ]]; then
    OSTYPE=$OS
  fi
fi

IS_WSL=false

info "$ARCH"
info "$OS" "$VER"
info "$OSTYPE"

warn ""
warn "If you want to abort, hit ctrl+c within 10 seconds..."
warn ""

sleep 10

info "Installing prerequities"

if [ ! -d "$HOME/bin/" ]; then
    mkdir "$HOME/bin"
fi

if [[ "$OSTYPE" == "linux"* ]]; then
    if uname -a | grep -q '^Linux.*Microsoft'; then
        IS_WSL=true
    fi

    ## Linuxbrew preqs
    if [ -x "$(command -v apt)" ]; then
        sudo apt-get update
        sudo apt-get -y install build-essential procps curl file git gnupg2 zsh
    elif [[ -x "$(command -v yum)" ]]; then
        sudo yum update
        sudo yum -y groupinstall 'Development Tools'
        sudo yum -y install procps-ng curl file git gnupg2 zsh
        sudo yum -y install libxcrypt-compat
    elif [ -x "$(command -v opkg)" ]; then
        # TODO Prune way back installs on this branch; the types of things that run opkg don't need full stack dev tools
        sudo opkg update
        sudo opkg install curl file git git-http ca-certificates ldd zsh ruby gnupg2
    fi

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
fi

info "WSL? $IS_WSL"

# install homebrew/linuxbrew
if ! [ -x "$(command -v brew)" ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! [ -x "$(command -v brew)" ]; then
  error "brew did not install properly"
fi

#current session
eval "$(brew --prefix)/bin/brew shellenv"

# TODO Bootstrap the linux brew path -- on mac it is just redundant.  Clobber what's there, we won't use it with zsh
echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" > "$HOME/.profile"

# Check env after preliminaries -- TODO: More verification
command -v git > /dev/null 2>&1 || MISSING_PACKAGES+=("git")
command -v curl > /dev/null 2>&1 || MISSING_PACKAGES+=("curl")

if [ -n "${MISSING_PACKAGES}" ]; then
    warn "The following is missing on the host and needs "
    warn "to be installed and configured before running this script again"
    error "missing: ${MISSING_PACKAGES[@]}"
fi

# Most packages will be installed in the 00 script, but we need the rest of the files in order to proceed
if ! [[ -x "$(command -v chezmoi)" ]]; then
  brew install chezmoi
fi

# Required for decryption
if ! [[ -x "$(command -v age)" ]]; then
  brew install age
fi

if ! [[ -d "$HOME/.local/share/chezmoi" ]]; then
  # chezmoi init --apply --verbose --dry-run git@github.com:borland502/dotfiles.git
  chezmoi init git@github.com:borland502/dotfiles.git
  chezmoi diff
fi

#TODO check for the .ssh key and for access to github

#Check for age key and binary
if [ ! -f "$HOME/bin/key.txt" ]; then
    error "Age decryption key is not present"
fi

info "bootstrap complete."
info ""
warn ""
warn "If you want to abort chezmoi download, hit ctrl+c within 10 seconds..."
warn ""

sleep 10

chezmoi apply