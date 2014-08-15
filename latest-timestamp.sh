#!/usr/bin/env bash

set -e
set -u

max=0
for dir in $(find * -maxdepth 0 -type d); do 
	ts=$(git --no-pager log -1 --format=%at $dir)
	if (($ts > $max)); then
		max=$ts
	fi
done

case $OSTYPE in
  linux-gnu)
    date -u -d @$max +%Y%m%d-%H%M%S
    ;;
  darwin*)
    date -u -r $max +%Y%m%d-%H%M%S
    ;;
  *)
    echo "Unsupported platform: $OSTYPE" >&2
    exit 1
    ;;
esac
