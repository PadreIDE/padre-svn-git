#!/usr/bin/env perl

use strict;
use warnings;

use Cwd qw(realpath);
use File::Basename;
use POSIX qw(ceil);

my $BASE_DIR = dirname realpath __FILE__;
my $GIT_REPO_DIR =  $BASE_DIR.'/git-repo';
chdir( $GIT_REPO_DIR ) || die $!;

my @branches = @ARGV;
if (! @branches) {
    @branches = `$BASE_DIR/unresolved-branches`;
    chomp @branches;
}

my $max_rev = `svn info file://$BASE_DIR/svn-mirror | grep Revision | cut -d' ' -f2`;
chomp $max_rev;

my $delbr_info_fpath = "$BASE_DIR/data/deleted-branches-info";
open(my $delbr_info_fh, '>', $delbr_info_fpath ) || die $!;
my @deleted = ();
BRANCH: for my $branch (@branches) {
    my $url = `git cat-file commit $branch | tail -1 | cut -d' ' -f2`;
    chomp $url;
    my ($path, $rev) = split /@/, $url;

	#print "$path $rev\n";
    my $low_rev = $rev;
    my $high_rev = $max_rev;
    while (1) {
        my $test_rev = ceil( ($low_rev + $high_rev) / 2 );
        if ($test_rev == $low_rev || $test_rev == $high_rev) {
            my $str = sprintf "%-40s# deleted at %s\n", $branch, $test_rev;
            print $str;
            print $delbr_info_fh $str;
            push @deleted, $branch;
            next BRANCH;
        }
        my $res = system "svn log -l1 $path\@$test_rev >/dev/null 2>/dev/null";
        ($res ? $high_rev : $low_rev) = $test_rev;
    }
}
close $delbr_info_fh || die $!;

my $delbr_fpath = "$BASE_DIR/data/deleted-branches";
open(my $delbr_fh, '>', $delbr_fpath ) || die $!;
print $delbr_fh join("\n", @deleted ) . "\n";
close $delbr_fh || die $!;

#system("cat $delbr_fpath");


