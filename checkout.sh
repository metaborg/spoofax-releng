#!/usr/bin/env bash

set -e
set -u

git config -f .gitmodules --get-regexp '^submodule\..*\.branch$' |
while read key branch 
do
  name=$(echo $key | sed 's/submodule\.//' | sed 's/\.branch//')
  branch=$(git config -f .gitmodules --get "$key")
  (cd $name; git checkout $branch)
done