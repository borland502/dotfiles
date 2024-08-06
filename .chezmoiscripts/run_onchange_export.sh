#!/usr/bin/env bash

# export chezmoi data to jinja compatible yaml in the ansible directory
mkdir -p "${ANSIBLE_HOME}/inventory"
chezmoi data --format=yaml > "${ANSIBLE_HOME}/inventory/group_vars/chezmoi_data.yaml"
