# Makefile
# Helps manage everything in a automated manner.
#
# Author: Nathan Campos <nathan@innoveworkshop.com>

test:
	prove -lvcf

critic:
	-perlcritic -4 bin/ lib/

