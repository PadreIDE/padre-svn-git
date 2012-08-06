#!/bin/bash

REV=$(svnlook youngest svn-mirror/)
DEST_FPATH="data-backup/svn-mirror-r"$REV".tgz"

if [ -f $DEST_FPATH ]; then
	echo "Backup $DEST_FPATH already exists."
else
	echo "Doing backup of svn-mirror on revision $REV to $DEST_FPATH"
	tar -czf $DEST_FPATH svn-mirror/
fi

echo "Actual backups"
ls -alh data-backup/