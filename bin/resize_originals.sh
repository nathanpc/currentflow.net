#!/bin/bash

### resize_originals.sh
### Resizes all of the original images under static/img/ to minimize their size.
### WARNING: This will override the original images.
###
### Author: Nathan Campos <nathanpc@dreamintech.net>

# Paths.
imagepath="static/img/"

# Configuration variables.
max_width=$(./bin/get_config.pl 'images/max_width')
retina=$(./bin/get_config.pl 'images/retina')

# Checks if the image is bigger than what is needed and shrinks it.
function optimize_width {
	local width=$(convert $1 -format '%w' info:)

	if [ $width -gt $max_width ]; then
		# Looks like we'll have to resize this one.
		mogrify "$1" -filter Triangle -define filter:support=2 -resize \
			$max_width -unsharp 0.25x0.25+8+0.065 -dither None -posterize 136 \
			-define jpeg:fancy-upsampling=off -interlace none "$1"
	fi
}

# Resizes all of the images in the folder.
# $1 - Folder with images in it.
function resize_images {
	for file in $1/*; do
		# Trick to get how deep we are in a folder.
		local deep=$(awk -F"/" '{print NF-1}' <<< "$file")

		# Found a image!
		if [[ -f $file ]]; then
			# Print "deepness" spaces.
			perl -E "print '  ' x ($deep - 1)"
			echo -n " $(basename $file) ("
			echo -ne "\e[33m$(du -k "$file" | cut -f1)k\e[0m -> "

			# Resize the image if needed.
			optimize_width "$file"

			# Signal that everything went OK.
			echo -e "\e[33m$(du -k "$file" | cut -f1)k\e[0m) \e[32mOK\e[0m"
		fi

		# Iterate over this new directory.
		if [[ -d $file ]]; then
			# Print "deepness" spaces.
			perl -E "print '  ' x ($deep - 1)"
			echo -e " \e[36m$(basename $file)/\e[0m"

			# Recursively iterate over the new directory.
			resize_images "$file"
		fi
	done
}

# Double the maximum width if retina is enabled.
if [[ $retina == '1' ]]; then
	max_width=$(bc <<< "$max_width * 2")
fi

# Start optimizing the image.
echo -e "\e[34mResizing original images... \e[0m"
echo -e "\e[36m static/\e[0m"
echo -e "\e[36m   img/\e[0m"
resize_images "static/img/"
echo -e "\e[34mDone\e[0m"

