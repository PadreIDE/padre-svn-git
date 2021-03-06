#!/usr/bin/env perl
use strict;
use warnings;

use Cwd qw(realpath);
use File::Basename;

my $BASE_DIR = dirname realpath __FILE__;
my $GIT_REPO_DIR =  $BASE_DIR.'/git-repo';
chdir( $GIT_REPO_DIR ) || die $!;

my $delbr_fpath = "$BASE_DIR/data/do-delete-empty-branches.txt";
exit unless -f $delbr_fpath;

open(my $delbr_fh, '<', $delbr_fpath ) || die $!;

while ( <$delbr_fh> ) {
    s/^#.*//;
    s/\s+#.*//;
    s/^\s+//;
    s/\s+$//;
    next if $_ eq '';
    system "git branch -D '$_'";
}

close $delbr_fh;

