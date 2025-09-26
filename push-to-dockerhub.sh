#!/bin/bash

# ComfyUI AMD ROCm Docker Hub Push Script
# Replace YOUR_DOCKERHUB_USERNAME with your actual Docker Hub username

# Configuration - EDIT THESE VARIABLES
DOCKERHUB_USERNAME="YOUR_DOCKERHUB_USERNAME"  # Replace with your Docker Hub username
IMAGE_NAME="comfyui-rocm"
VERSION="latest"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 ComfyUI AMD ROCm Docker Hub Push Script${NC}"
echo "=================================================="

# Check if username is set
if [ "$DOCKERHUB_USERNAME" = "YOUR_DOCKERHUB_USERNAME" ]; then
    echo -e "${RED}❌ Error: Please edit this script and set your Docker Hub username${NC}"
    echo "Edit the DOCKERHUB_USERNAME variable at the top of this script"
    exit 1
fi

# Full image name
FULL_IMAGE_NAME="$DOCKERHUB_USERNAME/$IMAGE_NAME"

echo -e "${YELLOW}📋 Configuration:${NC}"
echo "  Docker Hub Username: $DOCKERHUB_USERNAME"
echo "  Image Name: $IMAGE_NAME"
echo "  Full Image Tag: $FULL_IMAGE_NAME:$VERSION"
echo ""

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Error: Docker is not running${NC}"
    exit 1
fi

# Build the image
echo -e "${BLUE}🏗️  Building Docker image...${NC}"
docker build -t "$FULL_IMAGE_NAME:$VERSION" .

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error: Docker build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build completed successfully${NC}"

# Tag with additional version if specified
if [ -n "$2" ]; then
    VERSION_TAG="$2"
    echo -e "${BLUE}🏷️  Tagging with version: $VERSION_TAG${NC}"
    docker tag "$FULL_IMAGE_NAME:$VERSION" "$FULL_IMAGE_NAME:$VERSION_TAG"
fi

# Check if already logged in to Docker Hub
echo -e "${BLUE}🔐 Checking Docker Hub authentication...${NC}"
if ! docker info | grep -q "Username:"; then
    echo -e "${YELLOW}🔑 Please log in to Docker Hub:${NC}"
    docker login
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error: Docker Hub login failed${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Already logged in to Docker Hub${NC}"
fi

# Push the image
echo -e "${BLUE}📤 Pushing image to Docker Hub...${NC}"
docker push "$FULL_IMAGE_NAME:$VERSION"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error: Docker push failed${NC}"
    exit 1
fi

# Push version tag if it exists
if [ -n "$2" ]; then
    echo -e "${BLUE}📤 Pushing version tag: $VERSION_TAG${NC}"
    docker push "$FULL_IMAGE_NAME:$VERSION_TAG"
fi

echo ""
echo -e "${GREEN}🎉 Success! Image pushed to Docker Hub${NC}"
echo "=================================================="
echo -e "${YELLOW}📋 Image Details:${NC}"
echo "  Repository: https://hub.docker.com/r/$DOCKERHUB_USERNAME/$IMAGE_NAME"
echo "  Pull command: docker pull $FULL_IMAGE_NAME:$VERSION"
echo ""
echo -e "${YELLOW}🚀 To use this image on another machine:${NC}"
echo "  docker run -it \\"
echo "    --cap-add=SYS_PTRACE \\"
echo "    --security-opt seccomp=unconfined \\"
echo "    --device=/dev/kfd --device=/dev/dri \\"
echo "    --group-add video --group-add render \\"
echo "    --ipc=host --shm-size 8G \\"
echo "    -p 8188:8188 \\"
echo "    -v /opt/rocm:/opt/rocm:ro \\"
echo "    $FULL_IMAGE_NAME:$VERSION"
echo ""
echo -e "${BLUE}💡 Tip: Create a new docker-compose.yml on the target machine using this image${NC}"
