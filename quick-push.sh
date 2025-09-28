#!/bin/bash

# Quick Docker Hub push script
# Re-tags the local build and pushes without rebuilding the image
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
LOCAL_IMAGE="${LOCAL_IMAGE:-comfyui-rocm:local}"

if [ -z "$DOCKERHUB_USERNAME" ]; then
    echo "❌ Usage: ./quick-push.sh [your-dockerhub-username] [optional-version-tag]"
    echo "Example: ./quick-push.sh johndoe"
    echo "Example: ./quick-push.sh johndoe v1.0"
    exit 1
fi

FULL_IMAGE_NAME="$DOCKERHUB_USERNAME/$IMAGE_NAME"
TARGET_IMAGE="$FULL_IMAGE_NAME:$VERSION_TAG"

echo "🚀 Preparing to push $TARGET_IMAGE (from $LOCAL_IMAGE)"

if ! docker image inspect "$LOCAL_IMAGE" >/dev/null 2>&1; then
    echo "❌ Local image $LOCAL_IMAGE not found. Run ./build-local.sh first."
    exit 1
fi

docker tag "$LOCAL_IMAGE" "$TARGET_IMAGE"

# Login if needed
docker login

# Push
docker push "$TARGET_IMAGE"

echo "✅ Done! Image available at: $TARGET_IMAGE"
