#!/usr/bin/perl

package Template::Engine;

use strict;
use warnings;
use autodie;

use File::Spec;
use File::Slurp;
use Term::ANSIColor;

# Constructor.
sub new {
	my ($class, %opts) = @_;
	my $self = {
		raw => $opts{raw},
		config => $opts{config},
		filename => $opts{file},
		filepath => undef
	};

	# Get absolute file path and content if a file was given as input.
	if (defined $opts{file}) {
		my $template_folder = 'template/';
		if (defined $self->{config}) {
			$template_folder = $self->{config}->{folders}->{templates};
		}

		$self->{filepath} = File::Spec->catdir(File::Spec->rel2abs(
				$template_folder), $opts{file});
		$self->{raw} = read_template($self->{filename});
	}

	bless $self, $class;
	return $self;
}

# Runs the engine over the text.
sub run {
	my ($self, %vars) = @_;
	my $output = $self->{raw};

	# Get template comment file matches in the form of: <!-- [[$file]] -->
	while ($output =~ /<!--\s?\[\[(?<fname>[\w\d\.\-\_\/]+)\]\]\s?-->/g) {
		# Open file and read the content.
		my $content = read_template($+{fname});

		# Substitute the file content into the template.
		substr($output, length($`), length($&), $content);
	}

	# Check for variables after the files have been substituted.
	while ($output =~ /<!--\s?\|(?<vname>[\w\d\.]+)\|\s?-->/g) {
		# Get variable value and substitute it.
		my $value = $vars{$+{vname}};

		if (defined $value) {
			substr($output, length($`), length($&), $value);
		} else {
			warn('[', colored('WARNING', 'yellow'), "] Couldn't find variable '",
				$+{vname}, "'. Ignoring...\n");
		}
	}

	return $output;
}

# Read the content of a template file.
sub read_template {
	my ($filename) = @_;

	my $abs_path = File::Spec->catdir(File::Spec->rel2abs('template'), $filename);
	return read_file($abs_path);
}

1;

__END__

=head1 NAME

Template::Engine - Super simple and HTML-friendly templating engine.

=head1 SYNOPSIS

  # Create a default configuration.
  my $config = Config::Tiny->read('levissimo.conf');

  # Optionally get the template from a file.
  my $raw_text = Template::Engine->read_template('test.html');
  
  # Create a new template instance.
  my $template = Template::Engine->new(config => $config, raw => $raw_text);
  $template = Template::Engine->new(config => $config, file => 'test.html');
  
  # Get generated text without passing any variables.
  my $final_text = $template->run();

  # Get generated text with some variables substituted.
  $final_text = $template->run(
  	some_var => 'Hello, World!',
	foo => 'bar'
  );

=head1 DESCRIPTION

TODO: Describe how to use the template language and how each method is defined.

=head1 METHODS

=over 4

=item I<$template> = C<Template::Engine>->C<new>(I<%opts>)

Initializes a new template object using the template text provided by
I<raw> or a file path relative to the I<template/> directory in the root of
project, or a directory provided by the I<config> object, provided via I<file>.
This templatecan be used to generate several different outputs depending on the
parameters passed to I<$template>->C<run>().

You can also provide a C<Config::Tiny> object with the default configuration as
I<config>.

=item I<$output> = I<$template>->C<run>(I<%vars>)

Run the engine over the file and get the finalized output text with the option
of substituting variables defined by I<%vars>.

=item I<$raw_text> = C<Template::Engine>->C<read_template>(I<$filename>)

Read the content of a template file residing in the I<template/> folder at the
root of the project firectory.

=back

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

