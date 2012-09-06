#!/bin/sh

BASE_DIR=$(cd $(dirname $0); pwd)
GIT_BASE_DIR="$BASE_DIR/git-repo"
cd $GIT_BASE_DIR || (echo "Can't chdir to $GIT_BASE_DIR" && exit )

git config --remove-section svn
git config --remove-section svn-remote.svn
rm -rf `git rev-parse --git-dir`/svn
perl -i -ne'next if m{/remotes/svn/}; print' `git rev-parse --git-dir`/info/refs
perl -i -ne'next if m{/remotes/svn/}; print' `git rev-parse --git-dir`/packed-refs
rm -rf `git rev-parse --git-dir`/refs/remotes/svn
