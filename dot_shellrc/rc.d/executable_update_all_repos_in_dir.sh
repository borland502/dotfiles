#!/usr/bin/env sh

# Tests
# TODO Extract all tests
if [[ ! -x $(command -v git) ]]; then
  echo 'Error: git is not available.' >&2
  exit 1
fi

function update_repos {
  local_project_dir=${1:-"$HOME/Development/bitbucket"}
  starting_dir=$(pwd)
  release_branch=${2:-"$RELEASE_BRANCH"}
  prev_branch=${3:-"$PREV_BRANCH"}

  cd "$local_project_dir" || exit

  if [[ -d $local_project_dir ]]; then

    # obtain meta data necessary to detect remote branches reliably
    # shellcheck disable=SC2091
    $(git fetch)

    # iterate through each directory, non git directories will fail safely
    for dir in "$local_project_dir"/*/; do
      echo "Processing git directory $dir"
      cd "$dir" || exit

      # look for a .git folder, if it doesn't exist, skip this directory
      if [[ ! -d '.git' ]]; then
        echo "Skipping directory $dir since there is no repository"
        continue
      fi

      git update-index -q --refresh
      CHANGED=$(git diff-index --name-only HEAD --)

      # stash without any options will just auto commit any modifications to a "wip labeled stash"
      if [[ ! -z $CHANGED ]]; then
        echo "Local has changed, stashing for safety"
        git stash

        # if stash does something bad, then we really don't want to continue
        # shellcheck disable=SC2181
        if [[ $? != 0 ]]; then
          echo "Could not stash work, quitting"
          exit 2
        fi
      fi

      # Check if release branch exists, if it doesn't quit
      # shellcheck disable=SC2143
      # shellcheck disable=SC2236
      if [[ ! -z $(git branch -r | grep "$release_branch") ]]; then
        # change to feature branch; command does no harm if we're already there
        git checkout "$release_branch"
      else

        # shellcheck disable=SC2143
        # shellcheck disable=SC2236
        if [[ ! -z $(git branch -r | grep "$prev_branch") ]]; then
          echo "Warn:  Release branch $release_branch does not exist, please create one officially.  Defaulting to $prev_branch"
          git checkout "$prev_branch"
        elif [[ ! -z $(git branch -r | grep "origin/master") ]]; then
          echo "Warn:  Release branch $release_branch does not exist, please create one officially.  Defaulting to master"
          git checkout main
        elif [[ ! -z $(git branch -r | grep "origin/main") ]]; then
          echo "Warn:  Release branch $release_branch does not exist, please create one officially.  Defaulting to master"
          git checkout main
        else
          echo "Error:  You don't even have master or main?  I give up"
          exit 4
        fi
      fi

      # With stash doing its job above, pull with confidence
      git pull

      # verify that local is current with the release branch remote
      # shellcheck disable=SC2143
      # shellcheck disable=SC2236
      if [[ ! -z $(git fetch --dry-run) ]]; then
        echo "Error:  git pull failed"
        exit 3
      fi

    done

    cd "$local_project_dir" || exit

  else
    echo "Local project directory $local_project_dir does not exist"
  fi

  cd "$starting_dir" || exit
}

export -f update_repos
