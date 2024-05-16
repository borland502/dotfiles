#!/usr/bin/env zsh

if ! [[ -f "${HOME}/.env" ]]; then
    touch "${HOME}/.env"
fi
