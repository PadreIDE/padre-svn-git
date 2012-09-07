#!/usr/bin/env perl

use strict;
use warnings;

use Cwd qw(realpath);
use File::Basename;

my $BASE_DIR = dirname realpath __FILE__;
my $GIT_REPO_DIR =  $BASE_DIR.'/git-repo';
chdir( $GIT_REPO_DIR ) || die $!;


my @not_found;
my %map_svn_git;
my %map_git_svn;
for my $sha (`git rev-list --all --date-order --timestamp | sort -n | awk '{print \$2}'`) {
	chomp $sha;
	my ( $svnid ) = `git show -s $sha | tail -2` =~ /git\-svn\-id\:[^\n]+[@](\d+)\s+.*?(\n|$)/s;
	unless ( $svnid ) {
		print "$sha ERROR - svn id not found\n";
		push @not_found, $sha;

	} else {

		$map_git_svn{$sha} = $svnid;

		$map_svn_git{$svnid} = [] unless exists $map_svn_git{$svnid};
		push @{$map_svn_git{$svnid}}, $sha;

		my $num = scalar @{$map_svn_git{$svnid}};
		my $tag_str = 'sr' . $svnid . '-gn' . $num;

		print "$sha, svn rev $svnid, $tag_str\n";
		system( "git tag -f $tag_str $sha 1>/dev/null" );
	}
}

if ( scalar @not_found ) {
	print "Not found list: " . join(" ", @not_found) . "\n";
}

my $map_fpath = "$BASE_DIR/rev-sha-map.txt";
print "Printing SVN rev to Git SHA map to '$map_fpath'\n";

open(my $map_fh, '>', $map_fpath ) || die $!;
foreach my $svnid ( sort { $a <=> $b } keys %map_svn_git ) {
	print { $map_fh } $svnid . ' ' . join(' ', @{$map_svn_git{$svnid}} ) . "\n";
}
close $map_fh || die $!;
