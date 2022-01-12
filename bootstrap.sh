#!/usr/bin/env bash
set -e

# Script outline and structure borrowed from https://raw.githubusercontent.com/home-assistant/supervised-installer/master/installer.sh

declare -a MISSING_PACKAGES

function info { echo -e "[info] $*"; }
function warn  { echo -e "[warn] $*"; }
function error { echo -e "[error] $*"; exit 1; }

#TODO Extract these functions into helper scripts
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

if [ ! -d "/home" ]; then
    error "Traditional /home root directory expected.  Is this a synology or other unique device?"
fi

# get sudo permission early in the install
# https://askubuntu.com/questions/15853/how-can-a-script-check-if-its-being-run-as-root
if [[ $EUID -ne 0 ]]; then
    echo "Enter credentials for sensitive installs"
    ask_for_sudo
fi

ARCH="$(uname -m)"
case $ARCH in
  x86_64|amd64)
    ARCH='amd64'
    ;;
  aarch64)
    ARCH='arm64'
    ;;
  i?86|x86)
    ARCH='386'
    ;;
  arm*)
    ARCH='arm'
    ;;
  *)
    error 'OS type not supported'
    ;;
esac

if ! [[ -f $HOME/bin/key.txt ]]; then 
  error 'encryption key missing from ~/bin folder'
fi

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
AGE_VERSION=$(curl -s "https://api.github.com/repos/FiloSottile/age/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')

info "Architecture: $ARCH"
info "OS: $OS" "$VER"
info "OSTYPE: $OSTYPE"
info "HOME: $HOME"
info "AGE Encryption: $AGE_VERSION" 

warn ""
warn "If you want to abort, hit ctrl+c within 10 seconds..."
warn ""

sleep 10

info "Installing prerequities"

if [[ "$OSTYPE" == "linux"* ]]; then
    if uname -a | grep -q '^Linux.*Microsoft'; then
        IS_WSL=true
    fi

    # Older versions of ubuntu and debian don't have age in the repos -- for now, just do it the hard way
    curl -Lo "$HOME/age.tar.gz" "https://github.com/FiloSottile/age/releases/latest/download/age-v${AGE_VERSION}-linux-amd64.tar.gz"
    tar xf "$HOME/age.tar.gz"
    sudo mv age/age /usr/local/bin
    sudo mv age/age-keygen /usr/local/bin
    rm -rf "$HOME/age.tar.gz"
    rm -rf "$HOME/age"

    ## Linuxbrew preqs & flatpak (aka our linux casks)
    if [ -x "$(command -v apt)" ]; then
        sudo apt-get update
        sudo apt-get -y install build-essential procps curl file git gnupg2 zsh sssd heimdal-clients msktutil flatpak

        flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    elif [[ -x "$(command -v yum)" ]]; then
        sudo yum update
        sudo yum -y groupinstall 'Development Tools'
        sudo yum -y install procps-ng curl file git gnupg2 zsh sssd heimdal-clients msktutil flatpak
        sudo yum -y install libxcrypt-compat
    elif [ -x "$(command -v opkg)" ]; then
        sudo opkg update
        sudo opkg install curl file git git-http ca-certificates ldd zsh ruby gnupg2

        curl "$HOME"/https://github.com/FiloSottile/age/releases/download/v1.0.0/age-v1.0.0-linux-amd64.tar.gz | tar -xz -C "$HOME/bin"

        # specific to synology with opkg
        # /var/services/homes/jhettenh
    fi

elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS OSX prerequisite -- no harm if run again and it will also take care of git well enough for the initial stuff
    # -----------------------------------------------------------------------------
    # XCode -- From Slay (https://github.com/minamarkham/formation/blob/master/slay)
    # -----------------------------------------------------------------------------
    if type xcode-select >&- && xpath=$(xcode-select --print-path) &&
        test -d "${xpath}" && test -x "${xpath}"; then
        info "Xcode already installed. Skipping."
    else
        step "Installing Xcode…"
        xcode-select --install
        info "Xcode installed!"
    fi
fi

info "WSL? $IS_WSL"

# we are going all in on the XDG specifications
if ! [[ -d "/etc/xdg" ]]; then
  sudo mkdir /etc/xdg
fi  

# linuxbrew isn't supported on arm yet -- so provide a mininmum install using traditional package managers
if ! [[ "$ARCH" == 'arm' || "$ARCH" == 'arm64' ]]; then

    # install homebrew/linuxbrew
    if ! [ -x "$(command -v brew)" ]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if [[ "$OSTYPE" != "darwin"* ]]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

      # lobber what's there, we won't use it with zsh
      echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" > "$HOME/.profile"
    fi  

  # Most packages will be installed in the 00 script, but we need the rest of the files in order to proceed
  if ! [[ -x "$(command -v chezmoi)" ]]; then
    brew install chezmoi
  fi

  # Check env after preliminaries -- TODO: More verification
  command -v zsh > /dev/null 2>&1 || MISSING_PACKAGES+=("zsh")
  command -v git > /dev/null 2>&1 || MISSING_PACKAGES+=("git")
  command -v curl > /dev/null 2>&1 || MISSING_PACKAGES+=("curl")
  command -v brew > /dev/null 2>&1 || MISSING_PACKAGES+=("brew")
  command -v chezmoi > /dev/null 2>&1 || MISSING_PACKAGES+=("chezmoi")

  if [ -n "${MISSING_PACKAGES}" ]; then
      warn "The following is missing on the host and needs "
      warn "to be installed and configured before running this script again"
      error "missing: ${MISSING_PACKAGES[@]}"
  fi

  # some repositories don't have age -- rather 

  if ! [[ -d "$HOME/.local/share/chezmoi" ]]; then
    # chezmoi init --apply --verbose --dry-run git@github.com:borland502/dotfiles.git
    chezmoi init https://github.com/borland502/dotfiles
    chezmoi diff
  fi

  info "changing shell now"
  sudo chsh -s /bin/zsh

  info "bootstrap complete."
  info ""
  warn ""
  warn "If you want to abort chezmoi download, hit ctrl+c within 10 seconds..."
  warn ""

  sleep 10

  chezmoi apply

else

    ## arm minimal install pending linuxbrew
    if [ -x "$(command -v apt)" ]; then
        sudo apt-get update
        # python3 golang p7zip vim fzf fd bat jq yq pyenv tldr age
    elif [[ -x "$(command -v yum)" ]]; then
        sudo yum update
    elif [ -x "$(command -v opkg)" ]; then
        sudo opkg update
    fi


  info "bootstrap complete on arm.  Guess we'll wait for linuxbrew to support it"
  exit 0

fi  
