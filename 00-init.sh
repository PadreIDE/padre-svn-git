#!/bin/bash

if [ "$1" != "sure" ]; then 
	echo "Will remove all data already downloaded. See script source code."
	exit;
fi

echo "Creating dirs"
mkdir data-backup
mkdir data-tmp
mkdir git-repo

echo "Deleting data"
rm -rf data-tmp/
rm -rf git-repo/
rm -rf svn-mirror/
