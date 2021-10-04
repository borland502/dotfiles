#!/usr/bin/env sh

td(){
    gdrive sync download "$GDRIVE_TODO_ROOT" "$HOME/.todo"
    todo.sh "$@" || exit
    gdrive sync upload "$HOME/.todo" "$GDRIVE_TODO_ROOT"
}