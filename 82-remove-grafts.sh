#!/bin/sh

BASE_DIR=$(cd $(dirname $0); pwd)
GIT_BASE_DIR="$BASE_DIR/git-repo"
cd $GIT_BASE_DIR || exit 1

rm `git rev-parse --git-dir`/info/grafts
