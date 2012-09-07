#!/bin/bash

BASE_DIR=$(cd $(dirname $0); pwd)
GIT_BASE_DIR="$BASE_DIR/git-repo"
cd $GIT_BASE_DIR || exit 1

GIT_DIR=`git rev-parse --git-dir`
if [ "$GIT_DIR" != '.git' ]; then
	echo "Git dir .git not found."
	exit 1;
fi

SVN_REV=`git svn info | grep 'Revision: ' | cut -d' ' -f2`

# Inside data-backup
GITTAR_FNAME="padre-git-$SVN_REV"
echo "Base file name $GITTAR_FNAME"

du -hs $GIT_DIR

echo "Running 90-purge.sh"
#./../90-purge.sh

FULL_GITTAR=data-backup/$GITTAR_FNAME-`date +%s`".tgz"
echo "Compressing to $FULL_GITTAR"
tar -czf "../$FULL_GITTAR" ./.git/

du -hs $GIT_DIR
ls -hl ../$FULL_GITTAR

echo "Done."
