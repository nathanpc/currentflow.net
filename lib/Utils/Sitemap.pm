#!/usr/bin/perl

package Utils::Sitemap;

use strict;
use warnings;
use autodie;

use File::Find::Rule;

use Page::Sitemap;

# Generate the sitemap.
sub generate {
	my ($config) = @_;
	my @files = _get_files($config);

	# Actually generate the sitemap.
	my $sitemap = Page::Sitemap->render(
		config => $config,
		pages => \@files
	);
}

# Get a list of front-facing files.
sub _get_files {
	my ($config) = @_;
	my @files = File::Find::Rule->file()
	                            ->name('*.html')
								->in($config->{folders}->{output});
	my @pages = ( '' );  # Added the main page already (slash added later).

	# Remove the output folder name from the files.
	for my $file (@files) {
		$file =~ s/^\Q$config->{folders}->{output}\E//;
		push @pages, $file;
	}

	return @pages;
}

1;

__END__

