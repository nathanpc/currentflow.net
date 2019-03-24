# Makefile
# Helps manage everything in a automated manner.
#
# Author: Nathan Campos <nathan@innoveworkshop.com>

all: clean
	@./bin/make_folders.sh
	@./bin/generate_site.pl
	@cp site/index.html site/page/1.html
	@./bin/copy_static.sh
	@./bin/finished.sh

clean:
	@-rm -r site/

test:
	prove -lvcf

critic:
	-perlcritic -4 bin/ lib/

