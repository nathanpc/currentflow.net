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
	my ($class, $file) = @_;
	my $self = {
		title => undef,
		author => undef,
		date => undef,
		body => undef,
		_file => $file,
		_template => Template::Engine->new(file => 'article.html')
	};

	bless $self, $class;
	return $self;
}

# Renders the finalized article.
sub render {
	my ($self) = @_;
	my $output = "";

	# If the article file hasn't been parsed yet, parse it.
	if (not defined $self->{title}) {
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
	my $filepath = File::Spec->catdir(File::Spec->rel2abs('posts'),
		$self->{_file});
	my $article = read_file($filepath);

	# Parse tags and check if all the required parameters are present.
	my %tags = _parse_meta_tags($article);
	_check_required_params(\%tags);

	# Populate class parameters.
	$self->{title} = $tags{title};
	$self->{author} = $tags{author};
	$self->{date} = $tags{created};

	# TODO: Get post body.
	$self->{body} = "<p>Hello, world!</p>\n";
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
	my ($param) = @_;
	my @requirements = ('title', 'author', 'created');
	my $fail = 0;

	# Iterate over the required parameters.
	for my $req_param (@requirements) {
		if (not defined $param->{$req_param}) {
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

