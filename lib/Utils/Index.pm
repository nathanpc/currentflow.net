#!/usr/bin/perl

package Utils::Index;

use strict;
use warnings;
use autodie;

use POSIX;

use Page::Index;

# Gets the number of pages to be created.
sub page_count {
	my ($config, @posts) = @_;
	return ceil(scalar(@posts) / $config->{blog}->{posts_per_page});
}

# Creates all the index pages.
sub create_pages {
	my ($config, @posts) = @_;
	my $total = page_count($config, @posts);

	# Loop though the pages.
	for (my $page = 0; $page < $total; $page++) {
		Page::Index->render(
			config => $config,
			articles => \@posts,
			page => $page,
			page_count => $total
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

  # Get the number of pages to be created.
  my $page_count = Utils::Index::page_count($config, @posts);
  
  # Create index pages.
  Utils::Index::create_pages($config, @posts);

=head1 METHODS

=over 4

=item C<Utils::Index::create_pages>(I<$config>, I<@posts>)

Generates all of the index pages from a list of post filenames.

=item I<$page_count> = C<Utils::Index::page_count>(I<$config>, I<@posts>)

Returns the number of pages that are going to be generated.

=back

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

