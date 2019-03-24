# Makefile
# Helps manage everything in a automated manner.
#
# Author: Nathan Campos <nathan@innoveworkshop.com>

all: clean
	mkdir site/
	mkdir site/page/
	./bin/generate_site.pl
	cp -r static/* site/

clean:
	-rm -r site/

test:
	prove -lvcf

critic:
	-perlcritic -4 bin/ lib/

