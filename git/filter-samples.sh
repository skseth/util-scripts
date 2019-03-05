#!/bin/bash

shopt -s extglob


clean-after-filter() {
    local repo="$1"

    pushd "$repo"

    # run these commands after filter to do GC for a repo 

    # remove references pointing to old objects to allow them to be gc'ed
    git for-each-ref --format="%(refname)" refs/original/ | \
        xargs -rn 1 git update-ref -d

    # prune unreachable reflog entries 
    git reflog expire --verbose --expire=0 --all

    # run gc
    git gc --prune=0

    popd
}


filter-remove-paths() {
    local repo="$1"

    pushd "$repo"

    git config core.longpaths true
    git reset --hard


    # The following command removes all folder1, folder2 and file1 from index
    git filter-branch -f --index-filter "
    git rm --cached -qr --ignore-unmatch -- folder1 folder2 file1
    " --prune-empty --tag-name-filter cat -- --all

    popd 
}

filter-keep-paths() {
    local repo="$1"

    pushd "$repo"

    git config core.longpaths true
    git reset --hard


    # The following command removes all folders from index
    # then reinstates folder1, 2 and file1
    git filter-branch -f --index-filter "
    git rm --cached -qr --ignore-unmatch -- .
    git reset -q $GIT_COMMIT -- folder1 folder2 file1
    " --prune-empty --tag-name-filter cat -- --all

    popd 
}


filter-keep-paths-with-exceptions() {
    local repo="$1"

    pushd "$repo"

    git config core.longpaths true
    git reset --hard


    # The following command removes all folders from index
    # then reinstates folder1, 2 and 3
    # then removes files or folders folder1/a and folder2/b
    git filter-branch -f --index-filter "
    git rm --cached -qr --ignore-unmatch -- .
    git reset -q $GIT_COMMIT -- folder1 folder2 folder3
    git rm --cached -qr --ignore-unmatch -- folder1/a folder2/b
    " --prune-empty --tag-name-filter cat -- --all

    popd 
}








