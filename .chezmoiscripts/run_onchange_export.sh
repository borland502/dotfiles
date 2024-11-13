#!/usr/bin/env bash

# export chezmoi data to jinja compatible yaml in the ansible directory
mkdir -p "${ANSIBLE_HOME}/inventory/group_vars"
chezmoi data --format=yaml >"${ANSIBLE_HOME}/inventory/group_vars/chezmoi_data.yaml"
chmod 600 "${ANSIBLE_HOME}/inventory/group_vars/chezmoi_data.yaml"

if [[ $(command -v sysupdate) ]]; then
  sysupdate
fi
