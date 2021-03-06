#!/usr/bin/perl

package Page::Object::Article;

use strict;
use warnings;
use autodie;

use Carp;
use File::Spec;
use File::Slurp;
use Term::ANSIColor;
use Time::Piece;

use Template::Engine;

# Constructor.
sub new {
	my ($class, %params) = @_;
	my $self = {
		url => undef,
		title => undef,
		author => undef,
		date => undef,
		body => undef,
		tags => undef,
		_file => File::Spec->catdir(File::Spec->rel2abs(
				$params{config}->{folders}->{posts}), $params{file}),
		_config => $params{config},
		_template => Template::Engine->new(
			file => 'article.html',
			config => $params{config})
	};

	# Bless the reference.
	bless $self, $class;

	# Parse the article.
	$self->_parse_file();
	$self->{url} = $self->{_config}->{server}->{path} . $self->location;

	return $self;
}

# Renders the finalized article.
sub render {
	my ($self) = @_;
	my $output = "";

	# Generate the output with the article template.
	$output = $self->{_template}->run(
		"article.url" => $self->{url},
		"article.title" => $self->{title},
		"article.author" => $self->{author},
		"article.date" => $self->_get_date_str(),
		"article.body" => $self->{body}
	);

	return $output;
}

# Get a URL slug for the post.
sub url_slug {
	my ($self, $param) = @_;
	my $slug;

	# Deecide which parameter to use to build the slug.
	if (not defined $param) {
		# Use both date and title.
		$slug = join(' ', $self->{date}, $self->{title});
	} elsif ($param eq 'date') {
		# Use date.
		$slug = $self->{date};
	} elsif ($param eq 'title') {
		# Use title.
		$slug = $self->{title};
	} else {
		# This does not compute.
		croak 'Parameter passed for URL slugging is not recognized';
	}

	# Create the slug.
	$slug =~ s/[^\w\d\-_]/\-/g;  # Substitute everything illegal for dashes.
	$slug =~ s/\-+/\-/g;         # Remove duplicate dashes.

	return $slug;
}

# Gets the post location.
sub location {
	my ($self) = @_;
	return 'post/' . $self->url_slug('date') . '/' . $self->url_slug('title') .
		'/';
}

# Parses an article file and populates the class.
sub _parse_file {
	my ($self) = @_;
	my $article = read_file($self->{_file});

	# Parse tags and check if all the required parameters are present.
	my %tags = _parse_meta_tags($article);
	_check_required_params(\%tags);
	$self->{tags} = \%tags;

	# Populate class parameters.
	$self->{title} = $tags{title};
	$self->{author} = $tags{author};
	$self->{date} = $tags{created};
	$self->{body} = $article;
}

# Parses the meta tags in the article.
sub _parse_meta_tags {
	my ($article) = @_;
	my %tags;

	# Yes, I know parsing HTML with regular expressions is bad, but I don't
	# think we need to parse the whole thing with a proper HTML parser just to
	# get a couple of <meta> tags.
	while ($article =~ /^<\s?meta\s+name="(?<name>[\w\d\.\-:_']+)"\s+content="(?<content>[^"]+)"\s?>\s?$/gm) {
		$tags{$+{name}} = $+{content};
	}

	return %tags;
}

# Check if all the required parameters are present.
sub _check_required_params {
	my ($tags) = @_;
	my @requirements = ('title', 'author', 'created');
	my $fail = 0;

	# Iterate over the required parameters.
	for my $req_param (@requirements) {
		if (not defined $tags->{$req_param}) {
			$fail = 1;
			carp '[', colored('WARNING', 'yellow'), "] Required parameter $req_param not present";
		}
	}

	# Some parameters were not found.
	if ($fail) {
		confess '[', colored('ERROR', 'red'), "] Required parameters were not present";
	}
}

# Get a human-friendly date string.
sub _get_date_str {
	my ($self) = @_;
	my $dt = Time::Piece->strptime($self->{date}, "%Y-%m-%d");

	# Override Time::Piece names with english so that it is locale agnostic.
	my @days = qw(Sun Mon Tue Wed Thu Fri Sat);
	my @months = qw(January February March April May June July August September
		October November December);
	Time::Piece::day_list(@days);
	Time::Piece::mon_list(@months);

	return join(' ', $dt->wdayname, $dt->mday, $dt->monname, $dt->year);
}

1;

__END__

=head1 NAME

Page::Object::Article - A simple object representing a article.

=head1 SYNOPSIS

  # Get a default configuration.
  my $config = Config::Tiny->read('levissimo.conf');

  # Create article object.
  my $article = Page::Object::Article->new(
    config => $config,
    file => 'some_post.html'
  );

  # Get the article output.
  my $output = $article->render();
  
  # Get the location of the article (omitting the index.html part).
  my $loc = $article->location;
  
  # Get a URL slug for the article.
  my $slug = $article->url_slug;
  $slug = $article->url_slug('date');
  $slug = $article->url_slug('title');

=head1 METHODS

=over 4

=item I<$article> = C<Page::Object::Article>->C<new>(I<%params>)

Initializes a new article obejct with a base file described in I<file> relative
to the default posts folder as defined in the C<Config::Tiny> object passed as
I<config>.

=item I<$output> = I<$article>->C<render>()

Runs the parser through the post file and generates a output according to the
default article template.

=item I<$locaiton> = I<$article>->C<location>

Returns only the article location, omitting the server location and
I</index.html>.

B<Example>: If the final URL will look like
L<http://example.com/post/2019-12-23/Some-Interesting-Post/index.html>, this
function will return just I<post/2019-12-23/Some-Interesting-Post/>.

=item I<$slug> = I<$article>->C<url_slug>(I<[$param]>)

Returns a URL slug representation of the article.

I<$param> is optional and can either be I<date> or I<title>. If omitted, this
function will return a slug with both date and title in it.

=back

=head1 PRIVATE METHODS

=over 4

=item I<$self>->C<_parse_file>()

Parses the whole article looking for tags and populates the object for rendering.

=item I<%tags> = C<_parse_meta_tags>($article)

Parses all the C<meta> tags inside the article file content, provided as
I<$article>, and returns them in the form of a hash.

=item C<_check_required_params>(I<$tags>)

Checks if all the required tags are present in the hash reference I<$tags>.

Required parameters: I<title>, I<author>, I<created>.

=item I<$date_str> = I<$self>->C<_get_date_str>()

Returns a more human-friendly version of the article date.

=back

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

