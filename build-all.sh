#!/usr/bin/env bash

set -e
set -u


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
QUALIFIER=$(./latest-timestamp.sh)


echo "Using qualifier $QUALIFIER"

./spoofax-deploy/org.metaborg.maven.build.strategoxt/build.sh
./spoofax-deploy/org.metaborg.maven.build.java/build.sh -q $QUALIFIER
./spoofax-deploy/org.metaborg.maven.build.spoofax.eclipse/build.sh -q $QUALIFIER
./spoofax-deploy/org.metaborg.maven.build.spoofax.libs/build.sh
./spoofax-deploy/org.metaborg.maven.build.spoofax.sunshine/build.sh
./spoofax-deploy/org.metaborg.maven.build.spoofax.benchmark/build.sh

ECLIPSE_UPDATE_SITE="$DIR/spoofax-deploy/org.strategoxt.imp.updatesite/target/site"
SUNSHINE_JAR_ARRAY=("$DIR/spoofax-sunshine/org.spoofax.sunshine/target/org.metaborg.sunshine-"*"-shaded.jar")
BENCHMARK_JAR_ARRAY=("$DIR/spoofax-benchmark/org.metaborg.spoofax.benchmark.cmd/target/org.metaborg.spoofax.benchmark.cmd-"*".jar")
LIBRARIES_JAR_ARRAY=("$DIR/spoofax-deploy/org.metaborg.maven.build.spoofax.libs/target/org.metaborg.maven.build.spoofax.libs-"*".jar")

echo "Build products"
echo "Eclipse update site: $ECLIPSE_UPDATE_SITE"
echo "Sunshine JAR: ${SUNSHINE_JAR_ARRAY[0]}"
echo "Benchmark JAR: ${BENCHMARK_JAR_ARRAY[0]}"
echo "Libraries JAR: ${LIBRARIES_JAR_ARRAY[0]}"