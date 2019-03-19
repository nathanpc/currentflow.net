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
	my ($class, $raw_text) = @_;
	my $self = {
		raw => $raw_text
	};

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
		my $floc = File::Spec->catdir(File::Spec->rel2abs('template'), $+{fname});
		my $content = read_file($floc);

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

1;

__END__

=head1 NAME

Template::Engine - Super simple and HTML-friendly templating engine.

=head1 SYNOPSIS

  # Create a new template instance.
  my $template = Template::Engine->new($raw_text);
  
  # Get generated text.
  my $final_text = $template->run();
  $final_text = $template->run(
  	some_var => 'Hello, World!',
	foo => 'bar'
  );

=head1 USAGE

TODO: Describe how to use the template language and how each method is defined.

=head1 METHODS

=over 4

=item I<$template> = C<Template::Engine>->C<new>(I<$raw_text>)

Initializes a new template object using the template text provided by
I<$raw_text> which can be used to generate several different outputs depending
on the parameters passed to I<$template>->C<run>().

=item I<$output> = I<$template>->C<run>(I<%vars>)

Run the engine over the file and get the finalized output text with the option
of substituting variables defined by I<%vars>.

=back

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

