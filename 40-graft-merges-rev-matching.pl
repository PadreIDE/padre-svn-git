#!/usr/bin/env perl

use strict;
use warnings;

use Cwd qw(realpath);
use File::Basename;
my $BASE_DIR = dirname realpath __FILE__;

my $GIT_REPO_DIR =  $BASE_DIR.'/git-repo';
chdir( $GIT_REPO_DIR ) || die $!;

chomp (my $GIT_DIR = `git rev-parse --git-dir`);

my @merges = `git log --all --no-merges --format='%H' --grep='merge '`;
chomp @merges;

my $grafts_fpath = "$GIT_DIR/info/grafts";
if ( $ARGV[0] eq 'rewrite' ) {
	print "Rewriting $grafts_fpath\n";
	system("echo > $grafts_fpath");
}
my $debug = ( $ARGV[1] eq 'debug' );

open( my $fh, '>>', $grafts_fpath ) || die $!;
print { $fh } "# Revision matching\n";
for my $commit (@merges) {
    my $commit_data = `git cat-file commit $commit`;
    my ($parent_rev) = $commit_data =~ /^.*?\smerge\s(?:.*\s)?\-?[r\s]?\s*(?:\d+|HEAD)\:(\d+)\s.*\n/msx;
    unless ($parent_rev) {
		($parent_rev) = $commit_data =~ /^.*?\smerge[^\n]+\@(\d+)\s.*\n/msx;
		unless ($parent_rev) {
			my ( $line ) = $commit_data =~ /^.*?\s(merge\s[^\n]+)\n/msx;
			unless ( $line ) {
				warn "odd commit $commit has unparsed merge commit '$commit_data'\n";
			} else {
				warn "odd commit $commit has unparsed merge line '$line'\n";
			}
			next;
		}
    }
    print "--------------\nrev $parent_rev\n$commit_data\n---------------\n\n" if $debug;

    my $parent_commit = `git log --all --format='%H' -E --grep='git-svn-id: .*\@$parent_rev '`;
    chomp $parent_commit;
    my @parents = split /\n/, $parent_commit;
    if (@parents > 1) {
        my ($commit_branch) = $commit_data =~ /git-svn-id: ([^@]+)/;
        my $branch_parent_commit = `git log --all --format='%H' --grep='git-svn-id: $commit_branch\@$parent_rev '`;
        chomp $branch_parent_commit;
        if ($branch_parent_commit =~ /\n/) {
            $branch_parent_commit = `git log --all --format='%H' --grep='git-svn-id: .*/trunk\@$parent_rev '`;
            chomp $branch_parent_commit;
            if ($branch_parent_commit =~ /\n|^$/) {
                warn "odd commit $commit.  parent rev crosses branches\n";
                next;
            }
        }
        elsif (!$branch_parent_commit) {
            warn "odd commit $commit.  parent rev crosses branches\n";
            next;
        }
        $parent_commit = $branch_parent_commit;
    }
    unless ($parent_commit) {
        warn "can't find parent commit for $commit - r$parent_rev\n";
        next;
    }
    my $commit_hashes = `git show -s --format='%H %P' $commit`;
    chomp $commit_hashes;
    my ($commit_hash, @parent_hashes) = split /\s+/, $commit_hashes;

    if (! grep { $parent_commit eq $_ } @parent_hashes ) {
        print { $fh } join(q{ }, $commit_hash, @parent_hashes, $parent_commit) . "\n";
    }
}
close $fh;

system("cat $grafts_fpath");