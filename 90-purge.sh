#!/bin/sh

BASE_DIR=$(cd $(dirname $0); pwd)
GIT_BASE_DIR="$BASE_DIR/git-repo"
cd $GIT_BASE_DIR || exit 1

# ditch all pre-conversion objects forcefully
git reflog expire --all --expire=now
git prune
git prune-packed
git repack -a -d -f --window=250 --depth=250
git fsck --full
