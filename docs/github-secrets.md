# GitHub Secrets Configuration Guide

This guide explains how to configure GitHub secrets for dynamic Docker labels and metadata.

## 🔐 Required Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

### Essential Secrets

| Secret Name | Purpose | Example Value |
|------------|---------|---------------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username | `johnsmith` |
| `DOCKERHUB_TOKEN` | Docker Hub access token | `dckr_pat_...` |

### Optional Secrets (with fallbacks)

| Secret Name | Purpose | Default Fallback | Example Value |
|------------|---------|------------------|---------------|
| `MAINTAINER_NAME` | Your name for labels | `ComfyUI ROCm Maintainer` | `John Smith` |
| `MAINTAINER_EMAIL` | Contact email | `maintainer@example.com` | `john@example.com` |
| `VENDOR_NAME` | Organization/vendor name | `github.repository_owner` | `John Smith` or `MyCompany` |
| `IMAGE_DESCRIPTION` | Custom description | `ComfyUI with AMD ROCm 6.4.4 support...` | `My custom ComfyUI setup` |

## 🎯 Setting Up Secrets

### 1. **Docker Hub Credentials**
```bash
# Create Docker Hub access token at:
# https://hub.docker.com/settings/security

# Add to GitHub secrets:
DOCKERHUB_USERNAME=your-username
DOCKERHUB_TOKEN=dckr_pat_your-token-here
```

### 2. **Personal Information**
```bash
# Add to GitHub secrets:
MAINTAINER_NAME=Your Full Name
MAINTAINER_EMAIL=your.email@domain.com
VENDOR_NAME=Your Organization
```

### 3. **Custom Description (Optional)**
```bash
# Add to GitHub secrets:
IMAGE_DESCRIPTION=My customized ComfyUI container with ROCm 6.4.4 support for AMD GPUs
```

## 🏷️ Generated Labels

With secrets configured, your Docker image will automatically include:

### Standard OCI Labels
```dockerfile
org.opencontainers.image.title=ComfyUI AMD ROCm
org.opencontainers.image.description=${YOUR_DESCRIPTION}
org.opencontainers.image.vendor=${YOUR_VENDOR_NAME}
org.opencontainers.image.version=${GITHUB_VERSION}
org.opencontainers.image.url=https://hub.docker.com/r/${YOUR_USERNAME}/comfyui-rocm
org.opencontainers.image.source=https://github.com/${YOUR_REPO}
org.opencontainers.image.documentation=https://github.com/${YOUR_REPO}/blob/main/README.md
org.opencontainers.image.created=${BUILD_DATE}
org.opencontainers.image.revision=${COMMIT_SHA}
org.opencontainers.image.licenses=GPL-3.0
```

### Technical Labels
```dockerfile
rocm.version=6.4
pytorch.version=2.7.1
ubuntu.version=24.04
gpu.support=AMD RDNA2,RDNA3,RDNA4
consumer.gpu=RX7000,RX9000
```

### Custom Labels
```dockerfile
maintainer=${YOUR_NAME} <${YOUR_EMAIL}>
description=${YOUR_DESCRIPTION}
version=${GITHUB_VERSION}
vendor=${YOUR_VENDOR_NAME}
```

## 🔧 GitHub Variables (Alternative)

You can also use GitHub Variables for non-sensitive data:

Go to: Settings → Secrets and variables → Actions → Variables tab

| Variable Name | Purpose | Example |
|--------------|---------|---------|
| `DEFAULT_DESCRIPTION` | Default image description | `ComfyUI ROCm for AMD GPUs` |
| `ORGANIZATION_NAME` | Your organization | `AI Solutions Inc` |
| `SUPPORT_EMAIL` | Support contact | `support@example.com` |

## 📋 Setup Checklist

- [ ] Create Docker Hub access token
- [ ] Add `DOCKERHUB_USERNAME` secret
- [ ] Add `DOCKERHUB_TOKEN` secret
- [ ] Add `MAINTAINER_NAME` secret
- [ ] Add `MAINTAINER_EMAIL` secret
- [ ] Add `VENDOR_NAME` secret (optional)
- [ ] Add `IMAGE_DESCRIPTION` secret (optional)
- [ ] Test workflow with a commit
- [ ] Verify labels in Docker Hub

## 🚀 Testing Your Setup

1. **Make a test commit:**
   ```bash
   git add .
   git commit -m "Test GitHub secrets integration"
   git push origin main
   ```

2. **Check GitHub Actions:**
   - Go to Actions tab in your repo
   - Watch the build process
   - Check for any errors

3. **Verify Docker Hub:**
   - Visit your Docker Hub repository
   - Check the image tags and metadata
   - Verify labels are populated correctly

## 🔍 Inspecting Labels

After the image is built, you can inspect the labels:

```bash
# Pull your image
docker pull your-username/comfyui-rocm:latest

# Inspect labels
docker inspect your-username/comfyui-rocm:latest | jq '.[0].Config.Labels'

# Or use docker command
docker image inspect your-username/comfyui-rocm:latest --format='{{json .Config.Labels}}' | jq
```

## 🛠️ Local Testing

To test the Dockerfile locally with custom values:

```bash
# Build with custom arguments
docker build -f Dockerfile.cloudbuild \
  --build-arg MAINTAINER_NAME="Your Name" \
  --build-arg MAINTAINER_EMAIL="your@email.com" \
  --build-arg VENDOR_NAME="Your Company" \
  --build-arg IMAGE_VERSION="1.0.0" \
  --build-arg DOCKERHUB_USERNAME="yourusername" \
  --build-arg GITHUB_USERNAME="yourgithub" \
  --build-arg GITHUB_REPO="your-repo" \
  -t test-image .

# Inspect the labels
docker inspect test-image | jq '.[0].Config.Labels'
```

## 🔒 Security Best Practices

1. **Use Access Tokens**: Never use your Docker Hub password
2. **Least Privilege**: Only grant necessary permissions
3. **Regular Rotation**: Rotate tokens periodically
4. **Monitor Usage**: Check token usage in Docker Hub
5. **Environment Separation**: Use different tokens for prod/dev

## 📧 Troubleshooting

### Labels Not Appearing
- Check if secrets are properly configured
- Verify secret names match exactly
- Look at GitHub Actions logs for build arguments

### Build Failures
- Ensure all required secrets are set
- Check for typos in secret names
- Verify Docker Hub token permissions

### Empty Labels
- Some secrets have fallback values, check if fallbacks are being used
- Verify the Dockerfile build arguments are being passed correctly

---

**Your Docker images will now have dynamic, personalized metadata! 🏷️✨**
