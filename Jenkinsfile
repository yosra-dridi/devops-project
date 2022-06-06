pipeline {
    agent any

    environment {
        COMMITHASH = getVersion()
    }

    stages {
        stage('Build') {
            steps {
                dir('applications/microservice') {
                    sh 'docker build . -t python-microservice'
                }
                // sh 'cd applications/microservice; docker build . -t python-microservice'
            }
        }

        stage ('Unit Test') {
            steps {
                sh 'docker run python-microservice pytest -v'
            }
        }

        stage ('Push Build') {
            steps {
                sh "docker tag python-microservice 1k3tv1nay/python-microservice:${COMMITHASH}"
                withCredentials([usernamePassword(credentialsId: 'dockercred', passwordVariable: 'docker_password', usernameVariable: 'docker_username')]) {
                    sh "docker login -u ${docker_username} -p ${docker_password}"
                    sh "docker push 1k3tv1nay/python-microservice:${COMMITHASH}"
                }
            }
        }

        stage ('Deploy server') {
            steps {
                ansiblePlaybook credentialsId: 'application-server',
                                disableHostKeyChecking: true,
                                installation: 'ansible',
                                inventory: 'ansible/app-inventory',
                                playbook: 'ansible/deploy-microservice.yml',
                                extras: "-e COMMITHASH=${COMMITHASH}"
            }
        }
    }
}

def getVersion(){
    def commithash = sh returnStdout: true, script: 'git rev-parse --short HEAD'
    return commithash
}
