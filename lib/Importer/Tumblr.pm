#!/usr/bin/perl

package Importer::Tumblr;

use strict;
use warnings;
use autodie;

use POSIX;
use Carp;
use LWP::Simple;
use HTML::TreeBuilder;
use Date::Parse;
use URI::Escape;

# TODO: Turn this module into a CPAN distribution for parsing Tumblr posts.

# Constructor.
sub new {
	my ($class) = @_;
	my $self = {
		url => undef,
		title => undef,
		date => undef,
		body => undef,
		tags => [],
		_html => undef
	};

	# Bless the reference.
	bless $self, $class;
	return $self;
}

# Fetches the page.
sub fetch {
	my ($self, $url) = @_;

	# Get the page content.
	my $page = get($url);
	if (defined $page) {
		$self->{_html} = $page;
	} else {
		croak "Failed to fetch the post at '$url'";
	}
}

sub parse {
	my ($self) = @_;

	# Just a little sanity check.
	if (not defined $self->{_html}) {
		croak "No page content to parse";
	}

	# Create the HTML tree object and parse the page.
	my $tree = HTML::TreeBuilder->new();
	$tree->parse($self->{_html});

	# Get the main post container from Tumblr.
	my $container = $tree->look_down(
		_tag => 'div',
		class => 'post text'
	);

	# Get the post title.
	$self->{title} = $container->look_down('class', 'title')->as_trimmed_text;
	$self->{title} =~ s/^\s+|\s+$//g;  # Trim whitespace.

	# Get the post body and fix the redirect URLs.
	$self->{body} = $container->look_down('class', 'caption')->as_HTML;
	$self->{body} =~ s/^<div class="caption">//;
	$self->{body} =~ s/<\/div>$//;
	$self->_fix_redirects();

	# Get the post metadata container.
	my $metadata = $container->look_down('class', 'metadata');

	# Get the post date.
	my $dt = $metadata->look_down('class', 'date')->as_trimmed_text;
	$self->{date} = strftime("%Y-%m-%d", gmtime(str2time($dt)));

	# Get the post tags.
	for my $tag ($metadata->look_down('class', 'tags')->look_down(_tag => 'a')) {
		# Clean the tag.
		$tag = $tag->as_text;
		$tag =~ s/^#//;

		# Push tag into tags array.
		push @{$self->{tags}}, $tag;
	}
}

# Makes the post body more human-readable.
sub pretty_body {
	my ($self) = @_;
	my $body = $self->{body};

	# Let's insert closing <p> tags, since Tumblr apparently only opens them.
	$body =~ s/<p>/<\/p><p>/g;
	$body =~ s/^<\/p>//;
	$body .= '</p>';

	# Add some empty lines to separate each paragraph.
	$body =~ s/<\/p><p>/<\/p>\n\n<p>/g;

	return $body;
}

# Replaces all of those nasty redirect URLs.
sub _fix_redirects {
	my ($self) = @_;
	
	# I can feel you judging me for using regular expressions to parse HTML, but
	# this is such a simple task that there's no way to justify using a parser,
	# just grab the URLs and replace them.

	# Go through the URLs and replace them accordingly.
	while ($self->{body} =~ /<a href="(?<url>https?:\/\/t.umblr.com\/redirect\?[^<>"\s]+)" target="_blank">/g) {
		my $raw = $+{url};
		my $url = undef;

		# Get the encoded URL.
		if ($raw =~ /(\?|&amp;)z=(?<encoded_url>[^&;]+)/) {
			$url = uri_unescape($+{encoded_url});
		} else {
			confess "Found a redirect URL, but couldn't replace it. Investigate...";
		}

		# Replace the nasty URLs with the fresh new ones.
		$self->{body} =~ s/\Q$raw\E/$url/g;
	}
}

1;

__END__

=head1 NAME

Importer::Tumblr - Fetches and parses Tumblr posts for importing into Levissimo.

=head1 SYNOPSIS

  # Create the importer object.
  my $post = Importer::Tumblr->new();
  $post->fetch('https://example.com/post/123/test-post');
  $post->parse();

  # Get the parameters out of the post.
  my $title = $post->{title};
  my $author = $post->{author};
  my $body = $post->{body};
  $body = $post->pretty_body;  # Human-readable body.

=head1 METHODS

=over 4

=item I<$post> = C<Importer::Tumblr>->C<new>()

Creates a new post object to be populated.

=item I<$post>->C<fetch>(I<$url>)

Fetches the post from the web and stores the page for parsing later.

=item I<$post>->C<parse>()

Parses the whole post and stores the post parameters in the object to be used by
the user. See I<PARAMETERS> for a list of the parameters available to you.

=item I<$body> = I<$post>->C<pretty_body>

Returns a more human-readable version of the post body with more whitespace.

=back

=head1 PARAMETERS

These are the post parameters that you have access via I<$post>->{I<parameter>}.

=over 4

=item I<title>

Simply the post title.

=item I<date>

When the article was posted to the blog as C<YYYY-MM-DD> string.

=item I<body>

The body of the article itself.

=item I<tags>

An array of the tags used to describe the post.

=back

=head1 PRIVATE METHODS

=over 4

=item I<$self>->C<_fix_redirects>()

Finds all of those nasty Tumblr redirection URLs in the post body and replaces
them with the original URL.

=back

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

