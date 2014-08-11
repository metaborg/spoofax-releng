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

Building anything requires Git 1.8.2 or higher, the Java Development Kit (JDK) 7 or higher, Maven 3.2 or higher, and wget.

**Git.**
Git is required to check out the source code from our GitHub repositories. Instructions on how to install Git for your platform can be found here: <http://git-scm.com/downloads>. If you run OSX and have [Homebrew](http://brew.sh/) installed, you can install Git by executing `brew install git`. Be sure that your Git version is 1.8.2 or higher, which you can confirm by executing `git version` on the command line.

**JDK.**
Spoofax is programmed in Java 7, so an installation of Java 7 is required. Maven, the build system that we use, requires the JDK to be installed, the JRE is not enough. The latest JDK can be downloaded and installed from: <http://www.oracle.com/technetwork/java/javase/downloads/index.html>.

On OSX, it can be a bit tricky to use the installed JDK, because Apple by default installs JRE 6. To check which version of Java you are running, execute the `java -version` command. If this tells you that the Java version is 1.7 or higher, everything is fine. If not, the Java version can be set with a command. If you have installed JDK 7, execute:

    export JAVA_HOME=`/usr/libexec/java_home -v 1.7`
    
If you have installed JDK 8, execute:

    export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
    
Note that setting the Java version this way is not permanent. Whenever a new terminal is opened the command needs to be executed again.

Confirm your Java installation and version by executing `java -version`.

**Maven.**
Maven is the build system used to build Spoofax, we require Maven 3.2 or higher. Download links and installation instructions can be found at <http://maven.apache.org/download.cgi>. Maven can be easily installed on OSX with Homebrew by executing `brew install maven`. Confirm the installation and version by running `mvn --version`.

**wget.**
Wget is installed from homebrew with `brew install wget`.

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

If you are developing a project that is included in Spoofax it is recommended to set up Eclipse for Spoofax development to test changes to the project.

**Install Eclipse**

First, [download and install Eclipse](http://www.eclipse.org/downloads/packages/eclipse-standard-44/lunar). Make sure that you are running Java 7 or higher. There are many preferences in Eclipse that should be on by default, but are not for some reason. Go to the Eclipse preferences and enable these options:

* General
	* Keep next/previous editor, view and perspectives dialog open
* General -> Startup and Shutdown
	* Refresh workspace on startup 
* General -> Workspace
	* Refresh using native hooks or polling

**Install m2eclipse plugin**

The m2eclipse plugin runs Maven inside Eclipse. It is required when working on Java components of Spoofax, because Maven manages the dependencies between projects and on third party libraries. If you will never work on Java components of Spoofax, you can skip installing this plugin. Install the m2eclipse plugin into Eclipse from the following update site: <http://download.eclipse.org/technology/m2e/releases>.

After installing the plugin into Eclipse and restarting, go into the Eclipse preferences and click on the `Maven` item. Disable the following checkboxes:

* Do not automatically update dependencies from remote repositories

Enable the following checkboxes:

* Download Artifact Sources
* Download Artifact JavaDoc

Now click on the `Discovery` item and click on `Open Catalog`, a new window will appear where connectors can be installed. Check the following connectors and press Finish:

* buildhelper
* Tycho Configurator
* m2e-jdt-compiler
* m2e-egit

Four Eclipse plugins will be installed which hook Maven plugins into Eclipse. Finish the installation and restart Eclipse. Maven will now run inside Eclipse on projects with the Maven nature. It will automatically resolve dependencies to projects in the workspace and download third party dependencies.

**Setting up for Spoofax development**

There are two ways to set up Eclipse for Spoofax development:

1. Install Spoofax into Eclipse, check out projects that you want to work on, and import them into Eclipse.
2. Check out all projects, build them with Maven, and import them into Eclipse.

The first approach is recommended because it is not possible to build languages inside Eclipse in the second approach, and it also requires less projects to be checked out. If you are not working on languages and want full control over all of Spoofax's components, use the second approach.

*First approach*

Install the nightly Spoofax into Eclipse from update site: <http://download.spoofax.org/update/nightly/>, and restart Eclipse. Clone the <https://github.com/metaborg/spoofax.git> repository and import the `org.strategoxt.imp.runtime` project into Eclipse. Check out any projects you want to work on and import them into Eclipse.

*Second approach*

Check out the spoofax-releng repository: 

```
git clone https://github.com/metaborg/spoofax-releng.git
cd spoofax-releng
git submodule update --init --remote
```

Alternatively, you can check out all repositories yourself for more control. 

Since it is not possible to build languages inside Eclipse (because Spoofax is not installed), the languages have to be built using Maven. Follow the build description at the top of this file to build everything with Maven. 

Now you can work on Java components such as the terms or Stratego interpreter projects. If a language was changed, for example by pulling in changes from git, just run the Maven builds again. The advantage of this approach is that Spoofax is completely built from your Eclipse workspace, without any dependencies on an installed Spoofax version.

**Testing changes**

To test changes to the Spoofax Eclipse plugin, a new Eclipse instance needs to be started. Press the little down arrow next to the bug icon (next to the play icon) and choose `Spoofax (no assertions)` to start a new Eclipse instance that contains your changes. To run with assertions enabled, use the `Spoofax (with assertions)` item, this will also provide more debugging output in the console.

# Adding a new project to the build

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
