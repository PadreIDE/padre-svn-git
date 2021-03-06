#!/usr/bin/env perl
use strict;
use warnings;

use Cwd qw(realpath);
use File::Basename;
my $BASE_DIR = dirname realpath __FILE__;

my ($user) = @ARGV;

my $author_file = $BASE_DIR . '/data/authors.txt';
my $author = "$user <$user\@svngit.padre.perlide.org>";

open my $fh, '>>', $author_file;
print { $fh } "$user = $author\n";
close $fh;
print "$author\n";

exit 0;
