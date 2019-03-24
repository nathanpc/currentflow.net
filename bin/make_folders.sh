#!/bin/bash

### make_folders.sh
### Makes all of the required folders for the output of Levissimo.
###
### Author: Nathan Campos <nathanpc@dreamintech.net>

function blue {
	echo -e "\e[34m$1\e[0m"
}

function ok {
	echo -e "\e[32m OK\e[0m"
}

blue "Creating output folders..."

echo -n " site/"
mkdir site/
ok

echo -n "   page/"
mkdir site/page/
ok

echo -n "   post/"
mkdir site/post/
ok

