node {
  stage('Check') {
    sh 'bash --version'
    sh 'python3 --version'
    sh 'pip3 --version'
    sh 'java -version'
    sh 'mvn --version'
  }

  stage('Update') {
    checkout scm
    sh 'git reset --hard'
    sh 'git clean -ddffxx'
    sh 'git submodule update --init --remote --recursive -- releng'
    sh './b clean-update -y'
  }

  if(env.JOB_BASE_NAME == 'spoofax-trigger-check') {
    stage('Trigger') {
      step([$class: 'CopyArtifact', filter: '.qualifier', projectName: env.JOB_NAME])
      def newQualifier = sh(script: './b changed', returnStdout : true).trim()
      if(newQualifier) {
        def command = """
        git add \$(grep path .gitmodules | sed 's/.*= //' | xargs)
        git commit --author="metaborgbot <>" -m "Build farm build for qualifier ${newQualifier} started, updating submodule revisions."
        git push --set-upstream origin ${env.BRANCH_NAME}
        """
        sshagent(['bc1d3314-2ab4-4b64-b46e-11f0030fecc1']) {
          sh returnStatus: true, script: command
        }
        build job: "../../spoofax/${env.BRANCH_NAME}", wait: false
      }
    }
  } else {
    stage('Build and Deploy') {
      def eclipseQualifier = sh(script: './b qualifier', returnStdout : true).trim()
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
        sh command
      }
    }

    stage('Archive') {
      archiveArtifacts artifacts: 'dist/', excludes: null, onlyIfSuccessful: true
    }
  }
}
