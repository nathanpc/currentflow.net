#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use Config::Tiny;
use File::Basename;

# Include the project module directory.
use FindBin;
use File::Spec;
use lib File::Spec->catdir($FindBin::Bin, '..', 'lib');

use Page::Index;

# Open the config file.
my $config = Config::Tiny->read('config/levissimo.conf');

# Get posts from directory.
my @posts = glob($config->{folders}->{posts} . "/*.html");
@posts = map { basename($_) } @posts;        # Get only basename from files.
@posts = sort { lc($b) cmp lc($a) } @posts;  # Sort posts from newer to older.


# Generate pages.
Page::Index->render(
	config => $config,
	articles => \@posts
);

