# ==========================
# Stage 1: Build Application
# ==========================
FROM maven:3.9.9-eclipse-temurin-21 AS builder

WORKDIR /app

# Copy pom.xml trước để tận dụng cache
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .
RUN chmod +x mvnw

# Download dependencies
# RUN ./mvnw dependency:go-offline
RUN mvn dependency:go-offline

# Copy source code
COPY src src

# Build jar
# RUN ./mvnw clean package -DskipTests
RUN mvn clean package -DskipTests
# ==========================
# Stage 2: Run Application
# ==========================
FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]