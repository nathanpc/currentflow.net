#!/usr/bin/perl

package Utils::Posts;

use strict;
use warnings;
use autodie;

use File::Basename;

# Get the post filenames sorted by date.
sub get_filenames {
	my ($config) = @_;

	# Get file list and sort them.
	my @posts = glob($config->{folders}->{posts} . "/*.html");
	@posts = map { basename($_) } @posts;        # Get only basename from files.
	@posts = sort { lc($b) cmp lc($a) } @posts;  # Sort posts from newer to older.

	return @posts;
}

1;

__END__

=head1 NAME

Utils::Posts - A colletion of utility functions for handling posts.

=head1 SYNOPSIS

  # Get a default configuration.
  my $config = Config::Tiny->read('levissimo.conf');

  # Get post filenames.
  my @posts = Utils::Posts::get_filenames($config);

=head1 METHODS

=over 4

=item I<@posts> = C<Utils::Posts::get_filenames>(I<$config>)

Gets a list of the post filenames from the default posts directory specified in
the I<$config> (C<Config::Tiny>) configuration.

=back

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

