# Stage 1: Build the application using Maven with Java 17
FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /app

# Copy the Maven project files from the backend directory
COPY backend/cashflow/pom.xml .
COPY backend/cashflow/mvnw .
COPY backend/cashflow/.mvn .mvn
COPY backend/cashflow/src ./src

# Ensure the Maven wrapper has execute permissions
RUN chmod +x mvnw

# Build the project (skip tests if desired)
RUN ls -la
RUN ./mvnw clean package -DskipTests

# Stage 2: Create the runtime image
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app

# Copy the built jar from the previous stage
COPY --from=build /app/target/cashflow-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
