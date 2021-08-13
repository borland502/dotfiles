#!/usr/bin/env bash

# Script can be used with linux, WSL (Windows), or MacOS with linuxbrew or homebrew.

# Update any existing homebrew recipes
brew update

echo "Preparing to install software on $OSTYPE"

echo "Adding custom taps"
brew tap AdoptOpenJDK/openjdk

echo "Installing all homebrew apps"

#TODO Install languages using virtual env managers if possible
programming_languages_homebrew=(openjdk node python3 golang typescript)

for i in ${programming_languages_homebrew[@]}; do
  brew install $i
done

build_tools_homebrew=(git maven gradle npm)

for i in ${build_frameworks_homebrew[@]}; do
  brew install $i
done

# TODO: Extract brew targets that require super user permissions and place them in bootstrap
cli_applications_homebrew=(nginx p7zip vim fzf fd bat jq yq mackup jenv diff-so-fancy prettyping shfmt autopep8 clang-format gpg2 exa jenv pyenv nvm tldr)

for i in ${cli_applications_homebrew[@]}; do
  brew install $i
done

echo "Installing misc plugins"
brew install pyenv-virtualenv
brew install pyenv-ccache

  # TODO: Extract brew targets that require super user permissions and place them in bootstrap
  cli_applications_homebrew=(nginx p7zip vim fzf fd bat jq yq mackup jenv diff-so-fancy prettyping shfmt autopep8 clang-format gpg2 exa jenv pyenv nvm tldr ncdu htop)

  gui_app_cask=(Vivaldi google-chrome docker visual-studio-code slack discord dropbox intellij-idea adoptopenjdk8 1password-cli)
  gui_app_cask+=(iterm2 1password viscosity paw the-unarchiver macdown bartender)
  for i in ${gui_app_cask[@]}; do
    brew install $i
  done

elif [[ $OSTYPE == "linux-gnu"* ]]; then
  echo "Installing linux specific apps"

  if [[ $PLATFORM == "darwin"* ]]; then
    echo "Installing all non-freeware packages with brew cask"

    gui_app_cask=(Vivaldi google-chrome docker visual-studio-code slack discord dropbox intellij-idea adoptopenjdk8 1password-cli)
    gui_app_cask+=(iterm2 1password viscosity paw the-unarchiver macdown)
    for i in ${gui_app_cask[@]}; do
      brew install $i
    done

  elif [[ $OSTYPE == "linux-gnu"* ]]; then
    echo "Installing linux specific apps"

    # https://stackoverflow.com/questions/38859145/detect-ubuntu-on-windows-vs-native-ubuntu-from-bash-script
    if [[ $(grep -q Microsoft /proc/version) ]]; then
      echo "WSL"
    else
      echo "native Linux"
    fi
  fi
fi
