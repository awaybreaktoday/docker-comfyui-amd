# ComfyUI with AMD ROCm Docker Setup

**ROCm 6.4.4** - Latest version with full consumer GPU support for RX 7000/9000 series

A lightweight Docker container for running ComfyUI with AMD ROCm support, leveraging your existing host ROCm installation.

✅ **OPTIMIZED**: Multi-stage Dockerfiles reduce image size by 30-45%. Both local and cloud builds supported with build timeout optimizations.

## 🎯 Features

- **🎮 Consumer GPU Support**: Full official support for RX 7000/9000 series
- **🪟 Cross-Platform**: Windows and Linux compatibility
- **⚡ Latest Stack**: Ubuntu 24.04 LTS + PyTorch + ROCm 6.4.4
- **🏗️ Multi-Stage Builds**: Optimized Dockerfiles for smaller images
- **📦 Cloud Build Support**: GitHub Actions + Docker Build Cloud compatible
- **🔧 Easy Setup**: Simple scripts for all operations
- **🎬 Video Generation**: AnimateDiff, CogVideoX, and SVD support
- **🤖 Ollama Integration**: Connect to external Ollama server for LLM workflows
- **👁️ Advanced Vision**: Qwen2.5-VL and Florence2 vision models
- **🚀 Automated Setup**: Host-managed custom nodes and model downloads

## 🚀 Quick Start

### **Basic Setup**
```bash
# Clone and navigate
cd Developer/src/personal/docker-comfyui-amd

# Make scripts executable
chmod +x *.sh

# Start ComfyUI
./run.sh

# Access at http://localhost:8188
```

### **Complete Setup with Extensions & Models**
```bash
# 1. Install custom nodes and video generation extensions
./setup-comfyui.sh

# 2. Download models (interactive menu)
./download-all-models.sh

# 3. Restart with new configuration
./stop.sh && ./run.sh

# 4. Install Python dependencies in container
docker exec -it comfyui-rocm-6.4.4 bash /app/setup.sh
```

### **Ollama + Video Generation Setup**
```bash
# On MacBook Pro (Ollama server)
export OLLAMA_HOST=0.0.0.0:11434
ollama serve
ollama pull qwen2.5-vl:7b

# On AMD server (complete setup)
./setup-comfyui.sh && ./download-all-models.sh
./stop.sh && ./run.sh
docker exec -it comfyui-rocm-6.4.4 bash /app/setup.sh
```

## 📁 Project Structure

```
docker-comfyui-amd/
├── 📋 Core Files
│   ├── README.md                    # This file
│   ├── Dockerfile                   # Multi-stage optimized build
│   ├── Dockerfile.cloudbuild        # Multi-stage with metadata for cloud builds
│   ├── docker-compose.yml           # Standard deployment
│   └── docker-compose.multi.yml     # Multi-source deployment
│
├── 🔧 Scripts
│   ├── run.sh                       # Quick start
│   ├── stop.sh / logs.sh / update.sh # Management
│   ├── build-local.sh               # Local builds with metadata
│   ├── quick-push.sh                # Push to Docker Hub
│   ├── setup-dockerhub.sh           # Docker Hub configuration
│   ├── setup-comfyui.sh             # Install custom nodes & extensions
│   ├── download-all-models.sh       # Download AI models (interactive)
│   └── container-setup.sh           # Container dependency installer
│
├── 📚 Documentation
│   ├── docs/models.md               # Model setup guide
│   ├── docs/github-secrets.md       # GitHub secrets configuration
│   ├── docs/docker-build-cloud.md   # Build Cloud setup
│   ├── docs/build-fixes.md          # Recent build fixes
│   └── docs/project-structure.md    # Detailed project overview
│
├── ⚙️ Configuration
│   ├── .env.local.example           # Local build environment
│   ├── .gitignore                   # Git ignore patterns
│   └── .github/workflows/           # CI/CD with Build Cloud
│
└── 📁 Data Directories
    ├── models/{checkpoints,vae,loras,controlnet}/  # AI models
    ├── output/                      # Generated images
    ├── input/                       # Input images
    ├── workflows/                   # ComfyUI workflows
    └── custom_nodes/                # Extensions
```

## 📋 Prerequisites

1. **ROCm 6.4.4** installed on host system
   ```bash
   # Verify installation
   rocm-smi
   cat /opt/rocm/.info/version  # Should show 6.4.4
   ```

2. **Docker** with GPU support
   ```bash
   # Add user to groups
   sudo usermod -a -G docker,video,render $USER
   # Log out and back in
   ```

3. **Compatible AMD GPU** (RX 7000/9000 series fully supported)

## 🛠️ Usage

### **Basic Operations**
```bash
./run.sh          # Start ComfyUI container
./stop.sh         # Stop container
./logs.sh         # View real-time logs
./update.sh       # Update and rebuild
```

### **Extension Management**
```bash
./setup-comfyui.sh              # Install all custom nodes and extensions
./download-all-models.sh        # Download AI models (interactive menu)
docker exec -it comfyui-rocm-6.4.4 bash /app/setup.sh  # Install Python deps
```

### **Ollama Integration**
```bash
# On your MacBook Pro (Ollama server)
export OLLAMA_HOST=0.0.0.0:11434
ollama serve
ollama pull qwen2.5-vl:7b
ollama pull llava:13b

# In ComfyUI nodes, set Ollama URL to:
# http://YOUR-MACBOOK-IP:11434
```

### **Docker Hub Deployment**
```bash
./quick-push.sh yourusername           # Simple push
./push-to-dockerhub.sh                 # Detailed push with validation
./setup-dockerhub.sh                   # Configure automation
```

### **Custom Local Builds**
```bash
# Copy and customize environment
cp .env.local.example .env.local
# Edit with your details, then:
source .env.local && ./build-local.sh
```

### **Multi-Platform Deployment**
```bash
# Use different sources
DOCKERHUB_USERNAME=user docker-compose -f docker-compose.multi.yml --profile dockerhub up
docker-compose -f docker-compose.multi.yml --profile local up
```

## 🏗️ Build Requirements

### **Local Build Only**
⚠️ **This image cannot be built in cloud services** due to:
- **3.6GB PyTorch ROCm package** download exceeds timeout limits
- **Build time**: 30-60 minutes depending on network speed
- **Cloud service limitations**: GitHub Actions and Docker Hub will fail

### **Building Locally**
```bash
# Build the image locally (required)
./build-local.sh

# After successful build, push to Docker Hub
./quick-push.sh yourusername
```

### **Why Local Build?**
- PyTorch ROCm wheel is 3.6GB (torch-2.8.0+rocm6.4)
- Includes all AMD GPU libraries (ROCm, HIP, MIOpen)
- Cloud services timeout during large downloads
- Local builds cache the download for faster rebuilds

## 🔧 Technical Details

### **Container Stack**
- **Base**: Ubuntu 24.04 LTS (12 years support)
- **PyTorch**: Stable release with ROCm 6.4 support
- **ComfyUI**: Latest from official repository
- **Extensions**: MIGraphX for AMD GPU acceleration
- **Custom Nodes**: Video generation, Ollama integration, advanced vision models

### **Included Extensions**
- **🎬 Video Generation**: AnimateDiff, CogVideoX, VideoHelperSuite
- **🤖 Ollama Integration**: comfyui-ollama, Ollama-Describer
- **👁️ Vision Models**: Qwen2.5-VL, Florence2, CLIP Vision
- **🎮 ControlNet**: Advanced pose and edge control for generation
- **📈 Upscaling**: RealESRGAN, ESRGAN variants
- **🔧 Utilities**: Custom Scripts, Manager, Impact Pack

### **ROCm 6.4.4 Integration**
- **Consumer GPU Support**: Official RX 7000/9000 series support
- **Host Mounting**: Uses your optimized ROCm installation
- **Performance**: Latest AMD GPU optimizations
- **Compatibility**: Windows and Linux support

### **GPU Architecture Support**
- **RDNA 2**: gfx1030, gfx1031, gfx1032
- **RDNA 3**: gfx1100, gfx1101, gfx1102 (RX 7000 series)
- **RDNA 4**: gfx1200, gfx1201 (RX 9000 series)

## 📚 Documentation

| Guide | Description |
|-------|-------------|
| **[Model Setup](docs/models.md)** | Download and configure AI models |
| **[GitHub Secrets](docs/github-secrets.md)** | Configure automated builds |
| **[Docker Build Cloud](docs/docker-build-cloud.md)** | Build infrastructure details |
| **[Build Fixes](docs/build-fixes.md)** | Recent Ubuntu 24.04 fixes |
| **[Project Structure](docs/project-structure.md)** | Detailed project overview |

## 🎮 Supported GPUs

**ROCm 6.4.4 Consumer GPU Support:**
- ✅ **RX 7900 XTX/XT** - Fully supported
- ✅ **RX 7800/7700 XT** - Fully supported  
- ✅ **RX 9070 XT/9070** - Fully supported (RDNA 4)
- ✅ **AMD Instinct** series - Enterprise support

## 🐛 Troubleshooting

### **Container Issues**
```bash
# Check ROCm installation
ls -la /opt/rocm && cat /opt/rocm/.info/version

# Verify Docker permissions
groups $USER | grep docker

# Check GPU devices
ls -la /dev/dri /dev/kfd
```

### **GPU Not Detected**
```bash
# Check logs
./logs.sh

# Verify host ROCm
rocm-smi

# Test PyTorch in container
docker exec -it comfyui-rocm-6.4.4 python -c "import torch; print(torch.cuda.is_available())"
```

### **Extension Issues**
```bash
# Reinstall custom nodes
./setup-comfyui.sh

# Install missing Python dependencies
docker exec -it comfyui-rocm-6.4.4 bash /app/setup.sh

# Check for import errors
./logs.sh | grep "IMPORT FAILED"
```

### **GPU Issues (RX 7900 XTX)**
```bash
# If you see "HIP error: no kernel image available"
# Check docker-compose.yml environment variables:
# HSA_OVERRIDE_GFX_VERSION=11.0.0
# PYTORCH_ROCM_ARCH=gfx1100

# Restart container after GPU config changes
./stop.sh && ./run.sh

# Verify GPU detection
docker exec -it comfyui-rocm-6.4.4 python -c "
import torch
print('PyTorch:', torch.__version__)
print('CUDA available:', torch.cuda.is_available())
print('Device name:', torch.cuda.get_device_name(0))
"
```

### **Ollama Connection Issues**
```bash
# Test Ollama connection from container
docker exec -it comfyui-rocm-6.4.4 curl http://YOUR-MACBOOK-IP:11434/api/tags

# Check MacBook firewall (allow port 11434)
# Verify OLLAMA_HOST environment variable
echo $OLLAMA_HOST  # Should be 0.0.0.0:11434
```

### **Build Issues**
See [Build Fixes Documentation](docs/build-fixes.md) for Ubuntu 24.04 compatibility solutions.

## 🔄 Updates

### **Update ComfyUI**
```bash
./update.sh
```

### **Update Container**
```bash
# Rebuild with latest packages
docker-compose build --no-cache
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with `./build-local.sh`
5. Submit a pull request (note: automated builds not available due to size)

See [Documentation Guide](docs/documentation-guide.md) for documentation standards.

## 📜 License

This setup uses:
- ComfyUI (GPL-3.0)
- PyTorch (BSD)
- ROCm (MIT/Apache 2.0)
- Ubuntu (Various open source licenses)

## 🆘 Support

**Need Help?**
1. Check the [Model Setup Guide](docs/models.md)
2. Review [Build Cloud Documentation](docs/docker-build-cloud.md)
3. Check container logs: `./logs.sh`
4. Verify ROCm: `rocm-smi`
5. Test extension setup: `./setup-comfyui.sh`

**Found a Bug?**
- Open an issue with your system details
- Include container logs and ROCm version
- Specify your GPU model
- Include extension versions and Ollama connection details

**Video Generation Tips:**
- **AnimateDiff**: Good for smooth motion, works with SD1.5 models
- **Wan2.2**: Best quality text-to-video, 14B parameters, requires 21GB VRAM
- **Wan2.2 Fast**: 4-step LoRA mode, 2 minutes vs 8-9 minutes
- **Resolution**: Start with 640x640, increase if you have VRAM
- **Prompts**: "A [subject] [action], [style]" format works best

**Ollama Integration Tips:**
- Use `qwen2.5-vl:7b` for best vision capabilities
- Use `llava:13b` as reliable backup
- Set MacBook IP correctly in Ollama nodes (http://IP:11434)
- Ensure firewall allows port 11434
- Test connection with curl before using nodes

**RX 7900 XTX Specific:**
- Environment variables configured for gfx1100 architecture
- 24GB VRAM: Can run Wan2.2 models at 640x640
- If GPU errors: restart container after env changes

---

**Ready to generate amazing AI art and videos with ComfyUI on AMD GPUs! 🎨🚀**

*Optimized for ROCm 6.4.4 with full consumer GPU support*
*Built with Docker Build Cloud for professional-grade CI/CD*
*Enhanced with video generation, Ollama integration, and advanced vision models*
