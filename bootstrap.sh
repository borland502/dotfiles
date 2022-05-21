#!/usr/bin/env bash
set -e

# Script outline and structure borrowed from https://raw.githubusercontent.com/home-assistant/supervised-installer/master/installer.sh

function info { echo -e "[info] $*"; }
function warn { echo -e "[warn] $*"; }
function error {
  echo -e "[error] $*"
  exit 1
}

#TODO Extract these functions into helper scripts
###############################################################################
# Prompts from Slay: https://github.com/minamarkham/formation/blob/master/twirl
###############################################################################
ask_for_sudo() {

  # Ask for the administrator password upfront.

  sudo -v &>/dev/null

  # Update existing `sudo` time stamp
  # until this script has finished.
  #
  # https://gist.github.com/cowboy/3118588

  # Keep-alive: update existing `sudo` time stamp until script has finished.  This does not work with homebrew's few priviliged installs
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &

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
else
  error "This script assumes the user environment variables exist.  This branch can be erased if sudo inherits user envs"
fi

ARCH="$(uname -m)"
case $ARCH in
x86_64 | amd64)
  ARCH='amd64'
  ;;
aarch64)
  ARCH='arm64'
  ;;
i?86 | x86)
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

export PATH=$HOME/bin:$PATH

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

cd "$HOME"

IS_WSL=false
AGE_VERSION=$(wget -qO- "https://api.github.com/repos/FiloSottile/age/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

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

  ## Linuxbrew preqs & flatpak (aka our linux casks)
  if [ -x "$(command -v apt)" ]; then
    sudo apt-get update
    sudo apt-get -y install build-essential procps curl file git gnupg2 zsh vim

    # linuxbrew isn't supported on arm yet -- so provide a mininmum install using traditional package managers
    if [[ "$ARCH" == 'arm' || "$ARCH" == 'arm64' ]]; then
      # install brew equivalents at the lower layer for arm
      sudo apt -y install python3 golang p7zip-full fzf fd-find bat jq tldr exa ripgrep lsof age

      wget https://sh.rustup.rs -O "rustup.sh"
      chmod +x "$HOME/rustup.sh"
      "$HOME/rustup.sh" -y

      # install via rust on arm
      cargo install starship --locked

    fi

  elif [[ -x "$(command -v dnf)" ]]; then
    sudo dnf update
    sudo dnf -y group install 'Development Tools'
    sudo dnf -y group install 'Domain Membership'
    sudo dnf -y group install 'C Development Tools and Libraries'
    sudo dnf -y install vim curl wget gnupg2 libxcrypt-compat zsh vim
  elif [[ -x "$(command -v yum)" ]]; then
    sudo yum update
    sudo yum -y groupinstall 'Development Tools'
    sudo yum -y install procps-ng curl file git gnupg2 zsh freeipa-client vim
    sudo yum -y install libxcrypt-compat
  elif [ -x "$(command -v opkg)" ]; then
    sudo opkg update
    sudo opkg install curl file git git-http ca-certificates ldd zsh ruby gnupg2
  fi

  # Older versions of ubuntu and debian don't have age in the repos -- for now, just do it the hard way
  # if ! [[ -f "$HOME/bin/age" ]]; then
  #   wget "https://github.com/FiloSottile/age/releases/latest/download/age-${AGE_VERSION}-linux-amd64.tar.gz" -O "age.tar.gz"

  #   tar xf "age.tar.gz"
  #   sudo mv age/age /usr/local/bin
  #   sudo mv age/age-keygen /usr/local/bin
  #   rm "age.tar.gz"
  #   rm -rf "$HOME/age"
  # fi

elif [[ "$OSTYPE" == "darwin"* ]]; then
  if ! [[ -x "$(command -v age)" ]]; then
    brew install age
  fi

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

info "Downloading helper scripts"
info "Installing has"
wget https://raw.githubusercontent.com/kdabir/has/master/has -O "has"
mv has "$HOME/bin"
chmod +x "$HOME/bin/has"

# shellcheck disable=SC2034
export HAS_ALLOW_UNSAFE=y # switch allows has to query the version of commands it does not recognize

if ! [[ -d "$HOME/.sdkman" ]]; then
  info "Downloading SDKMan"
  curl -s "https://get.sdkman.io?rcupdate=false" | bash
fi

info "WSL? $IS_WSL"

# we are going all in on the XDG specifications
if ! [[ -d "/etc/xdg" ]]; then
  sudo mkdir /etc/xdg
fi

if ! [[ "$ARCH" == 'arm' || "$ARCH" == 'arm64' ]]; then

  # install homebrew/linuxbrew
  if ! has brew; then
    /bin/bash -c "NONINTERACTIVE=1 $(wget -qO- https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [[ "$OSTYPE" != "darwin"* ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    # lobber what's there, we won't use it with zsh
    echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >"$HOME/.profile"
  fi

  # Most packages will be installed in the 00 script, but we need the rest of the files in order to proceed
  if ! [[ -x "$(command -v chezmoi)" ]]; then
    brew install chezmoi
  fi

  if ! has gsed gdircolors; then
    brew install gsed
    brew install coreutils
  fi

fi

# Most packages will be installed in the 00 script, but we need the rest of the files in order to proceed
if ! [[ -x "$(command -v chezmoi)" ]]; then
  sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply borland502
fi


if ! [[ -d "$HOME/.local/share/chezmoi" ]]; then
  chezmoi init https://github.com/borland502/dotfiles
  chezmoi diff
fi

info "bootstrap complete."
info ""
warn ""
warn "If you want to abort chezmoi download, hit ctrl+c within 10 seconds..."
warn ""

sleep 10

chezmoi --use-builtin-age false apply

if [[ -z ${ZINIT_HOME+x} ]] && ! [[ -d ${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git ]]; then
  # shellcheck disable=SC1091
  if [[ -f "$HOME/.zprofile" ]]; then
    source "$HOME/.zprofile"
  fi

  # manual installation since we will get a chicken/egg cycle with .zshrc
  ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

elif [[ -z ${ZINIT_HOME+x} ]]; then
  warn "zinit exists, but is not initialized properly"
fi

info "changing shell now"
sudo chsh -s /bin/zsh

# Trigger final builds
source ~/.zshrc