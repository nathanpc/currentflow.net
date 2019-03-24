#!/usr/bin/perl

package Page::Post;

use strict;
use warnings;
use autodie;

use Page::Base;
use Template::Engine;
use Page::Object::Article;

# Constructor.
sub new {
	my ($class, $config, $file) = @_;
	my $self = {
		article => Page::Object::Article->new(config => $config, file => $file),
		_config => $config,
		_page => undef
	};

	# Generate the page template.
	my $template = Template::Engine->new(
		config => $config,
		file => 'page.html'
	);

	# Create post filename.
	my $fn = 'post/' . $self->{article}->url_slug . '.html';

	# Create base page object.
	print "[LOG] Generating post page: $fn\n";
	$self->{_page} = Page::Base->new($config, $template, $fn);

	bless $self, $class;
	return $self;
}

# Build the page and output the file.
sub build {
	my ($self) = @_;

	# Render the page.
	$self->{_page}->render(
		"server.path" => $self->{_config}->{server}->{path},
		"blog.title" => $self->{_config}->{blog}->{title},
		"blog.subtitle" => $self->{_config}->{blog}->{subtitle},
		"page.articles" => $self->{article}->render(),
		"page.pager" => ''
	);
}

# Create a new page, built it, and output all in one go.
sub render {
	my ($class, %params) = @_;

	# Create a page object.
	my $page = $class->new($params{config}, $params{file});

	# Build the page.
	$page->build();

	return $page;
}

1;

__END__

=head1 NAME

Page::Post - Abstract representation of a post page.

=head1 SYNOPSIS

  # Create a default configuration.
  my $config = Config::Tiny->read('levissimo.conf');
  
  # This is the most common way to use this class.
  Page::Index->render(
    config => $config,
	file => 'posts/article.html'
  );

  # The same as the above, but longer.
  my $page = Page::Index->new($config, 'posts/article.html');
  $page->build();

=head1 METHODS

=over 4

=item I<$page> = C<Page::Index>->C<new>(I<$config>, I<$file>)

Initializes a new post page object with a configuration set by I<$config> and a
post file I<$file>.

Note that I<$config> should be a C<Config::Tiny> object.

=item I<$page>->C<build>()

Builds the page and writes it to the output file.

=item I<$page> = C<Page::Index>->C<render>(I<%params>)

Does everything you need to get from start to finish in a single line. All you
have to do is supply it with a C<Config::Tiny> as I<config> and a post file as
I<file>.

This function returns the object as if it was a constructor. It is actually just
a alias for calling C<new> and C<build>.

=back

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

