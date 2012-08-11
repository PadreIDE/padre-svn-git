#!/bin/bash

# clean up working dir

BASE_DIR=$(cd $(dirname $0); pwd)
GIT_BASE_DIR="$BASE_DIR/git-repo"
cd $GIT_BASE_DIR || (echo "Can't chdir to $GIT_BASE_DIR" && exit )

git update-ref -d master

# create annotated tags out of svn tags
git for-each-ref --format='%(refname)' refs/remotes/svn/tags/* | while read tag_ref; do
    tag=${tag_ref#refs/remotes/svn/tags/}
    tree=$( git rev-parse "$tag_ref": )
	echo "tag $tag"

    # find the oldest ancestor for which the tree is the same
    parent_ref="$tag_ref";
    while [ "$( git rev-parse --quiet --verify "$parent_ref"^: )" = "$tree" ]; do
        echo "  searching oldest ancestor: $tree, $parent_ref"
        parent_ref="$parent_ref"^
    done
    parent=$( git rev-parse "$parent_ref" );
    echo "  parent found: $parent"

    # if this ancestor is in trunk then we can just tag it
    # otherwise the tag has diverged from trunk and it's actually more like a
    # branch than a tag
    merge=$( git merge-base "refs/remotes/svn/trunk" $parent );
    if [ "$merge" = "$parent" ]; then
        target_ref=$parent
    else
        echo "  ! tag has diverged: $tag ($merge), $tag_ref"
        target_ref="$tag_ref"
    fi

    # create an annotated tag based on the last commit in the tag, and delete the "branchy" ref for the tag
    git show -s --pretty='format:%s%n%n%b' "$tag_ref" | \
    perl -ne 'next if /^git-svn-id:/; $s++, next if /^\s*r\d+\@.*:.*\|/; s/^ // if $s; print' | \
    env GIT_COMMITTER_NAME="$(  git show -s --pretty='format:%an' "$tag_ref" )" \
        GIT_COMMITTER_EMAIL="$( git show -s --pretty='format:%ae' "$tag_ref" )" \
        GIT_COMMITTER_DATE="$(  git show -s --pretty='format:%ad' "$tag_ref" )" \
        git tag -a -F - "$tag" "$target_ref" \
	    && echo "  updated ref: $tag $target_ref"

	echo "  deleting ref $tag_ref"
    git update-ref -d "$tag_ref"
    echo ""
done

# create local branches out of svn branches
git for-each-ref --format='%(refname)' refs/remotes/svn/ | while read branch_ref; do
    branch=${branch_ref#refs/remotes/svn/}
    git branch "$branch" "$branch_ref"
    git update-ref -d "$branch_ref"
done

# rename 'trunk' to 'master'
git checkout trunk
git branch -M trunk master

