
pipeline {
    agent any

    environment {
        SLACK_CHANNEL = '#aplicacion-de-eventos'
        JOB_NAME = "${env.JOB_NAME}"
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
        BUILD_URL = "${env.BUILD_URL}"
        NEXUS_VERSION = "nexus3"
        // This can be http or https
        NEXUS_PROTOCOL = "http"
        // Where your Nexus is running
        NEXUS_URL = "localhost:8081"
        // Repository where we will upload the artifact
        NEXUS_REPOSITORY = "mvn-repository"
        // Jenkins credential id to authenticate to Nexus OSS
        NEXUS_CREDENTIAL_ID = "Nexus_Password"
        ARTIFACT_VERSION = "${env.BUILD_NUMBER}"
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

                 pom = readMavenPom file: "pom.xml";
                    // Find built artifact under target folder
                 filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
                    // Print some info from the artifact found
                 echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length} ${filesByGlob[0].lastModified}"
                    // Extract the path from the File found
                 artifactPath = filesByGlob[0].path;
                    // Assign to a boolean response verifying If the artifact name exists
                 artifactExists = fileExists artifactPath;

                 if(artifactExists) {
                        echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";

                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: ARTIFACT_VERSION,
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                // Artifact generated such as .jar, .ear and .war files.
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: artifactPath,
                                type: pom.packaging]
                            ]
                        );

                    } else {
                        error "*** File: ${artifactPath}, could not be found";
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