#!/bin/bash

### copy_static.sh
### Copies all of the static files from static/ to site/ preserving the folder
### structure.
###
### Author: Nathan Campos <nathanpc@dreamintech.net>

echo -e "\e[34mCopying static files...\e[0m"
cp -r static/* site/

