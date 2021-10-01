#!/usr/bin/env sh

TODO_DIR="$HOME/.todo"
TODO_TXT="$TODO_DIR/todo.txt"

td(){
    gdrive download --path "$TODO_DIR" --force "$GDRIVE_TODO_TXT"
    todo.sh "$@" || exit
    gdrive update --parent "$GDRIVE_TODO_ROOT" "$GDRIVE_TODO_TXT" "$TODO_TXT"
}