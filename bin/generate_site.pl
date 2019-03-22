#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use Config::Tiny;

# Include the project module directory.
use FindBin;
use File::Spec;
use lib File::Spec->catdir($FindBin::Bin, '..', 'lib');

use Page::Index;

# Open the config file.
my $config = Config::Tiny->read('config/levissimo.conf');

# Generate pages.
Page::Index->render(
	config => $config,
	articles => [ '2019-03-20_Power12_The_Mini6_Again_But_Better.html' ]
);

