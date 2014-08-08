# Metaborg release engineering

This repository contains all sub-repositories, projects, and scripts required to build our Java components, Spoofax, and Sunshine.

# Short build description

This description skips over details and just provides the commands to build Spoofax and Sunshine. See the next section for a detailed description of the builds.

Execute the following commands:

    git clone https://github.com/metaborg/spoofax-releng.git
    cd spoofax-releng
    git submodule update --init --remote
    
    cd spoofax-deploy/org.metaborg.maven.build.strategoxt
    ./build.sh -u
    cd ..
    cd org.metaborg.maven.build.java
    ./build.sh
    cd ..
    cd org.metaborg.maven.build.spoofax.eclipse
    ./build.sh
    cd ..
    cd org.metaborg.maven.build.spoofax.sunshine
    ./build.sh
    
The Spoofax update site can be found at:

    spoofax-deploy/org.strategoxt.imp.updatesite/target/site
    
The Sunshine JAR can be found at:

    spoofax-sunshine/org.spoofax.sunshine/target/org.metaborg.sunshine-<VERSION>.jar
    
# Detailed build description

This is the detailed description, going over requirements and explaining each step in more detail.

## Supported platforms

Linux and OSX are supported, Windows is currently not supported.

## Requirements

Building anything requires Git 1.8.2 or higher, the Java Development Kit (JDK) 7 or higher, Maven 3.2 or higher, and wget. Building is only supported on the OSX platform at this moment.

**Git.** Git is required to check out the source code from our GitHub repositories. Instructions on how to install Git for your platform can be found here: <http://git-scm.com/downloads>. If you run OSX and have [Homebrew](http://brew.sh/) installed, you can install Git by executing `brew install git`. Be sure that your Git version is 1.8.2 or higher, which you can confirm by executing `git version` on the command line.

**JDK.** Spoofax is programmed in Java 7, so an installation of Java 7 is required. Maven, the build system that we use, requires the JDK to be installed, the JRE is not enough. The latest JDK can be downloaded and installed from: <http://www.oracle.com/technetwork/java/javase/downloads/index.html>.

On OSX, it can be a bit tricky to use the installed JDK, because Apple by default installs JRE 6. To check which version of Java you are running, execute the `java -version` command. If this tells you that the Java version is 1.7 or higher, everything is fine. If not, the Java version can be set with a command. If you have installed JDK 7, execute:

    export JAVA_HOME=`/usr/libexec/java_home -v 1.7`
    
If you have installed JDK 8, execute:

    export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
    
Note that setting the Java version this way is not permanent. Whenever a new terminal is opened the command needs to be executed again.

Confirm your Java installation and version by executing `java -version`.

**Maven.** Maven is the build system used to build Spoofax, we require Maven 3.2 or higher. Download links and installation instructions can be found at <http://maven.apache.org/download.cgi>. Maven can be easily installed on OSX with Homebrew by executing `brew install maven`. Confirm the installation and version by running `mvn --version`.

**wget.** Wget is installed from homebrew with `brew install wget`.

## Preparation

As preparation for building, the sources need to be checked out from GitHub. Clone this repository and sub-repositories by executing:

    git clone https://github.com/metaborg/spoofax-releng.git
    cd spoofax-releng
    git submodule update --init --remote
    
This can take a while because some repositories have a large history, and GitHub cloning is fairly slow.

We also need to download and install the StrategoXT distribution, execute the following commands:

    cd spoofax-deploy/org.metaborg.maven.build.strategoxt
    ./build.sh
    
This will download the latest distribution from our build farm and install it in your local Maven repository. To update the installed StrategoXT distribution at a later time, run:

    ./build.sh -u
    
After the build is finished, `cd` back into the root of the repository.

## Building the Java components

The Java components consist of the following projects:

* Stratego/Abstract terms
	* org.spoofax.terms
	* org.spoofax.aterm
* Stratego interpreter and libraries
	* org.spoofax.interpreter
	* org.spoofax.interpreter.core
	* org.spoofax.interpreter.library.interpreter
	* org.spoofax.interpreter.library.java
	* org.spoofax.interpreter.library.jline
	* org.spoofax.interpreter.library.xml
* Index library
	* org.spoofax.interpreter.library.index
* Task engine framework
	* org.metaborg.runtime.task
* Spoofax generator
	* org.strategoxt.imp.generator
* SGLR parser
	* org.spoofax.jsglr
	* org.spoofax.interpreter.library.jsglr
* Stratego Java backend
	* org.strategoxt.strj
* External dependencies
	* org.spoofax.interpreter.externaldeps
	
To build and install them, execute the following commands:

    cd spoofax-deploy/org.metaborg.maven.build.java
    ./build.sh
    
Maven will build and install all projects into your local Maven repository as artefacts. Other builds can then depend on these installed artefacts. After the build is finished, `cd` back into the root of the repository.

## Building Spoofax

The Spoofax build uses the StrategoXT distribution and Java components which were installed in previous steps. If you are building Spoofax again at a later time, be sure to update your installed StrategoXT distribution and Java components before building Spoofax.

To start the build, just execute the build script:
    
    cd spoofax-deploy/org.metaborg.maven.build.spoofax.eclipse
    ./build.sh

The main artefact of a Spoofax build is the Eclipse update site which can be used to install or update Spoofax. After a successful build, the update site is located at:

    spoofax-deploy/org.strategoxt.imp.updatesite/target/site

You can add this local update site to Eclipse by navigating to:

    Help -> Install New Software... -> Add -> Local
    
Then it can be used to install Spoofax, like a regular update site. After a restart of Eclipse, Spoofax can be tested.

Alternatively, all projects can be imported into an Eclipse workspace, and a new Eclipse instance can be started to test Spoofax.

## Building Sunshine

Sunshine depends on the StrategoXT distribution and Java components as well, be sure to keep them up to date. To start the build, just execute the build script:
    
    cd spoofax-deploy/org.metaborg.maven.build.spoofax.sunshine
    ./build.sh
    
The result is an executable JAR which includes all dependencies, which can be found at:

    spoofax-sunshine/org.spoofax.sunshine/target/org.metaborg.sunshine-<VERSION>.jar

# Setting up Eclipse for Spoofax development

TODO

# Build qualifier

Eclipse and Maven use the `major.minor.patch-qualifier` scheme for versioning. The major, minor, and patch parts of the version are set in each project, but the -qualifier part is not. In Maven, `-SNAPSHOT` is used as qualifier for replaceable (nightly) builds, but it is not required to replace `SNAPSHOT` with an actual number. However, in Eclipse, a plugin can only be upgraded if its version is higher than the installed version, so each build needs a higher qualifier number to be able to update installed plugins.

By default, the Java and Spoofax build scripts use the current date and time as qualifier but can be modified by passing the `-q number` parameter as follows:

```
QUALIFIER=12345

cd org.metaborg.maven.build.java
./build.sh -q $QUALIFIER
cd ..

cd org.metaborg.maven.build.spoofax.eclipse
./build.sh -q $QUALIFIER
cd ..
```
An increasing reproducible qualifier can be created by getting the commit count of all git repositories with `git rev-list HEAD --count` and summing them.

# Additional arguments

All build scripts accept two arguments to change the behaviour of Maven. The `MAVEN_OPTS` environment variable can be set with the `-e opts`, which is used to set the JVM arguments that Maven uses. The `-a args` sets extra arguments that are passed to Maven.

For example, to increase memory and enable parallel builds with 4 cores, pass the following arguments: `-e "-server -Xmx512m -Xms512m -Xss16m" -a "-T 4"`.

# TODO

* Windows support
* Troubleshooting/FAQ
