#!/bin/bash

BASE_DIR=$(cd $(dirname $0); pwd)
GIT_BASE_DIR="$BASE_DIR/git-repo"
cd $GIT_BASE_DIR || exit 1

# remove merged branches
git for-each-ref --format='%(refname)' refs/heads | while read branch; do
    git rev-parse --quiet --verify "$branch" > /dev/null || continue # make sure it still exists
    git symbolic-ref HEAD "$branch"
    echo "merged branches:"
    git branch --merged | grep -v '^\*'
    git branch -d $( git branch --merged | grep -v '^\*' | grep -v 'master' )
done

git checkout master
