#!/usr/bin/env bash

set -eu

MAVEN_OPTS="-Xmx512m -Xms512m -Xss16m" mvn org.eclipse.tycho:tycho-versions-plugin:set-version -DnewVersion=$1 -Dproperties=metaborg-version -Dartifacts=org.metaborg.maven.parent
