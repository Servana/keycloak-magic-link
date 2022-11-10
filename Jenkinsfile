Globals = [:]
pipeline {
  agent {
    label 'docker-agent'
  }
  parameters {
    string defaultValue:'keycloak-magic-link', description: 'repo/imageName', name: 'name', trim: true
  }
  options{
    timeout(time:24,unit:'HOURS')
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '5'))
    timestamps()
  }
  environment{
    REPO_NAME="${params.name}"
	DOCKER_REGISTRY="482016542819.dkr.ecr.eu-west-1.amazonaws.com"
	AWS_DEFAULT_REGION="eu-west-1"
  }
  stages {
    stage('Build') {
      steps {
        script{
            gitCommitHash = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
            env.SHORT_COMMIT_HASH = gitCommitHash.take(7)
            echo "Short Commit Hash is ${SHORT_COMMIT_HASH}"

            build(DOCKER_REGISTRY, REPO_NAME, SHORT_COMMIT_HASH)
        }
      }
    }
    stage('PushToRegistry'){
      steps {
        script {
			gitCommitHash = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
            env.SHORT_COMMIT_HASH = gitCommitHash.take(7)
            echo "Short Commit Hash is ${SHORT_COMMIT_HASH}"

            createRepository(REPO_NAME)
            push(DOCKER_REGISTRY, REPO_NAME, SHORT_COMMIT_HASH)
            currentBuild.description = "Current Version is ${SHORT_COMMIT_HASH}"
        }
        deleteDir()
      }
    }
  }
}

def push(dockerRegistry, repoName, version){
    echo "We are about to publish artifacts to remote repository"
    sh """
    set +x
    aws ecr get-login-password --region ${env.AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${dockerRegistry}
    set -x
    docker push ${dockerRegistry}/${repoName}:${version}
    docker push ${dockerRegistry}/${repoName}:latest
    """
}

def build(dockerRegistry, repoName, version){
    echo 'Build docker image'
    RESULT = sh (
            script: "docker build --network host --cache-from ${dockerRegistry}/${repoName}:latest --rm=true . -t ${dockerRegistry}/${repoName}:${version} -t ${dockerRegistry}/${repoName}:latest",
            returnStdout: true
    ).trim()

}


def createRepository(repoName){

  sh """
    aws ecr describe-repositories --repository-names ${repoName} || aws ecr create-repository --repository-name ${repoName}
  """

}


def repositoryExists(repoName){
    if (describeRepository(repoName) == 0) {
        return true
    }else{
        return false
    }
}