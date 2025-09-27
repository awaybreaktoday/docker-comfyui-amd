#!/bin/bash

# Multi-architecture build script for Docker Hub
# This builds the image for multiple CPU architectures

# Load .env.local if it exists
if [ -f .env.local ]; then
    set -a
    source .env.local
    set +a
fi

DOCKERHUB_USERNAME="${1:-$DOCKERHUB_USERNAME}"
IMAGE_NAME="comfyui-rocm"
VERSION="${2:-${IMAGE_VERSION:-latest}}"

if [ -z "$DOCKERHUB_USERNAME" ]; then
    echo "❌ Usage: ./build-multiarch.sh [dockerhub-username] [version]"
    echo "Example: ./build-multiarch.sh johndoe latest"
    exit 1
fi

echo "🏗️ Building multi-architecture image for Docker Hub..."

# Create and use a new builder instance
docker buildx create --name multiarch-builder --use

# Build for multiple architectures and push to Docker Hub
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag "$DOCKERHUB_USERNAME/$IMAGE_NAME:$VERSION" \
    --push \
    .

echo "✅ Multi-architecture build complete!"
echo "Architectures: linux/amd64, linux/arm64"
echo "Available at: $DOCKERHUB_USERNAME/$IMAGE_NAME:$VERSION"
