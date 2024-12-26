#!/usr/bin/env zsh

# export chezmoi data to jinja compatible yaml in the ansible directory
mkdir -p "${ANSIBLE_HOME}/inventory/group_vars"
chezmoi data --format=yaml >"${ANSIBLE_HOME}/inventory/group_vars/chezmoi_data.yaml"
chmod 600 "${ANSIBLE_HOME}/inventory/group_vars/chezmoi_data.yaml"

chmod 600 "${XDG_CONFIG_HOME}/age/key.txt"

_prev="$(pwd)"
cd "${XDG_DATA_HOME}/automation/home-ops" || (echo "Could not change to ${XDG_DATA_HOME}/automation/home-ops" && exit 2)
if [[ $(command -v task) && "$(pwd)" == "${XDG_DATA_HOME}/automation/home-ops" ]]; then
  task install
  task sync
fi
cd "${_prev}" || (echo "Could not change to ${_prev}" && exit 2)

# shellcheck disable=SC1090
source ~/.zshrc
