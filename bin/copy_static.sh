#!/bin/bash

### copy_static.sh
### Copies all of the static files from static/ to site/ preserving the folder
### structure.
###
### Author: Nathan Campos <nathanpc@dreamintech.net>

infolder="static"
outfolder=$(./bin/get_config.pl 'folders/output' | sed -e 's/\/$//')

echo -e "\e[34mCopying static files...\e[0m"

# The easy way:
#cp -r static/* site/

# The fun way:

# Go through a directory and copy the files in it.
# $1 - Directory to copy files from.
function copy_files {
	for file in $1/*; do
		# Trick to get how deep we are in a folder.
		deep=$(awk -F"/" '{print NF-1}' <<< "$file")

		# Copy if they are files.
		if [[ -f $file ]]; then
			# Print "deepness" spaces.
			perl -E "print '  ' x ($deep - 1)"
			echo -n " $(basename $file)"
			cp $file "$outfolder/${file//$infolder\//}"
			echo -e "\e[32m OK\e[0m"
		fi

		# Go through the directory.
		if [[ -d $file ]]; then
			# Print "deepness" spaces.
			perl -E "print '  ' x ($deep - 1)"
			echo -e " \e[36m$(basename $file)/\e[0m"

			# Make directory.
			mkdir "$outfolder/${file//$infolder\//}/"

			# Recursively iterate over the new directory.
			copy_files "$file"
		fi
	done
}

# Start copying.
copy_files "$infolder"

