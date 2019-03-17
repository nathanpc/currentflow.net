# Makefile
# Helps manage everything in a automated manner.
#
# Author: Nathan Campos <nathan@innoveworkshop.com>

all: clean
	mkdir site/
	./bin/generate_site.pl
	cp -r static/* site/
	# TODO: Run script to generate the static files.

clean:
	-rm -r site/

test:
	prove -lvcf

critic:
	-perlcritic -4 bin/ lib/

