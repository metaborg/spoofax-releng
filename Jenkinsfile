// Utility functions.
def exec_stdout(String cmd) {
  return sh(script: cmd, returnStdout : true).trim()
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

// env.JOB_BASE_NAME returns the wrong name: parse our own.
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
def isTrigger = jobBaseName == 'spoofax-trigger-check'


node {
  stage('Check') {
    echo "Job ${jobName} (base: ${jobBaseName}) on branch ${branchName}"
    exec 'bash --version'
    exec 'python3 --version'
    exec 'pip3 --version'
    exec 'java -version'
    exec 'mvn --version'
  }

  stage('Update') {
    checkout scm

    // Checkout branch and set to rev, since Jenkins checks out a commit (detached head).
    def rev = exec_stdout('git rev-parse HEAD')
    exec "git checkout ${branchName}"
    exec "git reset --hard ${rev}"

    exec 'git clean -ddffxx'
    exec 'git submodule update --init --remote --recursive -- releng'
    exec './b clean-update -y'
  }

  if(isTrigger) {
    stage('Trigger') {
      step([$class: 'CopyArtifact', filter: '.qualifier', projectName: jobName, optional: true])
      def newQualifier = exec_stdout('./b changed')
      if(newQualifier) {
        def command = """
        git add \$(grep path .gitmodules | sed 's/.*= //' | xargs)
        git commit --author="metaborgbot <>" -m "Build farm build for qualifier ${newQualifier} started, updating submodule revisions."
        git push --set-upstream origin ${branchName}
        """
        sshagent(['bc1d3314-2ab4-4b64-b46e-11f0030fecc1']) {
          // Allow failure of commit and push, could happen if something was pushed in between.
          exec_canfail(command)
        }
        build job: "../spoofax/${branchName}", wait: false
      }
    }
  } else {
    stage('Build and Deploy') {
      def eclipseQualifier = exec_stdout('./b qualifier')
      def mavenLocalRepo = "${env.JENKINS_HOME}/m2repos/${env.EXECUTOR_NUMBER}"
      def command = """
      ./b build all eclipse-instances \
          --eclipse-qualifier ${eclipseQualifier} \
          --stratego-build \
          --stratego-no-tests \
          --copy-artifacts 'dist' \
          --maven-local-repo '${mavenLocalRepo}' \
          --maven-deploy \
          --maven-deploy-identifier 'metaborg-nexus' \
          --maven-deploy-url 'http://artifacts.metaborg.org/content/repositories/snapshots/' \
          --gradle-no-native \
          --gradle-no-daemon
      """
      withMaven(mavenSettingsConfig: 'org.jenkinsci.plugins.configfiles.maven.MavenSettingsConfig1430668968947') {
        exec(command)
      }
    }

    stage('Archive') {
      archiveArtifacts artifacts: 'dist/', excludes: null, onlyIfSuccessful: true
    }
  }
}
