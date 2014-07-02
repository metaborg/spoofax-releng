# Spoofax release engineering

This repository contains all sub-repositories, projects, and scripts required to build Spoofax.

## Building Spoofax

### Requirements

Building Spoofax requires Git 1.8.2 or higher, the Java Development Kit (JDK) 7 or higher, and Maven 3.2 or higher. Building is only supported on the OSX platform at this moment.

**Git. ** Git is required to check out the source code from our github repositories. Instructions on how to install Git for your platform can be found here: <http://git-scm.com/downloads>. If you run OSX and have [Homebrew](http://brew.sh/) installed, you can install git by executing `brew install git`. Be sure that your git version is 1.8.2 or higher, which you can confirm by executing `git version` on the command line.

**JDK. ** Spoofax is programmed in Java 7, so an installation of Java 7 is required. Maven, the build system that we use, requires the JDK to be installed, the JRE is not enough. The latest JDK can be downloaded and installed from: <http://www.oracle.com/technetwork/java/javase/downloads/index.html>.

On OSX, it can be a bit tricky to use the installed JDK, because Apple by default installs JRE 6. To check which version of Java you are running, execute the `java -version` command. If this tells you that the Java version is 1.7 or higher, everything is fine. If not, the Java version can be set with a command. If you have installed JDK 7, execute:

    export JAVA_HOME=`/usr/libexec/java_home -v 1.7`
    
If you have installed JDK 8, execute:

    export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
    
Note that setting the Java version this way is not permanent. Whenever a new terminal is opened the command needs to be executed again.

Confirm your Java installation and version by executing `java -version`.

**Maven. ** Maven is the build system used to build Spoofax, we require Maven 3.2 or higher. Download links and installation instructions can be found at <http://maven.apache.org/download.cgi>. Maven can be easily installed on OSX with [Homebrew](http://brew.sh/) by executing `brew install maven`. Confirm the installation and version by running `mvn --version`.

### Preparation

As preparation to build Spoofax, the sources need to be checked out from github. Clone this repository and sub-repositories by executing:

    git clone https://github.com/metaborg/spoofax-releng.git
    cd spoofax-releng
    git submodule update --init --remote
    
This can take a while because some repositories have a large history, and github cloning is fairly slow.

We also need to download the strategoxt distribution, execute the following commands:

    cd spoofax-deploy/org.metaborg.maven.spoofax
    ./update-strategoxt.sh
    
This will download the latest distribution from our build farm. You only need to run this command when an update to the distribution is required.

### Build

To start the build, just execute the build script:

    ./build.sh
    
If this is the first time you are building Spoofax, Maven will have to download a lot of Maven and Eclipse plugins. These are cached in the local Maven repository, making subsequent builds faster.

### Output

The main artefact of a Spoofax build is the Eclipse update site which can be used to install or update Spoofax. After a successful build, the update site is located at:

    spoofax-deploy/org.strategoxt.imp.updatesite/target/site

You can add this local update site to Eclipse by navigating to:

    Help -> Install New Software... -> Add -> Local
    
Then it can be used to install Spoofax, like a regular update site. After a restart of Eclipse, Spoofax can be tested.

Alternatively, all projects can be imported into an Eclipse workspace, and a new Eclipse instance can be started to test Spoofax.

## TODO

* Custom version numbering. Currently the timestamp is used as qualifier, but a more deterministic qualifier like the number of commits should be used.
* Linux support
* Windows support