#!/bin/sh

BASE_DIR=$(cd $(dirname $0); pwd)
GIT_BASE_DIR="$BASE_DIR/git-repo"
cd $GIT_BASE_DIR || exit 1

# remove the backup refs
git for-each-ref --format='%(refname)' refs/original/ refs/remotes/svn/ | while read ref; do
    git update-ref -d "$ref"
done
