#!/usr/bin/env perl

use strict;
use warnings;

use Cwd qw(realpath);
use File::Basename;

my $BASE_DIR = dirname realpath __FILE__;
my $GIT_REPO_DIR =  $BASE_DIR.'/git-repo';
chdir( $GIT_REPO_DIR ) || die $!;

my @branches = `git branch -r | cut -c3-`;
chomp @branches;

print "Deleting branches not containing lib/Padre.pm or Padre/lib/Padre.pm\n";
for my $branch ( @branches ) {
    next if  
           system("git show $branch:lib/Padre.pm >/dev/null 2>/dev/null") 
		|| system("git show $branch:Padre/lib/Padre.pm >/dev/null 2>/dev/null")
	;
       
    system "$BASE_DIR/kill-svn-branch $branch";
}

