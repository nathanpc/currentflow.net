#!/bin/bash

### copy_index.sh
### Creates the main website index.html by copying the first page.
###
### Author: Nathan Campos <nathanpc@dreamintech.net>

outfolder=$(./bin/get_config.pl 'folders/output')
echo -e "\e[34mGenerating the main page...\e[0m"
echo -n "  index.html "
cp "$outfolder/page/1/index.html" "$outfolder/index.html"
echo -e "\e[32mOK\e[0m"

