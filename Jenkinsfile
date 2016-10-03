node {
  stage('Check') {
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

  stage('Build and Deploy') {
    def eclipseQualifier = (sh script: './b qualifier', returnStdout : true).trim()
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
