#!/bin/bash

### make_folders.sh
### Makes all of the required folders for the output of Levissimo.
###
### Author: Nathan Campos <nathanpc@dreamintech.net>

function ok {
	echo -e "\e[32m OK\e[0m"
}

echo -e "\e[34mCreating output folders...\e[0m"

outfolder=$(./bin/get_output_path.pl)
echo -n " $outfolder"
mkdir $outfolder
ok

echo -n "   page/"
mkdir $outfolder/page/
ok

echo -n "   post/"
mkdir $outfolder/post/
ok

