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

my %skip_list = ();
my @commit_sub_strs = (
	# not sure about this, see @15702, @15703, @15704
	[
		'this is the working merge of the 0.90 branch back to trunk', # @15704 - manual merge
		'about to merge from the 0.90 branch back to trunk',
	],

	[
		'merge Padre-t1102 - Remove menu item Perl/Automatic Bracket Completion #1102', # @13685 - manual merge
		'Remove  Perl/Automatic Bracket Completion',
	],

	[
		'merge to trunk - Part 1', # @11598 - manual merge
		'changes update (fix #956) and tidy', # @11524
	],

	[
		'merge artifacts from slave-driver', # @10579 - manual merge
		'Merge 10552:10562 from trunk to branch', # @
	],

	[
		'merge changes from branch', # @7865 - manual merge
		'use require instead of use',
	],

	[
		'merge branches/Padre-Taskmanager', # @5824 - manual merge
		'fix interface dodging and add some diagnostics to postevent parts',
	],

	[
		'merge the Padre-0.25 release branch', # @2684 - manual merge
		'fix test script # @2682',
	],

	[
		'merge trunk changes 1249-1264 over to threads', # @1265 - manual merge
		'allow number prefix before the lkjh movement keys in vi-mode'
	],
);

sub grep_commits {
	my ( $sub_str ) = @_;
	my $cmd = "git --no-pager log --all --format='%H' --grep='". $sub_str . "'";

	my @refs = `$cmd`;
	chomp( @refs );
	return @refs;
}


sub get_parents {
	my ( $commit ) = @_;
	my $cmd = 'git --no-pager log --all -n1 --pretty=format:%P ' . $commit;
	my $str = `$cmd`;
	chomp( $str );
	return split(/\s+/, $str);
}


my @merge_info;
foreach my $strs ( @commit_sub_strs ) {
	my @childs = grep_commits( $strs->[0] );
	my @new_parents = grep_commits( $strs->[1] );
	my $child_num = 1;
	foreach my $child ( @childs ) {
		print "Child $child\n";
		my @act_parents = get_parents( $child );
		print "  Act parents for child num $child_num - " . join(" ",@act_parents) . "\n";
		print "  New parents " . join(" ",@new_parents) . "\n";
		push @merge_info, [
			$child,
			@act_parents,
			@new_parents
		];
		$child_num++;
	}
	print "\n";
}


open( my $fh, '>>', $grafts_fpath ) || die $!;
print { $fh } "# Revision matching - $0\n";

foreach my $commits ( @merge_info ) {
	print { $fh } join(' ', @$commits) . "\n";
}

close $fh;
system("cat $grafts_fpath");