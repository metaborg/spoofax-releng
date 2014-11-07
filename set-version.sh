#!/usr/bin/env bash

set -eu

MAVEN_OLD_VERSION=$1
MAVEN_NEW_VERSION=$2
ECLIPSE_OLD_VERSION=$(echo $MAVEN_OLD_VERSION | sed s/-SNAPSHOT/.qualifier/)
ECLIPSE_NEW_VERSION=$(echo $MAVEN_NEW_VERSION | sed s/-SNAPSHOT/.qualifier/)

echo "Old version: $MAVEN_OLD_VERSION / $ECLIPSE_OLD_VERSION"
echo "New version: $MAVEN_NEW_VERSION / $ECLIPSE_NEW_VERSION"

#MAVEN_OPTS="-Xmx512m -Xms512m -Xss16m" mvn org.eclipse.tycho:tycho-versions-plugin:set-version -DnewVersion=$MAVEN_NEW_VERSION -Dproperties=metaborg-version -Dartifacts=org.metaborg.maven.parent

function sedeasy {
  sed -i '' "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

echo "Manually patching spoofax-deploy/org.strategoxt.imp.feature/feature.xml, because Tycho does not change the versions in feature.xml for Java projects."
sedeasy "$ECLIPSE_OLD_VERSION" "$ECLIPSE_NEW_VERSION" spoofax-deploy/org.strategoxt.imp.feature/feature.xml
echo "Manually patching spoofax/org.strategoxt.imp.generator/src/sdf2imp/project/create-maven-pom.str, so that the generated POM file uses the right version."
sedeasy "$MAVEN_OLD_VERSION" "$MAVEN_NEW_VERSION" spoofax/org.strategoxt.imp.generator/src/sdf2imp/project/create-maven-pom.str
