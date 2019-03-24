#!/usr/bin/perl

use strict;
use warnings;
use autodie;

package Utils::Index;

use POSIX;

use Page::Index;

sub create_pages {
	my ($config, @posts) = @_;
	my $total = ceil(scalar(@posts) / $config->{blog}->{posts_per_page});

	# Loop though the pages.
	for (my $page = 0; $page < $total; $page++) {
		Page::Index->render(
			config => $config,
			articles => \@posts,
			page => $page
		);
	}
}

1;

__END__

=head1 NAME

Utils::Index - A colletion of utility functions for handling the index page.

=head1 SYNOPSIS

  # Get a default configuration.
  my $config = Config::Tiny->read('levissimo.conf');
  
  # Get posts from deafult directory.
  my @posts = Utils::Posts::get_filenames($config);
  
  # Create index pages.
  Utils::Index::create_pages($config, @posts);

=head1 METHODS

=over 4

=item C<Utils::Index::create_pages>(I<$config>, I<@posts>)

Generates all of the index pages from a list of post filenames.

=back

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

