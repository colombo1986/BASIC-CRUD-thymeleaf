# Etapa 1: Construcción
FROM maven:3.9.5-eclipse-temurin-17 AS builder

# Establecer el directorio de trabajo en el contenedor
WORKDIR /app

# Copiar los archivos de configuración y de proyecto
COPY pom.xml ./
COPY src ./src

# Construir el proyecto y empaquetarlo como un JAR ejecutable
RUN mvn clean package -DskipTests

# Etapa 2: Ejecución
FROM eclipse-temurin:17-jre

# Establecer el directorio de trabajo en el contenedor
WORKDIR /app

# Copiar el JAR construido en la etapa 1
COPY --from=builder /app/target/*.jar app.jar

# Exponer el puerto que usará la aplicación
EXPOSE 8085