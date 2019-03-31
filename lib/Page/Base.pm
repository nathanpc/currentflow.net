#!/usr/bin/perl

package Page::Base;

use strict;
use warnings;
use autodie;

use File::Spec;
use File::Slurp;
use Term::ANSIColor;
use HTML::Packer;

use Template::Engine;

# Constructor.
sub new {
	my ($class, $config, $template, $outputfile) = @_;
	my $self = {
		output => "",
		_config => $config,
		_template => $template,
		_outputfile => File::Spec->catdir(File::Spec->rel2abs(
				$config->{folders}->{output}), $outputfile)
	};

	bless $self, $class;
	return $self;
}

# Builds the page and outputs the file.
sub render {
	my ($self, %vars) = @_;

	# Get output and minify it.
	my $content = $self->{_template}->run(%vars);
	HTML::Packer::minify(
		\$content,
		remove_comments => 1,
		do_javascript => 'best',
		do_stylesheet => 'minify',
		#html5 => 1
	);

	# Open the output file and write the template output to it.
	open(my $output, '>:encoding(UTF-8)', $self->{_outputfile});
	print $output $content;
	close($output);
}

1;

__END__

=head1 NAME

Page::Base - Abstract base representation of a page.

=head1 SYNOPSIS

  # Create the necessary objects for a page.
  my $config = Config::Tiny->read('levissimo.conf');
  my $template = Template::Engine->new(file => 'test.html');
  
  # Create a new base page.
  my $page = Page::Base->new($config, $template, 'page.html');

  # Build the page and output the file.
  $page->render(
    "blog.title" => 'Blog Title',
	"blog.subtitle" => 'Something like a subtitle.'
  );

=head1 DESCRIPTION

This class is designed to be super simple and should be used only as a base for
other page classes and will implement all the common, underlying, basics of
every page in this project.

=head1 METHODS

=over 4

=item I<$page> = C<Page::Base>->C<new>(I<$config>, I<$template>, I<$outputfile>)

Initializes a new page object with a configuration set by a C<Config::Tiny>
object in I<$config>, a C<Template::Engine> as I<$template>, and a output file
name with a path relative to I<site/> in the project root.

=item I<$page>->C<render>(I<%vars>)

Build the page passing I<%vars> as the arguments to I<$template>->C<run>() and
writes the output to the specified file location.

=back

=head1 AUTHOR

Nathan Campos <nathanpc@dreamintech.net>

=head1 COPYRIGHT

Copyright (c) 2019 Nathan Campos.

=cut

