pipeline {
    agent any
    stages {
        stage("whoami") {
            steps {
                sh 'whoami'
            }
        }


        stage("Verify SSH connection to server") {
            steps {
                sshagent(credentials:['php-server-id']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ec2-user@44.205.190.83
                    '''
            }
                }
        }

        //try build

        stage("List all files"){
            steps{
                 sh 'docker ps'
            }
        }
        stage("Clear all running docker containers") {
            steps {
                script {
                    try {
                        sh 'docker rm -f $(docker ps -a -q)'
                    } catch (Exception e) {
                        echo 'No running container to clear up...'
                    }
                }
            }
        }

        stage("Start Docker") {
            steps {
                sh 'docker-compose ps'
            }
        }
        // stage("Run Composer Install") {
        //     steps {
        //         sh 'docker-compose run --rm composer install'
        //     }
        // }
    }

}