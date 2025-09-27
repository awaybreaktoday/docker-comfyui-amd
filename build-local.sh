#!/bin/bash

# Local build script with customizable metadata
# This script allows you to build locally with the same metadata structure as GitHub Actions

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏗️ Local Build with Custom Metadata${NC}"
echo "================================================"

# Load .env.local if it exists
if [ -f .env.local ]; then
    echo -e "${GREEN}📁 Loading configuration from .env.local${NC}"
    set -a  # automatically export all variables
    source .env.local
    set +a  # turn off automatic export
fi

# Default values (can be overridden with environment variables or arguments)
MAINTAINER_NAME="${MAINTAINER_NAME:-Your Name}"
MAINTAINER_EMAIL="${MAINTAINER_EMAIL:-your.email@example.com}"
VENDOR_NAME="${VENDOR_NAME:-Your Organization}"
IMAGE_VERSION="${IMAGE_VERSION:-1.0.0-local}"
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-yourusername}"
GITHUB_USERNAME="${GITHUB_USERNAME:-yourgithub}"
GITHUB_REPO="${GITHUB_REPO:-docker-comfyui-amd}"
IMAGE_DESCRIPTION="${IMAGE_DESCRIPTION:-ComfyUI with AMD ROCm 6.4.4 support - Lightweight container using host ROCm (Local Build)}"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
VCS_REF=$(git rev-parse HEAD 2>/dev/null || echo "unknown")

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --maintainer-name)
            MAINTAINER_NAME="$2"
            shift 2
            ;;
        --maintainer-email)
            MAINTAINER_EMAIL="$2"
            shift 2
            ;;
        --vendor)
            VENDOR_NAME="$2"
            shift 2
            ;;
        --version)
            IMAGE_VERSION="$2"
            shift 2
            ;;
        --dockerhub-user)
            DOCKERHUB_USERNAME="$2"
            shift 2
            ;;
        --description)
            IMAGE_DESCRIPTION="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --maintainer-name NAME    Set maintainer name"
            echo "  --maintainer-email EMAIL  Set maintainer email"
            echo "  --vendor NAME             Set vendor/organization name"
            echo "  --version VERSION         Set image version"
            echo "  --dockerhub-user USER     Set Docker Hub username"
            echo "  --description DESC        Set image description"
            echo "  -h, --help               Show this help message"
            echo ""
            echo "Environment variables can also be used:"
            echo "  MAINTAINER_NAME, MAINTAINER_EMAIL, VENDOR_NAME,"
            echo "  IMAGE_VERSION, DOCKERHUB_USERNAME, IMAGE_DESCRIPTION"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${YELLOW}📋 Build Configuration:${NC}"
echo "  Maintainer: $MAINTAINER_NAME <$MAINTAINER_EMAIL>"
echo "  Vendor: $VENDOR_NAME"
echo "  Version: $IMAGE_VERSION"
echo "  Docker Hub User: $DOCKERHUB_USERNAME"
echo "  GitHub Repo: $GITHUB_USERNAME/$GITHUB_REPO"
echo "  Description: $IMAGE_DESCRIPTION"
echo "  Build Date: $BUILD_DATE"
echo "  VCS Ref: $VCS_REF"
echo ""

# Image name
IMAGE_NAME="$DOCKERHUB_USERNAME/comfyui-rocm:$IMAGE_VERSION"

echo -e "${BLUE}🐳 Building Docker image: $IMAGE_NAME${NC}"

# Build the image with all the custom metadata
docker build -f Dockerfile.cloudbuild \
    --build-arg PYTORCH_VERSION=2.7.1 \
    --build-arg ROCM_VERSION=6.4 \
    --build-arg UBUNTU_VERSION=24.04 \
    --build-arg MAINTAINER_NAME="$MAINTAINER_NAME" \
    --build-arg MAINTAINER_EMAIL="$MAINTAINER_EMAIL" \
    --build-arg VENDOR_NAME="$VENDOR_NAME" \
    --build-arg IMAGE_VERSION="$IMAGE_VERSION" \
    --build-arg DOCKERHUB_USERNAME="$DOCKERHUB_USERNAME" \
    --build-arg GITHUB_USERNAME="$GITHUB_USERNAME" \
    --build-arg GITHUB_REPO="$GITHUB_REPO" \
    --build-arg IMAGE_DESCRIPTION="$IMAGE_DESCRIPTION" \
    --build-arg IMAGE_URL="https://hub.docker.com/r/$DOCKERHUB_USERNAME/comfyui-rocm" \
    --build-arg SOURCE_URL="https://github.com/$GITHUB_USERNAME/$GITHUB_REPO" \
    --build-arg DOCUMENTATION_URL="https://github.com/$GITHUB_USERNAME/$GITHUB_REPO/blob/main/README.md" \
    --build-arg BUILD_DATE="$BUILD_DATE" \
    --build-arg VCS_REF="$VCS_REF" \
    -t "$IMAGE_NAME" \
    .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}🏷️ Inspecting labels:${NC}"
    docker inspect "$IMAGE_NAME" --format='{{json .Config.Labels}}' | jq -r 'to_entries[] | "\(.key): \(.value)"' | head -15
    echo ""
    echo -e "${YELLOW}📦 Available commands:${NC}"
    echo "  Run container:   docker run -it --device=/dev/kfd --device=/dev/dri -v /opt/rocm:/opt/rocm:ro -p 8188:8188 $IMAGE_NAME"
    echo "  Push to hub:     docker push $IMAGE_NAME"
    echo "  Inspect labels:  docker inspect $IMAGE_NAME | jq '.[0].Config.Labels'"
    echo "  Remove image:    docker rmi $IMAGE_NAME"
else
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi
