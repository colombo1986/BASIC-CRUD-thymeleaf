
pipeline {
    agent any

    environment {
        SLACK_CHANNEL = '#aplicacion-de-eventos'
        JOB_NAME = "${env.JOB_NAME}"
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
        BUILD_URL = "${env.BUILD_URL}"
    }
    stages {
        stage('Checkout') {
            steps {
                // Clona el repositorio desde GitHub
                git 'https://github.com/colombo1986/BASIC-CRUD-thymeleaf.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def sonarRunner = tool name: 'SonarQubeScanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                    withSonarQubeEnv('SonarQubeServer') {
                        sh """
                            ${sonarRunner}/bin/sonar-scanner \
                            -Dsonar.projectKey=manage-eventos-app \
                            -Dsonar.java.binaries=target/classes
                        """
                    }
                }
            }
        }



        stage('Build') {
            steps {
                // Compila el proyecto usando Maven
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                // Ejecuta las pruebas unitarias
                sh 'mvn test'
            }
        }

        stage('Package') {
            steps {
                // Empaqueta la aplicación
                sh 'mvn package'
            }
        }

        stage('Deploy') {
            steps {
                // Despliega la aplicación (ajusta según tu entorno)
                sh 'echo "Deploying application..."'
            }
        }

        stage('Upload to Nexus') {
            steps {
                script {
                    nexusArtifactUploader {
                        nexusVersion: 'nexus3'
                        protocol: 'http'
                        nexusUrl: 'http://localhost:8081'
                        groupId: 'com.gestion.productos'
                        version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}"
                        repository: 'mvn-repository'
                        credentialsId: 'Nexus_Password'
                        artifacts: [
                            [
                                artifactId: 'mi-artefacto',
                                classifier: '',
                                file: 'target/nombre-del-artefacto.jar',
                                type: 'jar'
                            ]
                        ]
                    }
                }

            }
        }

    }



post {
        success {
            slackSend(channel: env.SLACK_CHANNEL,
                      color: 'good',
                      message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' succeeded. Check it out: ${env.BUILD_URL}",
                      tokenCredentialId: env.SLACK_CREDENTIAL_ID)
        }
        failure {
            slackSend(channel: env.SLACK_CHANNEL,
                      color: 'danger',
                      message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' failed. Check it out: ${env.BUILD_URL}",
                      tokenCredentialId: env.SLACK_CREDENTIAL_ID)
        }
        unstable {
            slackSend(channel: env.SLACK_CHANNEL,
                      color: 'warning',
                      message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' is unstable. Check it out: ${env.BUILD_URL}",
                      tokenCredentialId: env.SLACK_CREDENTIAL_ID)
        }
        always {
            slackSend(channel: env.SLACK_CHANNEL,
                      color: '#FFFF00',
                      message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' completed. Check it out: ${env.BUILD_URL}",
                      tokenCredentialId: env.SLACK_CREDENTIAL_ID)
        }
    }

}