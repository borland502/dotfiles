#!/usr/bin/env bash

function a2inc {
	#Tests
	if [[ ! -x $(command -v rsync) ]]; then
		echo 'Error: rsync is not available.' >&2
		exit 1
	fi

	# Default to no pattern
	PATTERN=${1:-''}

	# If directory is not provided, set to the temp dir
	LOG_DIR=${2:-'/tmp'}

	#Prefix log with date prefix
	LOG_FILE="$LOG_DIR/$(date +"%Y-%m-%d")-server.log"

	# Use rsync with compression to download, then only get updates to the log for that day
	rsync -Phz -e ssh "$VLAB_A2_USER@$VLAB_APP_HOST:$VLAB_A2_LOG_DIR/server.log" "$LOG_FILE"

	if [[ ! -f "$LOG_FILE" ]]; then
		echo "No log downloaded"
		exit 2
	fi

	if [[ ! -x $(command -v lnav) ]]; then
		# Not everyone appreciates overkill
		# case insensitive search for the incident id
		less -i -p"$PATTERN" "$LOG_FILE"
	else
		# use lnav if available (insensitive search by default)
		lnav -c"/$PATTERN" "$LOG_FILE"
	fi
}


