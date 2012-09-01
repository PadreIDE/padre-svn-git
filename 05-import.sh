#!/bin/bash

GITTAR_FNAME="padre-git-r19164.tgz"

BASE_DIR=$(cd $(dirname $0); pwd)
GIT_BASE_DIR="$BASE_DIR/git-repo"

if [ "$1" != "archive" -a "$1" != "slooow" ]; then
	echo "Read source code before you run this."
	exit;
fi

if [ -d $GIT_BASE_DIR ]; then
	echo "Directory git-repo/ already exists."
	exit
fi


if [ "$1" = "slooow" ]; then

	if [ ! -d svn-mirror/ ]; then
		echo "Directory svn-mirror/ doesn't exist."
		exit
	fi

	mkdir $GIT_BASE_DIR
	cd $GIT_BASE_DIR || (echo "Can't chdir to $GIT_BASE_DIR" && exit )

	git init

	git svn init \
		--trunk=trunk \
		--tags=tags \
		--branches=branches \
		--prefix=svn/ \
		file://$BASE_DIR/svn-mirror \
		2>&1 | tee $BASE_DIR/data-tmp/out-05-import.txt

	git config svn.authorsfile $BASE_DIR/data/authors.txt
	git svn fetch --authors-prog=$BASE_DIR/author-generate.txt

	exit
fi


if [ ! -f data-backup/$GITTAR_FNAME ]; then
	curl http://cloud.github.com/downloads/mj41/padre-svn-git/$GITTAR_FNAME -o data-backup/$GITTAR_FNAME
fi

mkdir $GIT_BASE_DIR

echo "Decompressing data-backup/$GITTAR_FNAME"
tar -xzf $BASE_DIR/data-backup/$GITTAR_FNAME -C $BASE_DIR/git-repo/ \
     || ( echo "Extract failed" && exit 1 )

