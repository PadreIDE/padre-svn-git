#!/bin/sh

BASE_DIR=$(cd $(dirname $0); pwd)
GIT_BASE_DIR="$BASE_DIR/git-repo"

svnsync sync --non-interactive file://$BASE_DIR/svn-mirror

if [ -d "$GIT_BASE_DIR" ]; then
	git svn fetch --authors-prog=$BASE_DIR/author-generate.sh \
		2>&1 | tee $BASE_DIR/data-tmp/out-05-import-`date +%s`.txt
else
	echo "Directory $GIT_BASE_DIR not found. Skipping git svn fetch."
fi
