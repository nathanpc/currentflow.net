#!/usr/bin/perl

package Page::Sitemap;

use strict;
use warnings;
use autodie;

use Term::ANSIColor;

use Page::Base;
use Template::Engine;

# Constructor.
sub new {
	my ($class, $config, $pages) = @_;
	my $self = {
		pages => $pages,
		_config => $config,
		_page => undef
	};

	# Generate the main file template.
	my $template = Template::Engine->new(
		config => $config,
		file => 'sitemap.xml'
	);

	# Create base page object.
	$self->{_page} = Page::Base->new($config, $template, 'sitemap.xml');

	bless $self, $class;
	return $self;
}

# Build the page and output the file.
sub build {
	my ($self) = @_;
	my $urlset = '';

	for my $page (@{$self->{pages}}) {
		# Some general variables.
		my $priority = '0.5';
		my $changefreq = 'monthly';

		# Create template object.
		my $template = Template::Engine->new(
			config => $self->{_config},
			file => 'sitemap_item.xml'
		);

		# Make pretty URLs when possible.
		$page = $self->_make_pretty($page);
		my $url = 'https://' . $self->{_config}->{server}->{host} .
			$self->{_config}->{server}->{path} . $page;

		# Notify user of the page generation.
		print colored("  $url ", 'cyan');

		# Detect which kind of page we are dealing with.
		if ($url =~ m/\/post\//) {
			# Post
			$priority = '0.8';
			$changefreq = 'yearly';
		} elsif ($url =~ m/\/page\/[0-9]+\//) {
			# Indexes
			$priority = '0.5';
			$changefreq = 'monthly';
		} elsif ($url =~ m/\Q\E/) {
			# Main
			$priority = '0.7';
			$changefreq = 'weekly';
		}

		# Append the item to the urlset.
		$urlset .= $template->run(
			url => $url,
			priority => $priority,
			changefreq => $changefreq
		);
	
		# Show that everything went fine.
		print colored('OK', 'green') . "\n";
	}

	# Render the page.
	$self->{_page}->render(
		"urls" => $urlset
	);
}

# Create a new page, built it, and output all in one go.
sub render {
	my ($class, %params) = @_;

	# Create a page object.
	my $page = $class->new($params{config}, $params{pages});

	# Build the page.
	$page->build();

	return $page;
}

# Make pretty URLs.
sub _make_pretty {
	my ($self, $url) = @_;
	$url =~ s/\/index\.html$/\//;

	return $url;
}

1;

__END__

=head1 NAME

Page::Sitemap - Abstract representation of a sitemap file.

=head1 SYNOPSIS

  # Create a default configuration.
  my $config = Config::Tiny->read('levissimo.conf');
  
  # Create a list of pages to map.
  my @pages = (
    'index.html',
    'page/1/index.html',
    'post/1234-12-34/Hello-World/index.html'
  );
  
  # This is the most common way to use this class.
  Page::Sitemap->render(
    config => $config,
	pages => \@pages
  );
  
  # The same as the above, but longer.
  my $page = Page::Sitemap->new($config, \@pages);
  $page->build();

=head1 METHODS

=over 4

=item I<$page> = C<Page::Index>->C<new>(I<$config>, I<\@pages>)

Initializes a new sitemap object with a configuration set by I<$config> and a
list of pages as I<\@pages>.

Note that I<$config> should be a C<Config::Tiny> object.

=item I<$page>->C<build>()

Builds the page and writes it to the output file.

=item I<$page> = C<Page::Sitemap>->C<render>(I<%params>)

Does everything you need to get from start to finish in a single line. All you
have to do is supply it with a C<Config::Tiny> as I<config> and a post file as
I<file>.

This function returns the object as if it was a constructor. It is actually just
a alias for calling C<new> and C<build>.

=back

=head1 PRIVATE METHODS

=over 4

=item I<$self>->C<_make_pretty>(I<$url>)

Returns a pretty URL when applicable for a given I<$url>.

=back

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

