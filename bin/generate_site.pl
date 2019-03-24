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

use Utils::Posts;
use Utils::Index;

# Open the config file.
my $config = Config::Tiny->read('config/levissimo.conf');

# Get posts from deafult directory.
my @posts = Utils::Posts::get_filenames($config);

# Generate index pages.
Utils::Index::create_pages($config, @posts);

# Create a post pages.
Utils::Posts::create_pages($config, @posts);

