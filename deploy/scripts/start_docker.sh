#!/bin/bash

# ===== LOG FILE =====
exec > /home/ubuntu/start_docker.log 2>&1

echo "===== STARTING DEPLOYMENT ====="

# ===== CONFIG =====
REGION="ap-south-1"
ACCOUNT_ID="266735802734"
REPO_NAME="spotify_hybrid_recsys"
IMAGE_TAG="latest"
CONTAINER_NAME="hybrid_recsys"

ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG"

# ===== LOGIN TO ECR =====
echo "Logging in to ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# ===== PULL IMAGE =====
echo "Pulling Docker image..."
docker pull $ECR_URI

# ===== STOP OLD CONTAINER (IF RUNNING) =====
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Stopping existing container..."
    docker stop $CONTAINER_NAME
fi

# ===== REMOVE OLD CONTAINER =====
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "Removing existing container..."
    docker rm $CONTAINER_NAME
fi

# ===== RUN NEW CONTAINER =====
echo "Starting new container..."
docker run -d -p 8000:8000 --name $CONTAINER_NAME $ECR_URI

echo "===== DEPLOYMENT SUCCESSFUL ====="