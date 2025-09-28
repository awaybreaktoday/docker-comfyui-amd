#!/bin/bash

# Multi-architecture build script for Docker Hub
# This builds the image for multiple CPU architectures
# ROCm support currently targets linux/amd64 only; the script keeps
# the buildx flow but defaults to the supported architecture.

set -e

# Load .env.local if it exists
if [ -f .env.local ]; then
    set -a
    source .env.local
    set +a
fi

DOCKERHUB_USERNAME="${1:-$DOCKERHUB_USERNAME}"
IMAGE_NAME="comfyui-rocm"
VERSION="${2:-${IMAGE_VERSION:-latest}}"
PLATFORMS="linux/amd64"

if [ -z "$DOCKERHUB_USERNAME" ]; then
    echo "❌ Usage: ./build-multiarch.sh [dockerhub-username] [version]"
    echo "Example: ./build-multiarch.sh johndoe latest"
    exit 1
fi

echo "🏗️ Building $IMAGE_NAME for Docker Hub (platforms: $PLATFORMS)..."

# Create and use a new builder instance if needed
if ! docker buildx inspect multiarch-builder >/dev/null 2>&1; then
    docker buildx create --name multiarch-builder --bootstrap >/dev/null
fi
docker buildx use multiarch-builder

# Build for multiple architectures and push to Docker Hub
docker buildx build \
    --platform "$PLATFORMS" \
    --tag "$DOCKERHUB_USERNAME/$IMAGE_NAME:$VERSION" \
    --push \
    .

echo "✅ Build complete!"
echo "Architectures: $PLATFORMS"
echo "Available at: $DOCKERHUB_USERNAME/$IMAGE_NAME:$VERSION"
