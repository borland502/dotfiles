#!/usr/bin/env zsh

function clone_by_project {

	# expect credentials in the form 'username', default to $USER with prompt for pw
	credentials=${1:-$USER}
	# default to aas
	project=${2:-$PROJECT}
	local_project_dir=${3:-"$HOME/Development/bitbucket"}

	rest_api_base='https://bitbucket.assist2.cloud/rest/api/1.0'
	limit=1000
	git_base="$BITBUCKET_SSH"

	#Tests

	#test for jq, otherwise someone is free to experience the pain of sed with JSON
	if [[ ! -x $(command -v jq) ]]; then
		echo 'Error: jq is not available.' >&2
		echo 'https://github.com/stedolan/jq'
		exit 1
	fi

	if [[ ! -x $(command -v curl) ]]; then
		echo 'Error: curl is not available.' >&2
		echo 'https://curl.haxx.se'
		exit 1
	fi

	# if local directory doesn't exist, then create it
	if [[ ! -d "$local_project_dir" ]]; then
		$(mkdir -p "$local_project_dir")
	fi

	#TODO: test for null (no content returned in rest call)
	curl_ret=$(curl "$rest_api_base/projects/$project/repos?limit=$limit" -u $credentials)

	#TODO test for valid content, display errors if present

	project_repos=$(echo ${curl_ret} | jq -r '.values | .[] | .links | .clone | .[] | .href | select(contains("ssh"))')

	cd ${local_project_dir}
	echo "Cloning in $(pwd)"

	for repo in $project_repos; do
		git clone $repo
	done

}
