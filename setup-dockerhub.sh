#!/bin/bash

# Docker Hub paid account setup script
# This script helps configure your Docker Hub repository for optimal automated builds

echo "🌟 Docker Hub Paid Account Configuration"
echo "========================================"

# Load .env.local if it exists
if [ -f .env.local ]; then
    set -a
    source .env.local
    set +a
fi

# Configuration variables
DOCKERHUB_USERNAME="${1:-${DOCKERHUB_USERNAME:-YOUR_DOCKERHUB_USERNAME}}"
REPO_NAME="comfyui-rocm"
GITHUB_USERNAME="${2:-${GITHUB_USERNAME:-YOUR_GITHUB_USERNAME}}"
GITHUB_REPO="${3:-${GITHUB_REPO:-docker-comfyui-amd}}"

if [ "$DOCKERHUB_USERNAME" = "YOUR_DOCKERHUB_USERNAME" ]; then
    echo "❌ Please provide your Docker Hub username"
    echo "Usage: ./setup-dockerhub.sh [dockerhub-username] [github-username] [github-repo]"
    exit 1
fi

echo "📋 Configuration:"
echo "  Docker Hub: $DOCKERHUB_USERNAME/$REPO_NAME"
echo "  GitHub: $GITHUB_USERNAME/$GITHUB_REPO"
echo ""

echo "🔧 Docker Hub Paid Features to Enable:"
echo ""
echo "1. 📦 Automated Builds:"
echo "   - Go to: https://hub.docker.com/repository/docker/$DOCKERHUB_USERNAME/$REPO_NAME/builds"
echo "   - Connect GitHub repository: $GITHUB_USERNAME/$GITHUB_REPO"
echo "   - Enable automated builds on push"
echo ""

echo "2. 🏗️ Multi-Architecture Builds:"
echo "   - Enable: linux/amd64, linux/arm64"
echo "   - Use: Docker Buildx in build settings"
echo ""

echo "3. 🔄 Build Rules Configuration:"
echo "   Source Type: Branch"
echo "   Source: main"
echo "   Docker Tag: latest"
echo "   Dockerfile location: Dockerfile.cloudbuild"
echo ""
echo "   Source Type: Tag"
echo "   Source: /^v([0-9.]+)$/"
echo "   Docker Tag: {\1}"
echo "   Dockerfile location: Dockerfile.cloudbuild"
echo ""

echo "4. ⏰ Scheduled Builds:"
echo "   - Enable weekly builds for security updates"
echo "   - Recommended: Sunday 2 AM UTC"
echo ""

echo "5. 🔐 Environment Variables to Set:"
echo "   PYTORCH_VERSION=2.7.1"
echo "   ROCM_VERSION=6.3"
echo "   UBUNTU_VERSION=24.04"
echo ""

echo "6. 📊 Build Analytics:"
echo "   - Enable build notifications"
echo "   - Set up webhook for CI/CD integration"
echo ""

echo "7. 🛡️ Security Scanning:"
echo "   - Enable Snyk vulnerability scanning"
echo "   - Set up security notifications"
echo ""

echo "8. 📈 Registry Analytics:"
echo "   - Monitor pull statistics"
echo "   - Track usage patterns"
echo ""

echo "🎯 Manual Setup Steps:"
echo "1. Create repository: https://hub.docker.com/repository/create"
echo "2. Repository name: $REPO_NAME"
echo "3. Description: 'ComfyUI with AMD ROCm support - Lightweight container using host ROCm'"
echo "4. Connect to GitHub: $GITHUB_USERNAME/$GITHUB_REPO"
echo "5. Configure build rules as shown above"
echo "6. Enable multi-arch builds"
echo "7. Set environment variables"
echo "8. Enable security scanning"
echo ""

echo "🚀 Quick Commands:"
echo "# Test local build:"
echo "docker build -f Dockerfile.cloudbuild -t $DOCKERHUB_USERNAME/$REPO_NAME:test ."
echo ""
echo "# Manual push (if needed):"
echo "docker push $DOCKERHUB_USERNAME/$REPO_NAME:test"
echo ""
echo "# Trigger automated build:"
echo "git tag v1.0.0"
echo "git push origin v1.0.0"
echo ""

echo "✅ Configuration complete! Check Docker Hub for automated builds."
