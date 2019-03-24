# Makefile
# Helps manage everything in a automated manner.
#
# Author: Nathan Campos <nathan@innoveworkshop.com>

all: clean
	mkdir site/
	mkdir site/page/
	mkdir site/post/
	./bin/generate_site.pl
	cp site/index.html site/page/1.html
	cp -r static/* site/

clean:
	-rm -r site/

test:
	prove -lvcf

critic:
	-perlcritic -4 bin/ lib/

