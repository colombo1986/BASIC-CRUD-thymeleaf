pipeline {
    agent any

    environment {
        IMAGE_NAME = 'gestioneventos' // Nombre de la imagen Docker
        IMAGE_TAG = '1.0'            // Versión de la imagen
    }

    stages {
        stage('Checkout') {
            steps {
                // Clona el repositorio desde GitHub
                git 'https://github.com/colombo1986/BASIC-CRUD-thymeleaf.git'
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

        stage('Docker Build') {
            steps {
                script {
                    // Construye la imagen Docker usando el Dockerfile
                    sh """
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Detener y eliminar cualquier contenedor existente con el mismo nombre
                    sh """
                    docker stop ${IMAGE_NAME} || true
                    docker rm ${IMAGE_NAME} || true
                    """

                    // Ejecutar un nuevo contenedor con la imagen recién creada
                    sh """
                    docker run -d --name ${IMAGE_NAME} -p 8085:8085 ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline ejecutado con éxito. Aplicación desplegada.'
        }
        failure {
            echo 'El pipeline falló. Verifique los logs para más detalles.'
        }
    }
}
