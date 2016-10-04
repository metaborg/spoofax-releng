// Utility functions.
def exec_stdout(String cmd) {
  try {
    return sh(script: cmd, returnStdout : true).trim()
  } catch(hudson.AbortException ae) {
    // Exit code 143 means SIGTERM (process was killed). These must be propagated.
    if(ae.getMessage().contains('script returned exit code 143')) {
      throw ae
    } else {
      // Return empty string, which also evaluates to false.
      return ''
    }
  }
}
def exec_status(String cmd) {
  return sh(script: cmd, returnStatus: true)
}
def exec_canfail(String cmd) {
  sh(script: cmd, returnStatus: true)
}
def exec(String cmd) {
  sh(script: cmd)
}

// Jenkins' env.JOB_BASE_NAME returns the wrong name: parse our own.
def jobName = env.JOB_NAME
def jobBaseSlashPos = jobName.indexOf('/')
String jobBaseName
if(jobBaseSlashPos != -1) {
  jobBaseName = jobName.substring(0, jobBaseSlashPos)
} else {
   jobBaseName = jobName
}
def branchName = env.BRANCH_NAME

// Determine if this is the trigger job, or a regular build job.
// The trigger job checks for changes, pushes a commit with updated submodule revisions, and triggers the regular build.
// The regular job builds and deploys Spoofax.
def isTrigger = jobBaseName == 'spoofax-trigger-check'


if(isTrigger) {
  // Keep last 2 builds, disable concurrent builds.
  properties([buildDiscarder(logRotator(numToKeepStr: '2')), disableConcurrentBuilds(), pipelineTriggers([])])
} else {
  // Keep last 5 builds.
  properties([buildDiscarder(logRotator(numToKeepStr: '5')), pipelineTriggers([])])
}

node {
  // Read properties
  def defaultProps = [
    'git.ssh.credential'    : 'bc1d3314-2ab4-4b64-b46e-11f0030fecc1'
  , 'maven.config.provided' : 'org.jenkinsci.plugins.configfiles.maven.MavenSettingsConfig1430668968947'
  ]
  def props = readProperties file: 'jenkins.properties', defaults: defaultProps
  def gitSshCredentials = props['git.ssh.credential']
  def mavenConfigProvided = props['maven.config.provided']

  stage('Check') {
    // Print important variables and versions for debugging purposes.
    echo "Job ${jobName} (base: ${jobBaseName}) on branch ${branchName}"
    exec 'bash --version'
    exec 'python3 --version'
    exec 'pip3 --version'
    exec 'java -version'
    exec 'mvn --version'
  }

  stage('Update') {
    // Checkout the revision of the triggered build.
    checkout scm
    // Checkout branch and set to rev, since Jenkins checks out a commit (detached head).
    def rev = exec_stdout('git rev-parse HEAD')
    exec "git checkout ${branchName}"
    exec "git reset --hard ${rev}"
    // Clean repository to ensure a clean build.
    exec 'git clean -ddffxx'
    if(isTrigger) {
      sshagent([gitSshCredentials]) {
        // Update 'releng' submodule. Must be done first because 'releng' hosts the build script used in the next command.
        exec 'git submodule update --init --remote --recursive -- releng'
        // Switch to SSH remotes.
        exec './b set-remote -s'
        // Update submodules to latest remote.
        exec './b clean-update -y'
      }
    } else {
      // Checkout submodules to stored revisions. Commit from trigger will have moved submodules forward.
      exec 'git submodule update --init --checkout --recursive'
    }
  }

  if(isTrigger) {
    stage('Trigger') {
      // Recover previous qualifier file to check if something has changed.
      step([$class: 'CopyArtifact', filter: '.qualifier', projectName: jobName, optional: true])
      // Check if changes have occurred. newQualifier is empty if there are no changes, which is false in Groovy.
      def newQualifier = exec_stdout('./b changed')
      if(newQualifier) {
        echo "Changes occurred since last trigger. New qualifier: ${newQualifier}"
        // Commit and push changes to submodule revisions.
        def command = """
        git add \$(grep path .gitmodules | sed 's/.*= //' | xargs)
        git commit --author="metaborgbot <>" -m "Build farm build for qualifier ${newQualifier} started, updating submodule revisions."
        git push --set-upstream origin ${branchName}
        """
        sshagent([gitSshCredentials]) {
          exec(command)
        }
        // Trigger a build of Spoofax. Quiet period of 2 minutes to group multiple changes into a single build.
        build job: "../spoofax/${branchName}", quietPeriod: 120, wait: false
      } else {
        echo 'No changes since last trigger'
      }
      // Archive qualifier file for the next trigger build.
      archiveArtifacts artifacts: '.qualifier', onlyIfSuccessful: true
    }
  } else {
    stage('Build and Deploy') {
      def eclipseQualifier = exec_stdout('./b qualifier')
      // Set the local Maven repository to an executor-local directory, to prevent concurrent build issues.
      def mavenLocalRepo = "${env.JENKINS_HOME}/m2repos/${env.EXECUTOR_NUMBER}"
      // Create the build command to run.
      // Disable Gradle native libraries and daemon because they do not work on our buildfarm.
      def command = """
      ./b build all eclipse-instances \
          --eclipse-qualifier ${eclipseQualifier} \
          --stratego-build \
          --stratego-no-tests \
          --copy-artifacts 'dist' \
          --maven-local-repo '${mavenLocalRepo}' \
          --gradle-no-native \
          --gradle-no-daemon
      """
      // Get Maven configuration and credentials from provided settings.
      withMaven(mavenSettingsConfig: mavenConfigProvided) {
        exec(command)
      }
    }

    stage('Archive') {
      archiveArtifacts artifacts: 'dist/', onlyIfSuccessful: true
    }
  }
}
