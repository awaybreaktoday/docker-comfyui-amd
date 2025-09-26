# Storage Constraints and Local Build Strategy

## 🚨 Issue: Cloud Builds Exceed Storage Limits

### **The Problem**
```
ERROR: Could not install packages due to an OSError: [Errno 28] No space left on device
```

**Root Cause:**
- **PyTorch ROCm wheels**: ~2.5-2.7GB (stable) or ~4.5GB (nightly)
- **Multi-platform builds**: linux/amd64 + linux/arm64 = ~9GB+
- **GitHub Actions**: Limited disk space
- **Docker Hub free tier**: 25GB total storage
- **Build dependencies**: Additional ~2-3GB

## 📊 Size Breakdown

| Component | Size | Impact |
|-----------|------|---------|
| **PyTorch ROCm (AMD64)** | ~2.5-2.7GB | Stable release |
| **PyTorch ROCm (ARM64)** | ~2.5-2.7GB | Stable release |
| **Base Ubuntu + deps** | ~1GB | System packages |
| **ComfyUI + extensions** | ~500MB | Application code |
| **Build cache/temp** | ~2GB | Docker layers |
| **Total per platform** | ~5-6GB | More manageable |

## ✅ Solution: Local Build Strategy

### **Disabled Cloud Builds**
```yaml
# GitHub Actions workflow now shows helpful notice instead of building
# Cloud builds commented out due to storage constraints
```

### **Enhanced Local Building**
```bash
# Single platform (recommended)
./build-local.sh --platform linux/amd64

# Multi-platform (if you have space)
./build-local.sh --multi-platform

# Push to Docker Hub
./quick-push.sh yourusername
```

## 🛠️ Local Build Optimizations

### **1. Storage-Aware Building**
```bash
# Check available space before building
df -h .
# Requires ~6-8GB free space (stable PyTorch)

# Clean up before building
docker system prune -a
```

### **2. Platform Selection**
```bash
# Single platform (saves ~4.5GB)
--platform linux/amd64

# Multi-platform only if needed
--platform linux/amd64,linux/arm64
```

### **3. Progressive Building**
```bash
# Build and test locally first
./build-local.sh

# Push only if successful
./quick-push.sh yourusername
```

## 📦 Docker Hub Considerations

### **Free Tier Limits**
- **Total storage**: 25GB
- **Pull rate limits**: 200 pulls per 6 hours
- **One private repository**

### **Paid Tier Benefits**
- **More storage**: Up to 5TB+
- **Unlimited pulls**: No rate limits
- **Multiple private repos**
- **Better support**

## 🚀 Alternative Strategies

### **1. Smaller Base Images**
```dockerfile
# Consider using smaller PyTorch builds
FROM pytorch/pytorch:2.6.0-rocm6.4-runtime  # Smaller than devel
# vs
pip install torch  # Full wheel download
```

### **2. Multi-Stage Builds**
```dockerfile
# Stage 1: Download and install PyTorch
FROM ubuntu:24.04 as pytorch-builder
RUN pip install torch...

# Stage 2: Copy only needed files
FROM ubuntu:24.04 as final
COPY --from=pytorch-builder /opt/venv /opt/venv
```

### **3. External Registry**
```bash
# Use alternative registries with more storage
# - GitHub Container Registry (ghcr.io)
# - Amazon ECR
# - Google Container Registry
```

### **4. Stable vs Nightly**
```dockerfile
# Now using stable releases (40% smaller)
RUN pip install torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/rocm6.4
# Previously used:
# RUN pip install --pre torch torchvision  # Nightly (~4.5GB)
```

## 💡 Recommendations

### **For Development**
1. **Build locally** with single platform
2. **Test thoroughly** before pushing
3. **Clean up regularly** (`docker system prune -a`)
4. **Monitor disk space** (`docker system df`)

### **For Production**
1. **Consider Docker Hub paid plan** (more storage)
2. **Use external CI/CD** with more disk space
3. **Self-hosted runners** with adequate storage
4. **Alternative registries** if needed

### **For Distribution**
1. **Push single platform** initially (AMD64)
2. **Add ARM64** only if needed
3. **Document storage requirements**
4. **Provide local build instructions**

## 🔧 Local Build Workflow

### **1. Prepare Environment**
```bash
# Check space
df -h
# Should have >15GB free

# Clean Docker
docker system prune -a
```

### **2. Build Image**
```bash
# Configure build
cp .env.local.example .env.local
# Edit with your details

# Build (single platform recommended)
./build-local.sh --dockerhub-user yourusername
```

### **3. Test Locally**
```bash
# Test the image
./run.sh

# Verify GPU access
docker exec -it container-name rocm-smi
```

### **4. Push to Registry**
```bash
# Push to Docker Hub
./quick-push.sh yourusername

# Or push with specific tag
./quick-push.sh yourusername v1.0
```

## 📚 Storage Management Tips

### **Monitor Usage**
```bash
# Docker storage usage
docker system df

# Detailed breakdown
docker system df -v

# Local disk space
df -h
```

### **Clean Up Regularly**
```bash
# Remove unused images/containers
docker system prune -a

# Remove build cache
docker builder prune

# Remove specific images
docker rmi $(docker images -q)
```

### **Optimize Builds**
```bash
# Use .dockerignore
echo "*.log" >> .dockerignore
echo "temp/*" >> .dockerignore

# Single platform builds
--platform linux/amd64

# Avoid unnecessary layers
RUN cmd1 && cmd2 && cmd3  # vs separate RUN statements
```

## 🎯 Current Status

✅ **Local build workflow** optimized and ready  
✅ **Storage constraints** documented and addressed  
✅ **Enhanced scripts** with storage awareness  
✅ **Cloud builds** disabled with helpful notices  
✅ **Alternative strategies** documented  

**Bottom Line**: Build locally, push manually, works reliably! 🚀
