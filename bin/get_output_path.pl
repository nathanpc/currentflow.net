#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use Config::Tiny;

my $config = Config::Tiny->read('config/levissimo.conf');
my $outpath = $config->{folders}->{output};

# If there are any arguments, then remove the last / in the path.
if (scalar(@ARGV) == 1) {
	$outpath =~ s/\/$//;
}

print $outpath;
exit 0;

__END__

=head1 NAME

get_output_path.pl - A super simple script to get the output path to be used in
shell scripts and Makefiles.

=head1 SYNOPSIS

  # Makefile
  OUTPATH = $(shell ./bin/get_output_path.pl)
  
  # Shell script.
  outpath=$(./bin/get_output_path.pl)
  
  # Calling in a shell and omitting the trailling slash.
  $ ./bin/get_output_path.pl noslash

=head1 DESCRIPTION

This script is dead simple. It just parses the configuration file, grabs the
output path and returns it. Nothing fancy, just glue logic for other things.

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

