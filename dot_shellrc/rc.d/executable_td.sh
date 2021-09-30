#!/usr/bin/env sh

TODO_DIR="$HOME/.todo"
TODO_TXT="$TODO_DIR/todo.txt"

td(){
    gsync -fg "$TODO_DIR" -d "todo"
    todo.sh "$@" || exit
    gupload -o -r "$GDRIVE_TODO_ROOT" "$TODO_TXT"
}