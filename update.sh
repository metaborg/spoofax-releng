#!/usr/bin/env bash

set -e
set -u

git submodule update --init --remote --recursive --depth 1
