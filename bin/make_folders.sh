#!/bin/bash

### make_folders.sh
### Makes all of the required folders for the output of Levissimo.
###
### Author: Nathan Campos <nathanpc@dreamintech.net>

function ok {
	echo -e "\e[32m OK\e[0m"
}

echo -e "\e[34mCreating output folders...\e[0m"

echo -n " site/"
mkdir site/
ok

echo -n "   page/"
mkdir site/page/
ok

echo -n "   post/"
mkdir site/post/
ok

