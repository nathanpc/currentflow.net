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
use Page::Object::Article;

# Read index page template.
my $fn_in = "index.html";
print "[LOG] Reading template from $fn_in\n";
my $template = Template::Engine->new(file => $fn_in);

# Create an article.
my $article = Page::Object::Article->new('2019-03-20_Power12_The_Mini6_Again_But_Better.html');

# Write the page to the output file.
my $fn_out = File::Spec->rel2abs("site/index.html");
print "[LOG] Opening output file: $fn_out\n";
open(my $out, '>:encoding(UTF-8)', $fn_out);
print $out $template->run(
	"blog.title" => "Levissimo Blog",
	"blog.subtitle" => "A blog about everything related to the project",
	"article.main" => $article->render()
);
close($out);
print "[LOG] Finished writing the index.html file\n";

