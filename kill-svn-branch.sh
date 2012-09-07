#!/usr/bin/env perl

use strict;
use warnings;

use Cwd qw(realpath);
use File::Basename;
use File::Path qw(rmtree);

my $BASE_DIR = dirname realpath __FILE__;

my $GIT_REPO_DIR =  $BASE_DIR.'/git-repo';
chdir( $GIT_REPO_DIR ) || die $!;

my $GIT_DIR = `git rev-parse --git-dir`;
chomp $GIT_DIR;

kill_svn_branch(@ARGV);

sub kill_svn_branch {
    my $io;
    my @refs;
    for my $branch (@_) {
        $branch =~ s{^remotes/}{};
    	print "Removing branch '$branch'.\n";

        system 'git', 'branch', '-r', '-D', $branch;
        rmtree("$GIT_DIR/svn/refs/remotes/$branch");

        open $io, '<', '.git/info/refs';
        @refs = <$io>;
        close $io;

        @refs = grep { !m{\srefs/remotes/$branch$} } @refs;
        open $io, '>', $GIT_DIR . '/info/refs';
        print {$io} @refs;
        close $io;

        open $io, '<', $GIT_DIR . '/packed-refs';
        @refs = <$io>;
        close $io;

        @refs = grep { !m{\srefs/remotes/$branch$} } @refs;
        open $io, '>', $GIT_DIR . '/packed-refs';
        print {$io} @refs;
        close $io;
    }
}

