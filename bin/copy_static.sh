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

# Checks if the image extension matches a array of known image extensions.
# $1 - Filename to be checked.
function is_image {
	local imgexts=('jpg' 'jpeg' 'png')
	local fext=${1##*.}
	
	if [[ " ${imgexts[*]} " == *" $fext "* ]]; then
		return 0
	else
		return 1
	fi
}

# Go through a directory and copy the files in it.
# $1 - Directory to copy files from.
function copy_files {
	for file in $1/*; do
		# Trick to get how deep we are in a folder.
		local deep=$(awk -F"/" '{print NF-1}' <<< "$file")

		# Copy if they are files.
		if [[ -f $file ]]; then
			# Get output file location.
			local outfile="$outfolder/${file//$infolder\//}"

			# Print "deepness" spaces.
			perl -E "print '  ' x ($deep - 1)"

			# Actually copy the file.
			echo -n " $(basename $file)"
			cp $file $outfile
			echo -e "\e[32m OK \e[0m"

			# Check if it is an optimizable image.
			if is_image $outfile; then
				# Print "deepness" spaces again.
				perl -E "print '  ' x ($deep + 1)"

				# Optimize image.
				./bin/optimize_image.sh "$outfile"
			fi
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

