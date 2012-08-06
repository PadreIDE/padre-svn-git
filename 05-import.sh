#!/bin/bash

BASE_DIR=$(cd $(dirname $0); pwd)
GIT_BASE_DIR="$BASE_DIR/git-repo"

if [ ! -d $GIT_BASE_DIR  ]; then
    mkdir $GIT_BASE_DIR
fi

cd $GIT_BASE_DIR || (echo "Can't chdir to $GIT_BASE_DIR" && exit )

git init

git svn init \
    --trunk=trunk \
    --tags=tags \
    --branches=branches \
    --prefix=svn/ \
    file://$BASE_DIR/svn-mirror \
    2>&1 | tee $BASE_DIR/data-tmp/out-05-import.txt

git config svn.authorsfile $BASE_DIR/data/authors
git svn fetch --authors-prog=$BASE_DIR/author-generate
