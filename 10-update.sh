#!/bin/sh

BASE_DIR=$(cd $(dirname $0); pwd)
GIT_BASE_DIR="$BASE_DIR/git-repo"
cd $GIT_BASE_DIR || (echo "Can't chdir to $GIT_BASE_DIR" && exit )

svnsync sync --non-interactive file://$BASE_DIR/svn-mirror

git svn fetch --authors-prog=$BASE_DIR/author-generate.sh \
	2>&1 | tee $BASE_DIR/data-tmp/out-05-import-pid$$.txt
