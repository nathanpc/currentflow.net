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
	my ($class, $config, $page_num, $page_count) = @_;
	my $self = {
		page_num => $page_num,
		_config => $config,
		_page => undef,
		_page_count => $page_count
	};

	# Generate the page template.
	my $template = Template::Engine->new(
		config => $config,
		file => 'index.html'
	);

	# Create a new base page according to the page number.
	if ($page_num == 0) {
		print "[LOG] Generating index page: index.html\n";
		$self->{_page} = Page::Base->new($config, $template, 'index.html');
	} elsif ($page_num > 0) {
		my $num = $page_num + 1;  # More human-friendly page representation.
		my $page_name = "page/$num.html";

		print "[LOG] Generating index page: $page_name\n";
		$self->{_page} = Page::Base->new($config, $template, $page_name);
	}

	bless $self, $class;
	return $self;
}

# Build the page and output the file.
sub build {
	my ($self, @filenames) = @_;

	# Work with the articles.
	my @articles;
	for my $file ($self->_filter_for_page(@filenames)) {
		my $article = Page::Object::Article->new(
			config => $self->{_config},
			file => $file);
		push @articles, $article;
	}

	# Render the page.
	$self->{_page}->render(
		"server.path" => $self->{_config}->{server}->{path},
		"blog.title" => $self->{_config}->{blog}->{title},
		"blog.subtitle" => $self->{_config}->{blog}->{subtitle},
		"page.articles" => _build_post_list(@articles),
		"page.pager" => $self->_generate_pager()
	);
}

# Create a new page, built it, and output all in one go.
sub render {
	my ($class, %params) = @_;

	# Create a page object.
	my $page = $class->new($params{config}, $params{page}, $params{page_count});

	# Build the page.
	$page->build(@{$params{articles}});

	return $page;
}

# Filters all the articles for the current page.
sub _filter_for_page {
	my ($self, @articles) = @_;
	my @filtered;

	# Define the limits of the page.
	my $start = $self->{page_num} * $self->{_config}->{blog}->{posts_per_page};
	my $end = $start + $self->{_config}->{blog}->{posts_per_page};

	# Check if the end post number is greater than the available posts.
	if ($end > scalar(@articles)) {
		$end = scalar(@articles);
	}

	# Filter only the articles for the current page.
	for (my $i = $start; $i < $end; $i++) {
		push @filtered, $articles[$i];
	}

	return @filtered;
}

# Builds the post list in the index page.
sub _build_post_list {
	my (@articles) = @_;
	my $output = "";

	# Loop through the articles and render them.
	for my $article (@articles) {
		$output .= $article->render();
	}

	return $output;
}

sub _generate_pager {
	my ($self) = @_;
	my $pager = Template::Engine->new(
		config => $self->{_config},
		file => 'pager.html'
	);

	# Generate the previous page link.
	my $prev = "";
	if ($self->{page_num} > 0) {
		# Remember that the filenames are human-friendly, so they start at 1,
		# while the page_num starts at 0, so the previous page is just the
		# current value of page_num.
		$prev = "<a href='" . $self->{_config}->{server}->{path} . "/page/" .
			$self->{page_num} . ".html'>&lt;</a>";
	}

	# Generate inner items.
	my $items = "";
	for (my $i = 0; $i < $self->{_page_count}; $i++) {
		if ($i == $self->{page_num}) {
			# Current page link.
			$items .= "<a href='" . $self->{_config}->{server}->{path} . "/page/" .
				($i + 1) . ".html' class='current'>" . ($i + 1) . "</a>\n";
		} else {
			$items .= "<a href='" . $self->{_config}->{server}->{path} . "/page/" .
				($i + 1) . ".html'>" . ($i + 1) . "</a>\n";
		}
	}

	# Generate next page link.
	my $next = "";
	if (($self->{page_num} + 1) < $self->{_page_count}) {
		# As explained before, page_num is start at 0, so we need to add 2 to
		# get the next human-friendly page.
		$next = "<a href='" . $self->{_config}->{server}->{path} . "/page/" .
			($self->{page_num} + 2) . ".html'>&gt;</a>";
	}

	return $pager->run(
		"pager.prev" => $prev,
		"pager.items" => $items,
		"pager.next" => $next
	);
}

1;

__END__

=head1 NAME

Page::Index - Abstract representation of the index page.

=head1 SYNOPSIS

  # Create a default configuration.
  my $config = Config::Tiny->read('levissimo.conf');

  # Create a list with article file names.
  my @articles = ('1.html', '2.html', ...);
  
  # This is the most common way to use this class.
  Page::Index->render(
    config => $config,
	page => 0,
	page_count => Utils::Index::page_count($config, @articles),
	articles => \@articles
  );

  # Create a list with article objects.
  my @obj_articles = (
    Page::Object::Article->new(file => '1.html', config => $config),
	Page::Object::Article->new(file => '2.html', config => $config),
	...
  );
  
  # The same as the above, but longer.
  my $page = Page::Index->new($config, 0,
    Utils::Index::page_count($config, @articles));
  $page->build(@obj_articles);

=head1 METHODS

=over 4

=item I<$page> = C<Page::Index>->C<new>(I<$config>, I<$page_num>, I<$page_count>)

Initializes a new index page object with a configuration set by I<$config>, a
page number set by I<$page_num>, and the number of pages as I<$page_count>.

Note that I<$config> should be a C<Config::Tiny> object and that I<$page_num>
starts at B<0>.

=item I<$page>->C<build>(I<@filenames>)

Builds the page by parsing the filenames given as a list and renders them on the
page according to the page number.

=item I<$page> = C<Page::Index>->C<render>(I<%params>)

Does everything you need to get from start to finish in a single line. All you
have to do is supply it with a C<Config::Tiny> as I<config>, a page number as
I<page>, a list reference of all the article file names as I<articles> in the
order that they should be placed in the page, and the maximum number of pages as
I<page_count>.

Note that you should pass all the articles available to this function and it
will decide which ones it will render according to the page number.

B<Remember:> Page numbers start at B<0>.

This function returns the object as if it was a constructor. It is actually just
a alias for calling C<new> and C<build>.

=back

=head1 PRIVATE METHODS

=over 4

=item I<@filtered> = I<$self>->C<_filter_for_page>(I<@articles>)

Gets a list of article filenames and returns a filtered list with only the
articles that should be on the current page.

=item I<$output> = C<_build_post_list>(I<@articles>)

Renders all the posts, passed as a list of C<Page::Object::Article>, as they
should be on the page.

=back

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

