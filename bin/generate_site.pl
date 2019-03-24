#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use Config::Tiny;
use Term::ANSIColor;

# Include the project module directory.
use FindBin;
use File::Spec;
use lib File::Spec->catdir($FindBin::Bin, '..', 'lib');

use Utils::Posts;
use Utils::Index;

# Open the config file.
print colored('Reading the configuration file...', 'blue') . "\n";
my $config = Config::Tiny->read('config/levissimo.conf');

# Get posts from deafult directory.
print colored('Gathering posts...', 'blue') . "\n";
my @posts = Utils::Posts::get_filenames($config);

# Generate index and post pages.
print colored('Generating pages...', 'blue') . "\n";
Utils::Index::create_pages($config, @posts);
Utils::Posts::create_pages($config, @posts);

