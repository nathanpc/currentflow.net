# Makefile
# Helps manage everything in a automated manner.
#
# Author: Nathan Campos <nathan@innoveworkshop.com>

OUTFOLDER = $(shell ./bin/get_output_path.pl)

all: clean
	@./bin/make_folders.sh
	@./bin/generate_site.pl
	@cp $(OUTFOLDER)/index.html $(OUTFOLDER)/page/1.html
	@./bin/copy_static.sh
	@./bin/finished.sh

clean:
	@-rm -r $(OUTFOLDER)

test:
	prove -lvcf

critic:
	-perlcritic -4 bin/ lib/

