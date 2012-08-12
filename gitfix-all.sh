#!/bin/bash

# Inside data-backup
GITTAR_FNAME="padre-git-r19164.tgz"

BASE_DIR=$(cd $(dirname $0); pwd)

if [ "$1" = "" ]; then
	echo "Read script source code."
	exit 1;
fi

if [ "$1" = "restore" ]; then
	# Restore git-repo
	cd $BASE_DIR \
	&& echo "Removing old git-repo data" \
	&& ( mkdir git-repo || true ) \
	&& ( rm -rf git-repo/* git-repo/.??* || true ) \
	&& echo \
	&& echo "Unpacking git-repo from backup file" \
	&& cd git-repo \
	&& ( tar -xzf $BASE_DIR/data-backup/$GITTAR_FNAME -C $BASE_DIR/git-repo/ \
	     || ( echo "Extract failed" && exit 1 ) \
	   ) \
	&& ls -alh \
	&& cd $BASE_DIR \
	&& echo "Unpack git-repo done" \
	&& echo
fi

if [ "$1" = "run" -o "$2" = "run" ]; then
	echo "Starting cleanup scripts"                   \
	&& echo "Running 20-delete-non-branches.pl"       \
	&& ./20-delete-non-branches.pl                    \
	&& echo                                           \
	&& echo "Running 25-delete-past-branches.sh"      \
	&& ./25-delete-past-branches.sh                   \
	&& echo                                           \
	&& echo "Running 30-fix-refs.sh"                  \
	&& ./30-fix-refs.sh                               \
	&& echo                                           \
	&& echo "Running 39-graft-merges-manual.sh"       \
	&& ./39-graft-merges-manual.pl rewrite            \
	&& echo                                           \
	&& echo "Running 40-graft-merges-rev-matching.pl" \
	&& ./40-graft-merges-rev-matching.pl              \
	&& echo                                           \
	&& echo "Running 49-find-branch-deletion.pl"      \
	&& ./49-find-branch-deletion.pl                   \
	&& echo                                           \
	&& echo "Running 50-delete-empty-branches.pl"     \
	&& ./50-delete-empty-branches.pl                  \
	&& echo                                           \
	&& echo "gitfix all done"
fi
