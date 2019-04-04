#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use Config::Tiny;

my $config = Config::Tiny->read('config/levissimo.conf');

# If no arguments were supplied then print the usage.
if (scalar(@ARGV) != 1) {
	print "Usage: $0 <variable_path>\n";
	exit 1;
}

my $output = undef;
my @vars = split '/', $ARGV[0];

if (scalar(@vars) == 1) {
	# Top-level variable.
	$output = $config->{$vars[0]};
} elsif (scalar(@vars) == 2) {
	# Variable under a group.
	$output = $config->{$vars[0]}->{$vars[1]};
} else {
	# Oops.
	print "Too many levels of groups.\n";
	exit 1;
}

# Check if the configuration variable exists.
if (defined $output) {
	print $output;
	exit 0;
} else {
	print "Variable doesn't exist.\n";
	exit 1;
}

__END__

=head1 NAME

get_config.pl - A shell helper to get a configuration variable from the default
file.

=head1 SYNOPSIS

  # Makefile
  FOLDER = $(shell ./bin/get_config.pl 'folders/posts')
  
  # Shell script.
  folder=$(./bin/get_config.pl 'folders/posts')

  # Shell removing trailling slash from path.
  $ ./bin/get_config.pl 'folders/output' | sed -e 's/\/$//'

=head1 DESCRIPTION

This script just parses the configuration file, grabs the desired variable
described as if it was a file path and returns it.

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

