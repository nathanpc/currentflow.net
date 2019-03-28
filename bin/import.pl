#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use Config::Tiny;
use Term::ANSIColor;

# Include the project module directory.
use FindBin;
use File::Spec;
use lib File::Spec->catdir($FindBin::Bin, '..', 'lib');

use Importer::Tumblr;
use Template::Engine;

# Print the usage text.
sub usage {
	print "Usage: $0 <service> <url>\n\n";
	print "    service    Which service to import from. Options: tumblr\n";
	print "    url        Full post URL.\n";
}

# Open the config file.
sub read_config {
	print colored('Reading the configuration file...', 'blue') . "\n";
	return Config::Tiny->read('config/levissimo.conf');
}

# Generate the post file.
sub generate_post {
	my (%params) = @_;

	# Start by creating the template.
	my $template = Template::Engine->new(
		config => $params{config},
		file => 'raw_post.html'
	);

	# Create a title slug for the filename.
	my $title_slug = $params{title};
	$title_slug =~ s/[^\w\d\-_]/_/g;  # Everything illegal becomes underscores.
	$title_slug =~ s/_+/_/g;          # Remove duplicate dashes.

	# Create filename and notify the user.
	my $outfile = $params{config}->{folders}->{posts} . $params{date} .
		"_$title_slug.html";
	print colored('Writing post file...', 'blue') . "\n";
	print "  $outfile ";

	# Open output file for writing.
	open(my $output, '>:encoding(UTF-8)', $outfile);
	print $output $template->run(
		'post.title' => $params{title},
		'post.author' => $params{author},
		'post.date' => $params{date},
		'post.body' => $params{body}
	);
	close($output);

	# Confirm writing to user.
	print colored('OK', 'green') . "\n";
}

# Parses the command-line arguments.
sub parse_args {
	# Wrong number of arguments passed.
	if (scalar(@ARGV) != 2) {
		usage();
		exit 1;
	}

	# Read the configuration file.
	my $config = read_config();

	# Get the parameters.
	my ($service, $url) = @ARGV;
	$service = lc $service;
	# Check which service to import from.
	if ($service eq 'tumblr') {
		# Import from Tumblr.
		print colored('Importing from Tumblr...', 'blue') . "\n";
		my $post = Importer::Tumblr->new();
		print colored('Fetching post from server...', 'blue') . "\n";
		print "  $url ";
		$post->fetch($url);
		print colored('OK', 'green') . "\n";
		print colored('Parsing post...', 'blue') . "\n";
		$post->parse();

		# Adds the image container for images in the post.
		my $body = $post->pretty_body;
		$body =~ s/<p><img/<p class="image-container"><img/g;

		# Generate the post file.
		generate_post(
			config => $config,
			title => $post->{title},
			author => $config->{blog}->{default_author},
			date => $post->{date},
			body => $body
		);
	} elsif ($service eq 'help') {
		usage();
		exit 0;
	} else {
		usage();
		exit 1;
	}
}

# Parse the command-line arguments.
parse_args();

__END__

=head1 NAME

import.pl - A simple command-line utility to import posts from other services.

=head1 SYNOPSIS

  $ ./bin/import.pl help
  $ ./bin/import.pl tumblr https://some.blog/post/1234567890/some-post

=head1 DESCRIPTION

This script will allow you to easily import posts from other services like into
the default format used by Levissimo.

This is not meant to be a migration tool, it will only grab a single post at a
time, but you can use it in conjunction with another script to automate things
and crawl a whole blog to be migrated.

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

