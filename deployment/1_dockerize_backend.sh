#!/bin/bash

# Variables - replace these with your actual values
DOCKER_USERNAME="siddankthep"
APP_NAME="cashflow-backend"
TAG="latest"  # You can modify this to use a specific version like "v1.0.0"

# Full image name with username/repository:tag
IMAGE_NAME="${DOCKER_USERNAME}/${APP_NAME}:${TAG}"

# Function to check if command was successful
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed"
        exit 1
    fi
}

# Step 1: Build the Docker image
echo "Building Docker image..."
docker build -f deployment/Dockerfile.backend -t ${IMAGE_NAME} .
check_status "Docker build"

# Step 2: Login to DockerHub (make sure you're logged in or have credentials configured)
echo "Please ensure you're logged in to DockerHub"
echo "If not, run: docker login"
# Uncomment the next line and replace with your credentials if you want automated login
# docker login -u ${DOCKER_USERNAME} -p "your_password"

# Step 3: Push the image to DockerHub
echo "Pushing image to DockerHub..."
docker push ${IMAGE_NAME}
check_status "Docker push"

echo "Successfully built and pushed ${IMAGE_NAME} to DockerHub!"