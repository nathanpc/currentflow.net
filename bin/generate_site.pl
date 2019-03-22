#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use Config::Tiny;

# Include the project module directory.
use FindBin;
use File::Spec;
use lib File::Spec->catdir($FindBin::Bin, '..', 'lib');

use Page::Index;

# Open the config file.
my $config = Config::Tiny->read('config/levissimo.conf');

# Generate pages.
Page::Index->render(
	config => $config,
	articles => [ '2019-03-20_Power12_The_Mini6_Again_But_Better.html' ]
);

# Read index page template.
#my $template = Template::Engine->new(
#	file => 'index.html',
#	config => $config
#);

# Create an article.
#my $article = Page::Object::Article->new(
#	file => '2019-03-20_Power12_The_Mini6_Again_But_Better.html',
#	config => $config
#);

# Create a page.
#my $page = Page::Base->new($config, $template, 'index.html');
#$page->render(
#	"blog.title" => $config->{blog}->{title},
#	"blog.subtitle" => $config->{blog}->{title},
#	"article.main" => $article->render()
#);

