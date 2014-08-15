#!/usr/bin/env bash

set -e
set -u

./spoofax-deploy/org.metaborg.maven.build.strategoxt/build.sh
./spoofax-deploy/org.metaborg.maven.build.java/build.sh
./spoofax-deploy/org.metaborg.maven.build.spoofax.eclipse/build.sh
./spoofax-deploy/org.metaborg.maven.build.spoofax.libs/build.sh
./spoofax-deploy/org.metaborg.maven.build.spoofax.sunshine/build.sh
