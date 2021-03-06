#!/usr/bin/env perl
use strict;
use warnings;

use Cwd qw(realpath);
use File::Basename;
my $BASE_DIR = dirname realpath __FILE__;

my $GIT_REPO_DIR =  $BASE_DIR.'/git-repo';
chdir( $GIT_REPO_DIR ) || die $!;

my @branches = `git branch -a | cut -c3-`;
chomp @branches;

for my $branch (@branches) {
    next unless $branch =~ /\@/;

    my ($base_branch, $rev) = split /\@/, $branch, 2;
    ($rev) = `git cat-file commit $branch` =~ /\bgit-svn-id: [^@]+\@(\d+)/;
    my $result = `git log -E --grep='git-svn-id: .*\@$rev' $base_branch`;
    if ($result =~ /\S/) {
        # found rev in base branch, this one is useless
        system "$BASE_DIR/kill-svn-branch.sh $branch";
    }
}

