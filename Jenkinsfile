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
  // Keep last 3 builds, disable concurrent builds, build when /spoofax-trigger job builds.
  properties([
    buildDiscarder(logRotator(numToKeepStr: '3'))
  , disableConcurrentBuilds()
  , pipelineTriggers([upstream(threshold: hudson.model.Result.SUCCESS, upstreamProjects: '/spoofax-trigger')])
  ])
} else {
  // Keep last 3 builds.
  properties([buildDiscarder(logRotator(artifactNumToKeepStr: '3')), disableConcurrentBuilds(), pipelineTriggers([])])
}


node {
  stage('Echo') {
    // Print important variables and versions for debugging purposes.
    echo "Job ${jobName} (base: ${jobBaseName}) on branch ${branchName}"
    exec 'env'
    exec 'bash --version'
    exec 'git --version'
    exec 'python3 --version'
    exec 'pip3 --version'
    exec 'java -version'
    exec 'mvn --version'
  }

  stage('Checkout') {
    // Checkout the revision of the triggered build.
    checkout scm
    // Checkout branch and set to rev, since Jenkins checks out a commit (detached head).
    def rev = exec_stdout('git rev-parse HEAD')
    exec "git checkout ${branchName}"
    exec "git reset --hard ${rev}"
    // Clean repository to ensure a clean build.
    exec 'git clean -ddffxx'
  }

  // Read properties
  def defaultProps = [
    'git.ssh.credential'  : 'git-metaborgbot-ssh'
  , 'maven.config'        : 'metaborg-release-maven-config'
  , 'maven.config.global' : 'metaborg-mirror-global-maven-config'
  ]
  def props = readProperties file: 'jenkins.properties', defaults: defaultProps
  def gitSshCredentials = props['git.ssh.credential']
  def mavenConfigId = props['maven.config']
  def mavenGlobalConfigId = props['maven.config.global']
  def slackChannel = props['slack.channel']

  try {
    stage('Update') {
      if(isTrigger) {
        sshagent([gitSshCredentials]) {
          // Update 'releng' submodule. Must be done first because 'releng' hosts the build script used in the next command.
          exec 'git submodule update --init --remote --recursive -- releng'
          // Update submodules to latest remote.
          exec './b clean-update -y'
        }
      } else {
        // Clean and reset submodules to prevent conflicts from modified files
        exec 'git submodule foreach git clean -ddffxx'
        exec 'git submodule foreach git reset --hard'
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
          // Add all changes to submodules.
          exec("git add \$(grep path .gitmodules | sed 's/.*= //' | xargs)")
          if(!exec_status('git diff --cached --exit-code')) {
            // No changes were added, trigger the build manually without a commit.
            build job: "/metaborg/spoofax-releng/${branchName}", quietPeriod: 60, wait: false
          } else {
            // Commit and push changes to submodule revisions.
            exec("git config user.name metaborgbot")
            exec("git config user.email '<>'")
            exec("git commit --author='metaborgbot <>' -m 'Submodule(s) changed, updating submodule revisions.'")
            sshagent([gitSshCredentials]) {
              exec("git push --set-upstream origin ${branchName}")
            }
          }
        } else {
          echo 'No changes since last trigger'
        }
        // Archive qualifier file for the next trigger build.
        archiveArtifacts artifacts: '.qualifier', onlyIfSuccessful: true
      }
    } else {
      stage('Build and Deploy') {
        def eclipseQualifier = exec_stdout('./b qualifier')
        // Create the build command to run.
        // Disable Gradle native libraries and daemon because they do not work on our buildfarm.
        def command = """
        ./b -p jenkins.properties -p build.properties build all eclipse-instances \
            --eclipse-qualifier ${eclipseQualifier}
        """
        // Get Maven configuration and credentials from provided settings.
        withMaven(mavenSettingsConfig: mavenConfigId, globalMavenSettingsConfig: mavenGlobalConfigId) {
          exec(command)
        }
      }

      stage('Archive') {
        archiveArtifacts artifacts: 'dist/', onlyIfSuccessful: true
      }
    }

    stage('Cleanup') {
      exec 'git clean -ddffxx'
    }
  } catch(org.jenkinsci.plugins.workflow.steps.FlowInterruptedException e) {
    if(e.causes.size() == 0) {
      throw e // No causes, signals abort.
    } else {
      notifyFail(slackChannel)
      throw e
    }
  } catch(hudson.AbortException e) {
    if(e.getMessage().contains('script returned exit code 143')) {
      throw e // Exit code 143 means SIGTERM (process was killed), signals abort.
    } else {
      notifyFail(slackChannel)
      throw e
    }
  } catch(e) {
    notifyFail(slackChannel)
    throw e
  }

  notifySuccess(slackChannel)
}


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

def createMessage(String message) {
  // def durationInMins = Math.round(currentBuild.duration / 1000)
  // "after ${durationInMins} mins"
  return "${env.JOB_NAME} - ${env.BUILD_NUMBER} - ${message} (<${env.BUILD_URL}|Status> <${env.BUILD_URL}console|Console>)"
}
def notifyFail(String channel) {
  if(!channel) {
    return
  }

  def prevBuild = currentBuild.getPreviousBuild()
  if(prevBuild) {
    if('SUCCESS'.equals(prevBuild.getResult())) {
      slackSend channel: channel, color: 'danger', message: createMessage('failed :facepalm:')
    } else {
      slackSend channel: channel, color: 'danger', message: createMessage('still failing :facepalm:')
    }
  } else {
    slackSend channel: channel, color: 'danger', message: createMessage('failed :facepalm:')
  }
}
def notifySuccess(String channel) {
  if(!channel) {
    return
  }

  def prevBuild = currentBuild.getPreviousBuild()
  if(prevBuild && !'SUCCESS'.equals(prevBuild.getResult())) {
    slackSend channel: channel, color: 'good', message: createMessage('fixed :party_parrot:')
  }
}
