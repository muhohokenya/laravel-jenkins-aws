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
                 sh 'cd '
            }
        }
        stage("Clear all running docker containers") {
            steps {
                script {
                    try {
                        sh 'sudo -S docker rm -f $(docker ps -a -q)'
                    } catch (Exception e) {
                        echo 'No running container to clear up...'
                    }
                }
            }
        }

        stage("Start Docker") {
            steps {
                sh 'sudo -S docker-compose ps'
            }
        }
        stage("Run Composer Install") {
            steps {
                sh 'sudo -S docker-compose run --rm composer install'
            }
        }
    }
    post {
        success {
            sh 'cd "/var/lib/jenkins/workspace/LaravelTest"'
            sh 'rm -rf artifact.zip'
            sh 'zip -r artifact.zip . -x "*node_modules**"'
            withCredentials([sshUserPrivateKey(credentialsId: "aws-ec2", keyFileVariable: 'keyfile')]) {
                sh 'scp -v -o StrictHostKeyChecking=no -i ${keyfile} /var/lib/jenkins/workspace/LaravelTest/artifact.zip ec2-user@13.40.116.143:/home/ec2-user/artifact'
            }
            sshagent(credentials: ['aws-ec2']) {
                sh 'ssh -o StrictHostKeyChecking=no ec2-user@13.40.116.143 unzip -o /home/ec2-user/artifact/artifact.zip -d /var/www/html'
                script {
                    try {
                        sh 'ssh -o StrictHostKeyChecking=no ec2-user@13.40.116.143 sudo chmod 777 /var/www/html/storage -R'
                    } catch (Exception e) {
                        echo 'Some file permissions could not be updated.'
                    }
                }
            }
        }
        always {
            sh 'docker compose down --remove-orphans -v'
            sh 'docker compose ps'
        }
    }
}