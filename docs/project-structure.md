# Project Structure - Cleaned Up

This document shows the cleaned up, final project structure after removing redundant files.

## 📁 Current File Structure

```
docker-comfyui-rocm/
├── 📋 Documentation
│   ├── README.md                    # Main documentation (ROCm 6.4.4)
│   ├── models.md                    # Model setup guide
│   ├── github-secrets.md            # GitHub metadata configuration
│   ├── building-and-publishing.md   # Local build workflow & publishing
│   └── project-structure.md         # This file
│
├── 🐳 Docker Configuration
│   ├── Dockerfile                   # Standard build (local use)
│   ├── Dockerfile.cloudbuild        # Optimized for cloud builds
│   ├── docker-compose.yml           # Standard compose file (local image aware)
│   └── docker-compose.multi.yml     # Multi-source deployment options
│
├── 🔧 Build Scripts
│   ├── run.sh                       # Quick start
│   ├── stop.sh                      # Stop container
│   ├── logs.sh                      # View logs
│   ├── update.sh                    # Update container
│   ├── build-local.sh               # Local build with custom metadata
│   └── build-multiarch.sh           # Buildx helper (linux/amd64 default)
│
├── 🌐 Docker Hub Scripts
│   ├── push-to-dockerhub.sh         # Detailed push with error handling
│   ├── quick-push.sh                # Simple one-liner push
│   └── setup-dockerhub.sh           # Docker Hub configuration helper
│
├── ⚙️ Configuration Files
│   ├── .env.local.example           # Local build environment template
│   ├── .gitignore                   # Git ignore patterns
│   └── .github/workflows/           # GitHub Actions automation (metadata only)
│       └── docker-build.yml         # Publishes metadata/artifacts
│
└── 📁 Data Directories
    ├── models/                      # AI models
    │   ├── checkpoints/             # Main diffusion models
    │   ├── vae/                     # VAE models
    │   ├── loras/                   # LoRA files
    │   └── controlnet/              # ControlNet models
    ├── output/                      # Generated images
    ├── input/                       # Input images
    ├── workflows/                   # ComfyUI workflows
    ├── custom_nodes/                # Custom extensions
    └── temp/                        # Temporary files
```

## 🎯 Usage Patterns

### **Quick Start (Most Users)**
```bash
./run.sh                    # Start ComfyUI
./logs.sh                   # View logs
./stop.sh                   # Stop when done
```

### **Docker Hub Deployment**
```bash
./quick-push.sh username    # Push to Docker Hub
# OR
./push-to-dockerhub.sh      # Detailed push with validation
```

### **Custom Local Builds**
```bash
cp .env.local.example .env.local
# Edit .env.local with your settings
source .env.local
./build-local.sh
```

### **Multi-Platform Deployment**
```bash
# Use different deployment sources
DOCKERHUB_USERNAME=user docker compose -f docker-compose.multi.yml --profile dockerhub up
GITHUB_USERNAME=user docker compose -f docker-compose.multi.yml --profile ghcr up
docker compose -f docker-compose.multi.yml --profile local up
```

## 📊 File Categories

| Category | Files | Purpose |
|----------|-------|---------|
| **Core Docker** | 4 files | Container definitions and orchestration |
| **Build Scripts** | 6 files | Local development and deployment |
| **Documentation** | 4 files | Setup guides and references |
| **Configuration** | 4 files | Environment and automation setup |
| **Data Directories** | 8 folders | Model storage and outputs |

## 🧹 Maintenance

The project is now **streamlined** with:
- ✅ **No redundant files**
- ✅ **Clear separation of concerns**
- ✅ **Comprehensive documentation**
- ✅ **Flexible deployment options**
- ✅ **Professional automation**

Total: **18 files + 8 directories** (down from 24 files)
