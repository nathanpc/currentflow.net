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

my $fn_in = "index.html";
print "[LOG] Reading template from $fn_in\n";
my $template = Template::Engine->new(file => $fn_in);

my $fn_out = File::Spec->rel2abs("site/index.html");
print "[LOG] Opening output file: $fn_out\n";
open(my $out, '>:encoding(UTF-8)', $fn_out);
print $out $template->run(
	"blog.title" => "Levissimo Blog",
	"blog.subtitle" => "A blog about everything related to the project"
);
close($out);
print "[INDEX] Closed the finished file\n";

