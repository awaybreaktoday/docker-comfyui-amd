# Build Optimization Guide

## 🐛 Large Download Issue

### **Problem**
PyTorch ROCm wheels are very large (~4.5GB), causing build timeouts and cancellations.

```
torch-2.10.0.dev20250926+rocm6.4-cp312-cp312-manylinux_2_28_x86_64.whl (4496.3 MB)
Error: The operation was canceled.
```

## ✅ Optimizations Applied

### **1. Extended Timeouts**
```dockerfile
# Dockerfile optimization
RUN pip install --upgrade pip && \
    pip install --no-cache-dir \
    --timeout 3600 \      # 1 hour timeout
    --retries 3 \         # 3 retry attempts
    --pre torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/nightly/rocm6.4
```

### **2. GitHub Actions Timeout**
```yaml
# Extended job timeout for large downloads
timeout-minutes: 120  # 2 hours for PyTorch download + build
```

### **3. Better Error Isolation**
```dockerfile
# Separate installation steps for better caching and error isolation
RUN pip install --no-cache-dir --timeout 300 -r requirements.txt  # ComfyUI deps
# vs
RUN pip install --no-cache-dir --timeout 3600 torch torchvision   # Large PyTorch
```

### **4. Docker Build Cloud Benefits**
- **Dedicated infrastructure** for large builds
- **Better network connectivity** for downloads
- **Enhanced caching** to avoid re-downloads
- **Parallel builds** across platforms

## 📊 Download Sizes

| Component | Size | Optimization |
|-----------|------|-------------|
| **PyTorch ROCm** | ~4.5GB | Extended timeout, retries |
| **TorchVision** | ~500MB | Bundled with PyTorch |
| **TorchAudio** | ~200MB | Bundled with PyTorch |
| **ComfyUI deps** | ~100MB | Separate step, faster timeout |
| **MIGraphX** | ~50MB | Separate step |

## 🎯 Build Strategy

### **Layer Optimization**
```dockerfile
# 1. System packages (fast, cacheable)
RUN apt-get update && apt-get install -y ...

# 2. Python environment (fast, cacheable)  
RUN python3 -m venv /opt/venv

# 3. PyTorch (SLOW, needs extended timeout)
RUN pip install --timeout 3600 --retries 3 torch ...

# 4. ComfyUI code (fast, changes often)
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

# 5. ComfyUI deps (medium, less frequent changes)
RUN pip install -r requirements.txt

# 6. Extensions (small, separate for isolation)
RUN git clone MIGraphX && pip install -r requirements.txt
```

### **Caching Strategy**
1. **Docker Build Cloud** persistent cache
2. **GitHub Actions** cache for layers
3. **Layer separation** to maximize cache hits
4. **Build argument** optimization

## 🚀 Expected Improvements

### **Build Times**
- **First build**: ~45-60 minutes (PyTorch download)
- **Cached builds**: ~5-10 minutes (cache hits)
- **Code changes**: ~10-15 minutes (PyTorch cached)

### **Reliability**
- ✅ **Extended timeouts** prevent cancellation
- ✅ **Retry logic** handles temporary failures
- ✅ **Build Cloud** provides stable infrastructure
- ✅ **Layer caching** reduces rebuild times

### **Multi-Platform**
- **AMD64**: Full support, faster builds
- **ARM64**: Cross-compilation, may be slower
- **Parallel**: Both platforms build simultaneously

## 🔍 Monitoring

### **Build Logs to Watch**
```
# Successful PyTorch download
Successfully downloaded torch-2.10.0...whl (4496.3 MB)
Installing collected packages: torch, torchvision, torchaudio
Successfully installed torch-2.10.0...

# Cache hits (faster subsequent builds)
CACHED [5/12] RUN pip install --timeout 3600 torch...
```

### **Failure Indicators**
```
# Timeout (should be rare with 120min limit)
Error: The operation was canceled.

# Network issues (retries should handle)
ERROR: Could not find a version that satisfies the requirement torch

# Build Cloud issues
Error: failed to solve: failed to create endpoint
```

## 🛠️ Troubleshooting

### **If Builds Still Fail**
1. **Check Docker Build Cloud status**
2. **Verify network connectivity** to PyTorch index
3. **Consider using stable releases** instead of nightly
4. **Split builds** further if needed

### **Fallback Options**
```dockerfile
# Option 1: Use stable PyTorch (smaller, more reliable)
RUN pip install torch==2.6.0 torchvision==0.21.0 --index-url https://download.pytorch.org/whl/rocm6.4/

# Option 2: Multi-stage build
FROM pytorch/pytorch:2.6.0-rocm6.4-devel as pytorch-base
# Copy only PyTorch to final image
```

### **Local Testing**
```bash
# Test Dockerfile locally with same optimizations
docker build -f Dockerfile.cloudbuild \
  --build-arg PYTORCH_VERSION=2.7.1 \
  --progress=plain \
  -t test-build .
```

## 📚 References

- [Docker Build Cloud Documentation](https://docs.docker.com/build/cloud/)
- [PyTorch Installation Guide](https://pytorch.org/get-started/locally/)
- [Docker Build Optimization](https://docs.docker.com/build/optimization/)

---

**These optimizations should resolve the build cancellation issues! 🚀**
