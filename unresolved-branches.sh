#!/usr/bin/env perl

use strict;
use warnings;

use Cwd qw(realpath);
use File::Basename;

my $BASE_DIR = dirname realpath __FILE__;
my $GIT_REPO_DIR =  $BASE_DIR.'/git-repo';
chdir( $GIT_REPO_DIR ) || die $!;

my @branches = `git branch | cut -c3-`;
for ( @branches ) { s/^\s+//; s/\s+$//; };

my %current_branches = map { $_ => 1 } qw(
	master
);

for my $branch ( @branches ) {
    next if $current_branches{$branch};
    next if $branch =~ m{^trash/};
    print "$branch\n";
}

