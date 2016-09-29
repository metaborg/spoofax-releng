node {
  stage('Checkout') {
    checkout scm

    sh "git clean -ddffxx"

    sh "git submodule update --init --remote --recursive -- releng"
    sh "./b checkout -y"
    sh "./b update"
  }

  stage('Build and deploy') {
    withMaven(
      mavenLocalRepo: "${env.JENKINS_HOME}/m2repos/${env.EXECUTOR_NUMBER}",
      mavenSettingsConfig: 'org.jenkinsci.plugins.configfiles.maven.MavenSettingsConfig1430668968947',
      mavenOpts: '-Xmx2G -Xms2G -Xss16M'
    ) {
      sh "./b build -a dist all eclipse-instances"
    }
  }

  stage('Archive') {
    archiveArtifacts artifacts: 'dist/*'
  }
}
