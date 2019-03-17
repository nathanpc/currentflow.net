#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use File::Slurp;

# Include the project module directory.
use FindBin;
use File::Spec;
use lib File::Spec->catdir($FindBin::Bin, '..', 'lib');

use Template::Engine;

my $fn_in = File::Spec->rel2abs("template/index.html");
my $fn_out = File::Spec->rel2abs("site/index.html");

print "[INDEX] Reading template: $fn_in\n";
my $template_text = read_file($fn_in);
my $template = Template::Engine->new($template_text);

print "[INDEX] Opening file to be written: $fn_out\n";
open(my $out, '>:encoding(UTF-8)', $fn_out);
print $out $template->run();
close($out);
print "[INDEX] Closed the finished file\n";

