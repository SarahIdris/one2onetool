pipeline {  
     agent any
	 parameters {
        string(name: 'DATA_FILE', defaultValue: 'Questions-test.json', description: 'Data file for staging environment')
        string(name: 'RECIPIENT_EMAIL', defaultValue: 'sarah.mdidris@hotmail.com', description: 'Email address to receive notifications')
        string(name: 'GITHUB_REPO_URL', defaultValue: 'https://github.com/sarahidris/one2onetool', description: 'URL of Github repo')
        string(name: 'DOCKER_IMAGE', defaultValue: 'sarahidris/one2onetool-stage', description: 'Name of docker image to create')
        string(name: 'CONTAINER_NAME', defaultValue: 'one2onetool-stage', description: 'Docker container name to run')
	 }
	 triggers {
		githubPush()
	 }
     stages {  
        stage('Clone from Github') {
             steps {
                 git branch: 'staging', url: 'https://github.com/sarahidris/one2onetool'
             }  
        }
        stage('Install npm dependencies') {
             steps {
                 sh 'npm install'
             }  
        }
        stage('Start nodejs unit tests') {
             steps {
                 sh 'npm run test'
             }  
        }
        stage('Build Docker Image') {
            steps {
                script {
                    app = docker.build("${DOCKER_IMAGE}")
                    app.inside {
                        sh 'echo $(curl localhost:3000)'
                    }
                }
            }
        }
        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker_hub_login') {
                        app.push("${env.BUILD_NUMBER}")
                        app.push("latest")
                    }
                }
            }
        }
        stage('Deploy Docker Container') {
            steps {
                    script {
                        sh "docker pull ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                        try {
                            sh "docker stop ${CONTAINER_NAME}"
                            sh "docker rm ${CONTAINER_NAME}"
                            sh "docker image prune -a -f"
                        } catch (err) {
                            echo: 'caught error: $err'
                        }
                        sh "docker run -e DATA_FILE=${DATA_FILE} --restart always --name ${CONTAINER_NAME} -p 3001:3000 -d ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                    }
            }
        }
     }  
	 
     post { 
         success {  
             echo 'Staging branch ran successfully!'  
			 mail bcc: '', body: "<b>Jenkins Job Details</b><br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> Jenkins build url: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "Jenkins job ran successfully. Great Work! :) (Project name: ${env.JOB_NAME})", to: "${RECIPIENT_EMAIL}";  
         }  
         failure {
             echo 'Staging branch has failed. Please check :('  
             mail bcc: '', body: "<b>Jenkins Job Details</b><br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> Jenkins build url: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "Jenkins job has failed. Please check (Project name: ${env.JOB_NAME})", to: "${RECIPIENT_EMAIL}";  
         }  
     }  
}