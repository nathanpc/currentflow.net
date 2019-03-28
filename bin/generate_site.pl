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

__END__

=head1 NAME

generate_site.pl - The main levissimo blog generator.

=head1 DESCRIPTION

The main executable to generate the Levissimo static pages. This executable must
be use in conjunction with others to work properly. Please take a look at the
C<Makefile> at the root of the project to get an idea of how this fits into the
whole system.

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

