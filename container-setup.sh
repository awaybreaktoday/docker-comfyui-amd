#!/bin/bash

# Container Setup Script
# Runs inside the container to install Python dependencies for custom nodes

set -e

echo "🐳 Container Setup Script"
echo "========================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📦 Installing Python dependencies...${NC}"

# Update package lists
apt-get update -qq

# Install system dependencies
apt-get install -y -qq \
    git \
    wget \
    unzip \
    curl \
    ffmpeg \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1

# Install Python packages
pip install --no-cache-dir \
    ollama>=0.3.0 \
    opencv-python \
    imageio \
    imageio-ffmpeg \
    torchvision \
    accelerate \
    transformers \
    diffusers \
    controlnet-aux \
    insightface \
    onnxruntime \
    mediapipe \
    segment-anything \
    ultralytics \
    xformers \
    ftfy \
    spandrel \
    kornia \
    torchsde

echo -e "${GREEN}✅ System dependencies installed${NC}"

# Install requirements from custom nodes if they exist
if [ -d "/app/custom_nodes" ]; then
    echo -e "${BLUE}🔧 Installing custom node requirements...${NC}"

    find /app/custom_nodes -name "requirements.txt" -exec pip install --no-cache-dir -r {} \;

    # Install specific requirements for key extensions
    if [ -f "/app/custom_nodes/requirements_custom.txt" ]; then
        pip install --no-cache-dir -r /app/custom_nodes/requirements_custom.txt
    fi
fi

echo -e "${GREEN}✅ Container setup completed!${NC}"

# Display system info
echo -e "${BLUE}📊 System Information:${NC}"
echo "Python: $(python --version)"
echo "PyTorch: $(python -c 'import torch; print(torch.__version__)')"
echo "CUDA/ROCm available: $(python -c 'import torch; print(torch.cuda.is_available())')"
echo "Device count: $(python -c 'import torch; print(torch.cuda.device_count())')"

if command -v rocm-smi &> /dev/null; then
    echo -e "${BLUE}🎮 GPU Status:${NC}"
    rocm-smi --showid --showproductname --showmeminfo --showuse
fi