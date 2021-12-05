#!/usr/bin/env zsh

function tag_branch() {
	chg=$1
	tag=$2
	branch=$3
	app=$4

	cd $BITBUCKET_DIRECTORY/$app

	git stash > /dev/null

	# Make sure we are all up to date
	git fetch origin > /dev/null

	# Freshly check out the branch in question to ensure no cruft is present
	git checkout -b "tmp-tag-branch-${branch}" "remotes/origin/${branch}" > /dev/null

	# Tag
	git tag -a -m"${chg} - TAG - Creating tag of branch '${branch}' for release ${tag}" "${tag}"

	# Clean up
	git checkout main > /dev/null

	# get latest of main while we are at it -- avoids so many problems later
	git pull

	git branch -d "tmp-tag-branch-${branch}" > /dev/null

	# Push
	git push origin "refs/tags/${tag}"

	echo "If something went wrong, you have 10s to hit CTRL-C to abort the delete"
	sleep 10

    # Delete branch from the safety of main
	git push origin --delete ${branch}
	
	cd $BITBUCKET_DIRECTORY
}

# tag_branch CHG0116376 FY22Q1X_ASSIST_2.4.0.0_DME release/ASSIST_2.4.0.0_DME assist
# tag_branch CHG0116376 FY22Q1X_ASSIST_2.4.0.0_DME release/ASSIST_2.4.0.0_DME assist2-services
# tag_branch CHG0116376 FY22Q1X_ASSIST_2.4.0.0_DME release/ASSIST_2.4.0.0_DME assist2-web
# tag_branch CHG0116376 FY22Q1X_ASSIST_2.4.0.0_DME release/ASSIST_2.4.0.0_DME birt-app
# tag_branch CHG0116376 FY22Q1X_ASSIST_2.4.0.0_DME release/ASSIST_2.4.0.0_DME birt-reports
# tag_branch CHG0116376 FY22Q1X_ASSIST_2.4.0.0_DME release/ASSIST_2.4.0.0_DME cprm