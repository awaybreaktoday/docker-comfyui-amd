# Docker Build Cloud - Not Suitable for This Project

⚠️ **IMPORTANT**: This project CANNOT be built using Docker Build Cloud, GitHub Actions, or any cloud-based build service due to the large PyTorch ROCm package size (3.6GB).

## ❌ Why Cloud Builds Fail

### **The PyTorch Problem**
- **Package Size**: PyTorch with ROCm 6.4 is **3.6GB**
- **Download File**: `torch-2.8.0+rocm6.4-cp312-cp312-manylinux_2_28_x86_64.whl`
- **Build Time**: 30-60+ minutes depending on network speed
- **Timeout Issues**: Most cloud services timeout before completion

### **Cloud Service Limitations**

| Service | Free Limit | Issue |
|---------|------------|-------|
| **GitHub Actions** | 6 hour max job | Timeouts on 3.6GB download |
| **Docker Hub Build** | 2 hour max | Fails during PyTorch download |
| **GitLab CI** | 3 hour max | Storage and timeout issues |
| **CircleCI** | 5 hour max | Network bandwidth throttling |

## ✅ Required: Local Build Process

### **Step 1: Build Locally**
```bash
# Clone the repository
git clone https://github.com/yourusername/docker-comfyui-amd.git
cd docker-comfyui-amd

# Build the image (30-60 minutes)
./build-local.sh
# OR
docker build -t comfyui-rocm .
```

### **Step 2: Push to Registry**
```bash
# Tag the image
docker tag comfyui-rocm:latest yourusername/comfyui-rocm:latest

# Push to Docker Hub
docker push yourusername/comfyui-rocm:latest
```

## 📊 Why PyTorch ROCm is So Large

The PyTorch wheel includes:
- **ROCm Libraries**: Full AMD GPU compute stack
- **HIP Runtime**: AMD's CUDA equivalent
- **MIOpen**: Deep learning primitives (AMD's cuDNN)
- **rocBLAS**: Basic linear algebra for GPUs
- **rocFFT**: Fast Fourier transforms
- **rocRAND**: Random number generation
- **Tensile**: Optimized GPU kernels
- **All GPU architectures**: gfx900, gfx906, gfx908, gfx1030, gfx1100, etc.

## 🔧 Local Build Optimization

### **First Build** (30-60 minutes)
```bash
# Downloads 3.6GB PyTorch package
# Builds all layers
docker build -t comfyui-rocm .
```

### **Subsequent Builds** (2-5 minutes)
```bash
# Uses cached PyTorch layer
# Only rebuilds changed layers
docker build -t comfyui-rocm .
```

## 💡 Alternative Approaches (Not Recommended)

### **1. Pre-built Base Image**
Create a base image with PyTorch pre-installed:
```dockerfile
# pytorch-rocm-base.dockerfile
FROM ubuntu:24.04
RUN pip install torch --index-url https://download.pytorch.org/whl/rocm6.4
```
Build locally and push, then reference in main Dockerfile.

### **2. Volume Mount PyTorch**
Download wheel once, mount as volume:
```bash
# Download once
wget https://download.pytorch.org/whl/rocm6.4/torch-2.8.0+rocm6.4-cp312-cp312-manylinux_2_28_x86_64.whl

# Mount during build (experimental)
docker build --mount=type=bind,source=./torch-2.8.0+rocm6.4.whl,target=/tmp/torch.whl .
```

### **3. Use CPU Version (No GPU)**
```dockerfile
# Small but no GPU acceleration
RUN pip install torch --index-url https://download.pytorch.org/whl/cpu
```
⚠️ This defeats the purpose of ROCm support!

## 📝 GitHub Actions Configuration

If you still want CI/CD, use it only for:
- **Linting** and code quality checks
- **Documentation** updates
- **Pushing** pre-built images
- **NOT for building** the Docker image

Example workflow:
```yaml
name: Push Pre-built Image
on:
  workflow_dispatch:
jobs:
  push:
    runs-on: ubuntu-latest
    steps:
      - name: Note about local build
        run: |
          echo "⚠️ This image must be built locally first!"
          echo "Run: ./build-local.sh"
          echo "Then: ./quick-push.sh ${{ secrets.DOCKERHUB_USERNAME }}"
```

## 🎯 Summary

1. **Build locally** - Required due to 3.6GB PyTorch
2. **Push to registry** - After successful local build
3. **Users pull pre-built** - Fast deployment
4. **No cloud builds** - They will always fail

This is a limitation of PyTorch's ROCm distribution size, not the Docker configuration. Until AMD provides smaller, modular packages, local builds are the only reliable option.