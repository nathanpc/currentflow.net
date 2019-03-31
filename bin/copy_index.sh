#!/bin/bash

### copy_index.sh
### Creates the main website index.html by copying the first page.
###
### Author: Nathan Campos <nathanpc@dreamintech.net>

outfolder=$(./bin/get_output_path.pl)
echo -n " index.html "
cp "$outfolder/page/1/index.html" "$outfolder/index.html"
echo -e "\e[32mOK\e[0m"

