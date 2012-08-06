#!/bin/bash

curl http://svn.perlide.org/padre/subversion/users.txt > data-tmp/authors-org
diff data-tmp/authors-org data/authors
