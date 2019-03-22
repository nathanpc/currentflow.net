#!/usr/bin/perl

package Page::Index;

use strict;
use warnings;
use autodie;

use Page::Base;
use Template::Engine;
use Page::Object::Article;

# Constructor.
sub new {
	my ($class, $config) = @_;
	my $self = {
		_config => $config,
		_page => undef
	};

	# Generate the page template and create a base page.
	my $template = Template::Engine->new(
		config => $config,
		file => 'index.html'
	);
	$self->{_page} = Page::Base->new($config, $template, 'index.html');

	bless $self, $class;
	return $self;
}

# Build the page and output the file.
sub build {
	my ($self, @articles) = @_;

	# TODO: Get the latest articles and put them in the page.

	# Render the page.
	$self->{_page}->render(
		"blog.title" => $self->{_config}->{blog}->{title},
		"blog.subtitle" => $self->{_config}->{blog}->{title},
		"article.main" => $articles[0]->render()
	);
}

# Create a new page, built it, and output all in one go.
sub render {
	my ($self, %params) = @_;

	# Create a page object.
	my $page = $self->new($params{config});

	# Work with the articles.
	my @articles;
	for my $article (@{$params{articles}}) {
		push @articles, Page::Object::Article->new(config => $params{config},
			file => $article);
	}

	# Build the page.
	$page->build(@articles);

	return $page;
}

1;

__END__

=head1 NAME

Page::Index - Abstract representation of the index page.

=head1 SYNOPSIS

  # Create a list with article file names.
  my @articles = ('1.html', '2.html', ...);
  
  # This is the most common way to use this class.
  Page::Index->render(config => $config, articles => \@articles);

  # Create a list with article objects.
  my @obj_articles = (
    Page::Object::Article->new(file => '1.html', config => $config),
	Page::Object::Article->new(file => '2.html', config => $config),
	...
  );
  
  # The same as the above, but longer.
  my $page = Page::Index->new($config);
  $page->build(@obj_articles);

=head1 METHODS

=over 4

=item I<$page> = C<Page::Index>->C<new>(I<$config>)

Initializes a new index page object with a configuration set by I<$config>. Note
that I<$config> should be a C<Config::Tiny> object.

=item I<$page>->C<build>(I<@articles>)

Builds the page appending the C<Page::Object::Article> list to the page and
outputs the finalized file.

=item I<$page> = C<Page::Index>->C<render>(I<%params>)

Does everything you need to get from start to finish in a single line. All you
have to do is supply it with a C<Config::Tiny> as I<config> and a list reference
of article file names as I<articles> in the order that they should be placed in
the page.

This function returns the object as if it was a constructor.

=back

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

