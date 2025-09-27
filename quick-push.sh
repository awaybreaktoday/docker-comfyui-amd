#!/bin/bash

# Quick Docker Hub push script
# Usage: ./quick-push.sh [your-dockerhub-username] [optional-version-tag]

# Load .env.local if it exists
if [ -f .env.local ]; then
    set -a
    source .env.local
    set +a
fi

DOCKERHUB_USERNAME="${1:-$DOCKERHUB_USERNAME}"
VERSION_TAG="${2:-${IMAGE_VERSION:-latest}}"
IMAGE_NAME="comfyui-rocm"

if [ -z "$DOCKERHUB_USERNAME" ]; then
    echo "❌ Usage: ./quick-push.sh [your-dockerhub-username] [optional-version-tag]"
    echo "Example: ./quick-push.sh johndoe"
    echo "Example: ./quick-push.sh johndoe v1.0"
    exit 1
fi

FULL_IMAGE_NAME="$DOCKERHUB_USERNAME/$IMAGE_NAME"

echo "🏗️  Building and pushing $FULL_IMAGE_NAME:$VERSION_TAG"

# Build
docker build -t "$FULL_IMAGE_NAME:$VERSION_TAG" .

# Login if needed
docker login

# Push
docker push "$FULL_IMAGE_NAME:$VERSION_TAG"

echo "✅ Done! Image available at: $FULL_IMAGE_NAME:$VERSION_TAG"
