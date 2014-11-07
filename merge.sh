#!/usr/bin/env bash

set -eu

FROM_BRANCH="$1"

mv .gitmodules to.gitmodules
git checkout $FROM_BRANCH -- .gitmodules
mv .gitmodules from.gitmodules
mv to.gitmodules .gitmodules

git config -f from.gitmodules --get-regexp '^submodule\..*\.branch$' |
while read key branch 
do
  name=$(echo $key | sed 's/submodule\.//' | sed 's/\.branch//')
  branch=$(git config -f from.gitmodules --get "$key")
  (cd $name; git merge $branch)
done

rm from.gitmodules
