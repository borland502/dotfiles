#!/usr/bin/env bash

# Set up additional frameworks and any tweaks/hacks/cleanup after the main work is done

# Vundle
if ! [[ -d "$HOME/.vim/bundle" ]]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
fi

# update tldr's index, though it should be up to date 
if [[ -x "$(command -v tldr)" ]]; then
  tldr --update
fi
