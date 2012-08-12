#!/usr/bin/env perl

use strict;
use warnings;

use Cwd qw(realpath);
use File::Basename;

my $BASE_DIR = dirname realpath __FILE__;
my $GIT_REPO_DIR =  $BASE_DIR.'/git-repo';
chdir( $GIT_REPO_DIR ) || die $!;

chomp (my $GIT_DIR = `git rev-parse --git-dir`);


my $grafts_fpath = "$GIT_DIR/info/grafts";
if ( $ARGV[0] && $ARGV[0] eq 'rewrite' ) {
	print "Rewriting $grafts_fpath\n";
	system("echo > $grafts_fpath");
}
my $debug = ( $ARGV[1] && $ARGV[1] eq 'debug' );

if ( $debug ) {
	print "Running in debug mode.\n";
}

my @merges;
if ( $ARGV[2] ) {
	my $cmd = "git log -n1 --no-merges --format='%H' --grep='merge' --grep='merging' $ARGV[2]";
	@merges = `$cmd`;
} else {
	@merges = `git log --all --no-merges --format='%H' --grep='merge ' --grep='merging'`;
}
chomp @merges;

my %skip_list = ();
my @commit_sub_strs = (
	'bumping version to current dev version for merge back to trunk', # @19039 - no merge
	'merge all the annotations so they show on the last line (but', # @16276 - no merge
	'this is the working merge of the 0.90 branch back to trunk', # @15704 - manual merge
	'reversing that last merge and commit', # @15703 - no merge
	'about to merge from the 0.90 branch back to trunk', # @15701 - no merge
	'merging indexer fix from trunk', # @15332 ???
	'avoid conflict for merge to trunk prior to re-branch for 0.88', # @15317 - no merge
	'merge latest message.pot into fr-fr.po', # @15043 - no merge
	'setting version number in the branch to current dev', # @14056 - no merge
	'resolve merge conflicts', # @13848 - no merge
	'revert to v0.05, using "svn merge -rHEAD:8244', # @13836 - no merge
	'add experimental branching and merging svn', # @13687 - no merge
	'merge Padre-t1102 - Remove menu item Perl/Automatic Bracket Completion #1102', # @13685 - manual merge
	'FindInFiles was trying to use a directory node, but', # @13464
	[ 'merge changes', '@12317'], # @12317 - no merge
	'merge it together, and move it', # @11801 - no merge
	'merge the uselessly-different Padre::Action:: classes', # @11765 - no merge
	'merge to trunk - Part 2', # @11599 - no merge
	'merge to trunk - Part 1', # @11598 - manual merge
	'Version bump to 0.64 early for Adam to get his merge done', # @11597 - no merge
	'merge artifacts from slave-driver', # @10579 - manual merge
	'merge the STDERR and STDOUT streams', # @9392 - no merge
	'Reverting the if -> if/elsif merging to make', # @8279 - no merge
	'merge changes from branch', # @7865 - manual merge
	'heading toward merge back to trunk.', # @7640 - no merge
	'Should have been removed before merging back to trunk', # @7659 - no merge
	'merge mistake fixed...', # @6583 - no merge
	'merge branches/Padre-Taskmanager', # @5824 - manual merge
	'begin merging find, fast_find and quick_find, and stop bringing', # @2870 - no merge
	'Removing the old modules table, and merging the Padre::DB', # @2817 - no merge
	'merge the Padre-0.25 release branch', # @2684 - manual merge
	'merge over the perl-level crash on icon-not-found', # @2681 - no merge
	'was doing nothing, merge it back into new', # @2233 - no merge
	'msgmerge with latest pot for Arabic translation', # @1974 - no merge
	'merge trunk changes 1249-1264 over to threads', # @1265 - manual merge
	'merge tab and space in.', # @813 - no merge
);

foreach my $sub_str ( @commit_sub_strs ) {

	my $cmd = "git --no-pager log --all --format='%H' --all-match";
	if ( ref $sub_str ) {
		$cmd .= " --grep='" . $_ . "'" foreach @$sub_str;
	} else {
		$cmd .= " --grep='" . $sub_str . "'";
	}

	my @refs = `$cmd`;
	chomp( @refs );
	if ( $debug ) {
		my $tmp_sub_str = ( ref $sub_str ) ? join(' AND ', @$sub_str ) : $sub_str;
		print "Skip list item: $tmp_sub_str\n";
		print "    " . join(" ", @refs ) . "\n";
	}
	$skip_list{ $_ } = $sub_str foreach @refs;
}


sub get_max_rev {
	my ( $p1, $p2 ) = @_;

	my $max_rev = $p1;
    if ( !$max_rev || $max_rev eq 'HEAD' ) {
		$max_rev = $p2;
	} elsif ( $p2 > $max_rev ) {
		$max_rev = $p2;
	}
	return $max_rev;
}

open( my $fh, '>>', $grafts_fpath ) || die $!;
print { $fh } "# Revision matching - $0\n";
for my $commit (@merges) {
	if ( exists $skip_list{$commit} ) {
		print "Skipping $commit - ".$skip_list{$commit}."\n" if $debug;
		next;
	}

    my $commit_data = `git cat-file commit $commit`;
    my ( $p1, $p2 ) = $commit_data =~ /\smerg(?:e|ing)\s(?:.*\s)?\-?[r\s]?\s*(\d+|HEAD)\:(\d+)\s.*/msx;
    my $parent_rev = get_max_rev( $p1, $p2 );
    #print "p1 ".($p1 // '').", p2 ".($p2 // '').", parent_rev ".($parent_rev // '')."\n" if $debug;

    unless ($parent_rev) {
		($parent_rev) = $commit_data =~ /\smerg(?:e|ing)[^\n]+\@(\d+)\s/msx;
		unless ($parent_rev) {
			my ( $line ) = $commit_data =~ /((?:[^\n]*\s)merg(?:e|ing)\s[^\n]+)/msx;
			unless ( $line ) {
				warn "unparsed merge commit $commit - commit '$commit_data'\n";
			} else {
				warn "unparsed merge commit $commit - merge line '$line'\n";
			}
			next;
		}
    }

    if ( $debug ) {
		print "--------------\n";
		print "rev $parent_rev\n";
		print "ref $commit\n";
		print "$commit_data\n";
		print "---------------\n";
		print "\n";
	}

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
            warn "odd commit $commit parent rev crosses branches\n";
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