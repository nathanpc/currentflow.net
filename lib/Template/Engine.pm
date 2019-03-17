#!/usr/bin/perl

package Template::Engine;

use strict;
use warnings;
use autodie;

use File::Spec;
use File::Slurp;

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
	my ($self) = @_;
	my $output = $self->{raw};

	# Get template comment file matches in the form of: <!-- [[$file]] -->
	while ($output =~ /<!--\s?\[\[(.+)\]\]\s?-->/g) {
		# Open file and read the contents.
		my $fname = $1;
		my $floc = File::Spec->catdir(File::Spec->rel2abs('template'), $fname);
		my $contents = read_file($floc);

		# Substitute the file contents into the template.
		substr($output, length($`), length($&), $contents);
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

=head1 METHODS

=over 4

=item I<$template> = C<Template::Engine>->C<new>(I<$raw_text>)

Initializes a new template object using the template text provided by
I<$raw_text> which can be used to generate several different outputs depending
on the parameters passed to I<$template>->C<run>().

=item I<$output> = I<$template>->C<run>()

Run the engine over the file and get the finalized output text.

=back

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

