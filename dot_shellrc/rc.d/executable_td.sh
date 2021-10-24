#!/usr/bin/env sh

tds() {
  gdrive sync download --keep-remote "$GDRIVE_TODO_ROOT" "$HOME/.todo" || exit
  todo.sh "$@" || exit
  gdrive sync upload --keep-local "$HOME/.todo" "$GDRIVE_TODO_ROOT"
}

td() {
  gdrive sync download --keep-remote "$GDRIVE_TODO_ROOT" "$HOME/.todo" || exit
  todo.sh "$@" || exit
}
