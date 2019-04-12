#!/bin/bash

### deploy.sh
### A simple deployment script that should work great for the typical workflow
### of resizing and optimizing the images, generating the website, commiting the
### changes to the repo, and pushing them. Should be perfect for deploying to
### GitHub Pages.
###
### Author: Nathan Campos <nathanpc@dreamintech.net>

function usage {
	echo "Usage: $0 <commit_message>"
	echo
	echo "    commit_message    Commit message that should be used."
	exit 1
}

# The main script itself.
if [[ $# -gt 0 ]]; then
	# Deploy!
	make resize
	make
	git commit -am "$1"
	git push
else
	# Looks like the person doesn't know how to use this script.
	usage
fi

