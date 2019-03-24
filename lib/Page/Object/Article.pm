#!/usr/bin/perl

package Page::Object::Article;

use strict;
use warnings;
use autodie;

use Carp;
use File::Spec;
use File::Slurp;
use Term::ANSIColor;

use Template::Engine;

# Constructor.
sub new {
	my ($class, %params) = @_;
	my $self = {
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

	bless $self, $class;
	return $self;
}

# Renders the finalized article.
sub render {
	my ($self) = @_;
	my $output = "";

	# If the article file hasn't been parsed yet, parse it.
	if (not defined $self->{tags}) {
		$self->_parse_file();
	}

	# Generate the output with the article template.
	$output = $self->{_template}->run(
		"article.title" => $self->{title},
		"article.author" => $self->{author},
		"article.date" => $self->{date},
		"article.body" => $self->{body}
	);

	return $output;
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
	while ($article =~ /^<\s?meta\s+name=["'](?<name>[\w\d\.\-:_]+)["']\s+content=["'](?<content>[^"']+)["']\s?>\s?$/gm) {
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

=head1 METHODS

=over 4

=item I<$article> = C<Page::Object::Article>->C<new>(I<%params>)

Initializes a new article obejct with a base file described in I<file> relative
to the default posts folder as defined in the C<Config::Tiny> object passed as
I<config>.

=item I<$output> = I<$article>->C<render>()

Runs the parser through the post file and generates a output according to the
default article template.

=back

=head1 PRIVATE

=over 4

=item I<$self>->C<_parse_file>()

Parses the whole article looking for tags and populates the object for rendering.

=item I<%tags> = C<_parse_meta_tags>($article)

Parses all the C<meta> tags inside the article file content, provided as
I<$article>, and returns them in the form of a hash.

=item C<_check_required_params>(I<$tags>)

Checks if all the required tags are present in the hash reference I<$tags>.

Required parameters: I<title>, I<author>, I<created>.

=back

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

