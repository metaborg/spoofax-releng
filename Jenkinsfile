node {
  stage('Check') {
    sh "python3 --version"
    sh "pip3 --version"
    sh "java -version"
    sh "mvn --version"
  }

  stage('Checkout') {
    checkout scm
    sh "git clean -ddffxx"
    sh "git submodule update --init --remote --recursive -- releng"
    sh "./b checkout -y"
    sh "./b update"
  }

  stage('Build and deploy') {
    def mavenLocalRepo = "${env.JENKINS_HOME}/m2repos/${env.EXECUTOR_NUMBER}"
    def command = """
    ./b build all eclipse-instances \
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
    archiveArtifacts artifacts: 'dist/*'
  }
}
