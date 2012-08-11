#!/bin/bash

MIRROR_FNAME="padre-mirror-r19164.tgz"
#MIRROR_FNAME="svn-mirror-r114.tgz"
REP_SVN_URI="http://svn.perlide.org/padre/"

if [ "$1" != "sure" -a "$1" != "slooow" ]; then
	echo "Read source code before you run this."
	exit;
fi

if [ -d svn-mirror/ ]; then
	echo "Directory svn-mirror/ already exists."
	exit
fi

if [ "$1" = "slooow" ]; then

	echo "Initializing svn-mirror repository"
	svnadmin create svn-mirror

	# svn won't let us change revision properties without a hook in place
	echo '#!/bin/sh' > svn-mirror/hooks/pre-revprop-change && chmod +x svn-mirror/hooks/pre-revprop-change
	svnsync init file://$PWD/svn-mirror $REP_SVN_URI

	echo "Doing svn sync"
	svnsync sync --non-interactive file://$PWD/svn-mirror

	exit
fi

if [ ! -f data-backup/$MIRROR_FNAME ]; then
	curl http://cloud.github.com/downloads/mj41/padre-svn-git/$MIRROR_FNAME -o data-backup/$MIRROR_FNAME
fi

echo "Decompressing data-backup/$MIRROR_FNAME"
tar -xzf data-backup/$MIRROR_FNAME
