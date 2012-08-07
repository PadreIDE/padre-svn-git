#!/bin/bash

BASE_DIR=$(cd $(dirname $0); pwd)
GIT_BASE_DIR="$BASE_DIR/git-repo"
cd $GIT_BASE_DIR || (echo "Can't chdir to $GIT_BASE_DIR" && exit )

$BASE_DIR/kill-svn-branch `git branch -r | grep @` \
	2>&1 | tee $BASE_DIR/data-tmp/out-25-delete-past-pid$$.txt
