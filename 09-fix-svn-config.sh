#!/bin/sh

BASE_DIR=$(cd $(dirname $0); pwd)
GIT_BASE_DIR="$BASE_DIR/git-repo"
cd $GIT_BASE_DIR || (echo "Can't chdir to $GIT_BASE_DIR" && exit )

# Update svn repo config
git config svn.authorsfile $BASE_DIR/data/authors.txt
git config svn-remote.svn.url file://$BASE_DIR/svn-mirror
