pipeline {
    environment {
    registry = "mdidris/one2onetool"
    registryCredential = 'dockerHub'
    dockerImage = ''
    }

    agent any
	parameters {
        string(name: 'DATA_FILE', defaultValue: 'Questions-test.json', description: 'Data file for staging environment')
        string(name: 'RECIPIENT_EMAIL', defaultValue: 'sarah.mdidris@hotmail.com', description: 'Email address to receive notifications')
        string(name: 'GITHUB_REPO_URL', defaultValue: 'https://github.com/SarahIdris/one2onetool', description: 'URL of Github repo')
        string(name: 'DOCKER_IMAGE', defaultValue: 'SarahIdris/one2onetool-stage', description: 'Name of docker image to create')
        string(name: 'CONTAINER_NAME', defaultValue: 'one2onetool-stage', description: 'Docker container name to run')
	 }
	 triggers {
		githubPush()
	 }
	
    stages {  
        stage('Clone from Github') {
             steps {
                 git branch: 'staging', url: 'https://github.com/SarahIdris/one2onetool'
             }  
        }
        stage('Building Docker Image') {
                steps {
                    script {
                        dockerImage = docker.build registry + ":$BUILD_NUMBER"
                    }
                }
            }
        stage('Deploying Docker Image to Dockerhub') {
                steps {
                    script {
                        docker.withRegistry('', registryCredential) {
                         app.push("${env.BUILD_NUMBER}")
                         app.push("latest")
                        }
                    }
                }
            }
        stage('Deploy Docker Container') {
            steps {
                    script {
                        bat "docker pull ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                        try {
                            bat "docker stop ${CONTAINER_NAME}"
                            bat "docker rm ${CONTAINER_NAME}"
                            bat "docker image prune -a -f"
                        } catch (err) {
                            echo: 'caught error: $err'
                        }
                        bat "docker run -e DATA_FILE=${DATA_FILE} --restart always --name ${CONTAINER_NAME} -p 3001:3000 -d ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
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
}