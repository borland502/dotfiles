#!/usr/bin/env bash

# Script can be used with linux, WSL (Windows), or MacOS with linuxbrew or homebrew.

PLATFORM=${OSTYPE:-'unknown'}

sysinstall() {

  echo "Preparing to install software on $PLATFORM"

  # Update any existing homebrew recipes
  brew update

  # Upgrade any already installed formulae
  brew upgrade

  echo "Adding custom taps"
  brew tap AdoptOpenJDK/openjdk

  echo "Installing all homebrew apps"

  programming_languages_homebrew=(openjdk node python3 golang typescript)

  for i in "${programming_languages_homebrew[@]}"; do
    brew install "$i"
  done

  build_tools_homebrew=(git subversion maven gradle npm)

  for i in "${build_tools_homebrew[@]}"; do
    brew install "$i"
  done

  cli_applications_homebrew=(nginx p7zip vim fzf fd bat jq yq mackup jenv diff-so-fancy prettyping)

  for i in "${cli_applications_homebrew[@]}"; do
    brew install "$i"
  done

  echo "Installing all non-freeware packages with brew cask"

  gui_app_cask=(Vivaldi google-chrome docker sourcetree visual-studio-code slack discord dropbox sublime-text intellij-idea onedrive adoptopenjdk8)
  # TODO New security permissions with virtualbox

  if [[ $PLATFORM == "darwin"* ]]; then
    echo "Installing Mac specific apps"
    # brew install mackup # Depends on dropbox or similar service
    gui_app_cask+=(iterm2 1password viscosity paw the-unarchiver macdown bartender)
    for i in "${gui_app_cask[@]}"; do
      brew cask install "$i"
    done

    echo "Adding custom taps"
    brew tap mas-cli/tap/mas

    echo "Installing all Mac Store apps"
    brew install mas

  elif [[ $PLATFORM == "linux"* ]]; then
    echo "Installing linux specific apps"

    # https://stackoverflow.com/questions/38859145/detect-ubuntu-on-windows-vs-native-ubuntu-from-bash-script
    if [[ $(grep -q Microsoft /proc/version) ]]; then
      echo "WSL"
    else
      echo "native Linux"
    fi
  fi

  echo "Install misc software that somehow isn't available in homebrew, cask, or the mac store"
}
