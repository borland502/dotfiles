#!/usr/bin/env zsh

# Where user-specific configurations should be written (analogous to /etc).
mkdir -p "${HOME}/.config"

# Where user-specific non-essential (cached) data should be written (analogous to /var/cache).
mkdir -p "${HOME}/.cache"

# Where user-specific data files should be written (analogous to /usr/share).
mkdir -p "${HOME}/.local/share"

# Non-official, but my OCD compels me to give it a name
mkdir -p "${HOME}/.local/bin"

# Where user-specific state files should be written (analogous to /var/lib).
mkdir -p "${HOME}/.local/state"
