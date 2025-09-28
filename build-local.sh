#!/bin/bash

set -e

# Local build script with customizable metadata
# Builds a reusable local image tag and optionally applies a remote tag for publishing

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
    set -a
    # shellcheck disable=SC1091
    source .env.local
    set +a
fi

# Default values (can be overridden via env or CLI)
MAINTAINER_NAME="${MAINTAINER_NAME:-Your Name}"
MAINTAINER_EMAIL="${MAINTAINER_EMAIL:-your.email@example.com}"
VENDOR_NAME="${VENDOR_NAME:-Your Organization}"
IMAGE_VERSION="${IMAGE_VERSION:-1.0.0-local}"
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-}"
GITHUB_USERNAME="${GITHUB_USERNAME:-yourgithub}"
GITHUB_REPO="${GITHUB_REPO:-docker-comfyui-rocm}"
IMAGE_DESCRIPTION="${IMAGE_DESCRIPTION:-ComfyUI with AMD ROCm 6.4.4 support - Lightweight container using host ROCm (Local Build)}"
LOCAL_IMAGE="${LOCAL_IMAGE:-comfyui-rocm:local}"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
VCS_REF=$(git rev-parse HEAD 2>/dev/null || echo "unknown")

show_help() {
    cat <<EOF
Usage: $0 [options]

Options:
  --maintainer-name NAME    Set maintainer name (label)
  --maintainer-email EMAIL  Set maintainer email (label)
  --vendor NAME             Set vendor/organization label
  --version VERSION         Set image version metadata (default: $IMAGE_VERSION)
  --dockerhub-user USER     Apply Docker Hub tag USER/comfyui-rocm:VERSION
  --description DESC        Override image description label
  --local-tag TAG           Override local image tag (default: $LOCAL_IMAGE)
  -h, --help                Show this help message

Environment variables can also be used:
  MAINTAINER_NAME, MAINTAINER_EMAIL, VENDOR_NAME, IMAGE_VERSION,
  DOCKERHUB_USERNAME, IMAGE_DESCRIPTION, GITHUB_USERNAME, GITHUB_REPO,
  LOCAL_IMAGE
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --maintainer-name)
            MAINTAINER_NAME="$2"; shift 2 ;;
        --maintainer-email)
            MAINTAINER_EMAIL="$2"; shift 2 ;;
        --vendor)
            VENDOR_NAME="$2"; shift 2 ;;
        --version)
            IMAGE_VERSION="$2"; shift 2 ;;
        --dockerhub-user)
            DOCKERHUB_USERNAME="$2"; shift 2 ;;
        --description)
            IMAGE_DESCRIPTION="$2"; shift 2 ;;
        --local-tag)
            LOCAL_IMAGE="$2"; shift 2 ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
done

REMOTE_IMAGE=""
if [ -n "$DOCKERHUB_USERNAME" ]; then
    REMOTE_IMAGE="$DOCKERHUB_USERNAME/comfyui-rocm:$IMAGE_VERSION"
fi

IMAGE_URL_ARG=""
if [ -n "$DOCKERHUB_USERNAME" ]; then
    IMAGE_URL_ARG="https://hub.docker.com/r/$DOCKERHUB_USERNAME/comfyui-rocm"
fi

SOURCE_URL_ARG="https://github.com/$GITHUB_USERNAME/$GITHUB_REPO"
DOC_URL_ARG="${SOURCE_URL_ARG}/blob/main/README.md"

echo -e "${YELLOW}📋 Build Configuration:${NC}"
echo "  Maintainer: $MAINTAINER_NAME <$MAINTAINER_EMAIL>"
echo "  Vendor: $VENDOR_NAME"
echo "  Version label: $IMAGE_VERSION"
echo "  Local image tag: $LOCAL_IMAGE"
echo "  Docker Hub tag: ${REMOTE_IMAGE:-<not set>}"
echo "  GitHub Repo: $GITHUB_USERNAME/$GITHUB_REPO"
echo "  Description: $IMAGE_DESCRIPTION"
echo "  Build Date: $BUILD_DATE"
echo "  VCS Ref: $VCS_REF"
echo ""

BUILD_TAGS=(-t "$LOCAL_IMAGE")
if [ -n "$REMOTE_IMAGE" ]; then
    BUILD_TAGS+=(-t "$REMOTE_IMAGE")
fi

echo -e "${BLUE}🐳 Building Docker image: $LOCAL_IMAGE${NC}"
if [ -n "$REMOTE_IMAGE" ]; then
    echo -e "${BLUE}   ↳ Additional tag: $REMOTE_IMAGE${NC}"
fi

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
    --build-arg IMAGE_URL="$IMAGE_URL_ARG" \
    --build-arg SOURCE_URL="$SOURCE_URL_ARG" \
    --build-arg DOCUMENTATION_URL="$DOC_URL_ARG" \
    --build-arg BUILD_DATE="$BUILD_DATE" \
    --build-arg VCS_REF="$VCS_REF" \
    "${BUILD_TAGS[@]}" \
    .

echo -e "${GREEN}✅ Build completed successfully!${NC}"
echo ""
echo -e "${YELLOW}🏷️ Inspecting labels (${LOCAL_IMAGE}):${NC}"
if command -v jq >/dev/null 2>&1; then
    docker inspect "$LOCAL_IMAGE" --format='{{json .Config.Labels}}' | jq -r 'to_entries[] | "\(.key): \(.value)"' | head -15
else
    echo "  (Install jq to pretty-print labels)"
    docker inspect "$LOCAL_IMAGE" --format='{{json .Config.Labels}}'
fi

echo ""
echo -e "${YELLOW}📦 Useful commands:${NC}"
echo "  Run container:   docker compose up -d"
echo "  Inspect labels:  docker inspect $LOCAL_IMAGE | jq '.[0].Config.Labels'"
if [ -n "$REMOTE_IMAGE" ]; then
    echo "  Publish:         docker push $REMOTE_IMAGE"
else
    echo "  Publish:         ./quick-push.sh <dockerhub-user> [tag]"
fi
echo "  Remove image:    docker rmi $LOCAL_IMAGE"
