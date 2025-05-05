#!/bin/bash

# Variables
DOCKER_USERNAME="siddankthep"
APP_NAME="cashflow-frontend"
TAG="latest"

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
docker build -f deployment/Dockerfile.frontend -t ${IMAGE_NAME} .
check_status "Docker build"

# Step 2: Login to DockerHub
echo "Please ensure you're logged in to DockerHub"
echo "If not, run: docker login"

# Step 3: Push the image to DockerHub
echo "Pushing image to DockerHub..."
docker push ${IMAGE_NAME}
check_status "Docker push"

echo "Successfully built and pushed ${IMAGE_NAME} to DockerHub!"