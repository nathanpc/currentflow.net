#!/bin/bash

### optimize_image.sh
### Optimizes images by shrinking them to the correct size, applying compression
### and other things.
###
### Arguments:
###    $1 = Image file to be overwritten.
###
### Author: Nathan Campos <nathanpc@dreamintech.net>

# Paths.
imagepath=$1
fext=${imagepath##*.}

# Configuration variables.
max_width=$(./bin/get_config.pl 'images/max_width')
retina=$(./bin/get_config.pl 'images/retina')

# Optimizes JPEG images.
function optimize_jpeg {
	convert "$imagepath" -sampling-factor 4:2:0 -strip -quality 85 -interlace \
		JPEG -colorspace sRGB "$imagepath";
}

function optimize_png {
	convert "$imagepath" -define png:compression-filter=5 -define \
		png:compression-level=9 -define png:compression-strategy=1 -define \
		png:exclude-chunk=all -colorspace sRGB -strip "$imagepath"
}

# Checks if the image is bigger than what is needed and shrinks it.
function optimize_width {
	local width=$(convert $imagepath -format '%w' info:)

	if [ $width -gt $max_width ]; then
		# Looks like we'll have to resize this one.
		mogrify "$imagepath" -filter Triangle -define filter:support=2 \
			-thumbnail $max_width -unsharp 0.25x0.25+8+0.065 -dither None \
			-posterize 136 -define jpeg:fancy-upsampling=off -interlace none \
			"$imagepath"

		# Show the progress we've made.
		echo -n "$(du -k "$imagepath" | cut -f1)k -> "
	fi
}

# Double the maximum width if retina is enabled.
if [[ $retina == '1' ]]; then
	max_width=$(bc <<< "$max_width * 2")
fi

# Start optimizing the image.
echo -ne "\e[34mOptimizing image... \e[0m"
echo -n "$(du -k "$imagepath" | cut -f1)k -> "

# Resize the image if needed.
optimize_width

# Actually optimize them.
if [[ ($fext == 'jpg') || ($fext == 'jpeg') ]]; then
	# JPEG
	optimize_jpeg
elif [[ $fext == 'png' ]]; then
	# PNG
	optimize_png
fi

# Show the last optimized size.
echo -n "$(du -k "$imagepath" | cut -f1)k "

# Signal that everything went OK.
echo -e "\e[32mOK\e[0m"

