#!/bin/sh

# exit immediately if password-manager-binary is already in $PATH
type password-manager-binary >/dev/null 2>&1 && exit

case "$(uname -s)" in
Darwin)
    # commands to install password-manager-binary on Darwin
    if [[ $(command -v brew) ]]; then
	if ! [[ $(command -v keepassxc-cli) ]]; then
	   brew install keepassxc-cli
	fi
    fi
    ;;
Linux)
    # commands to install password-manager-binary on Linux
    if [[ $(command -v apt) ]]; then
	sudo apt install keepassxc
    fi
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac
