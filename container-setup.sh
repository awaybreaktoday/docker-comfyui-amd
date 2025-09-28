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
    libgl1 \
    libgl1-mesa-dri \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1

BASE_PYTHON_PACKAGES=(
    "opencv-python"
    "imageio"
    "imageio-ffmpeg"
    "torchvision"
    "accelerate"
    "transformers"
    "diffusers"
    "controlnet-aux"
    "insightface"
    "mediapipe"
    "segment-anything"
)

pip install --no-cache-dir "${BASE_PYTHON_PACKAGES[@]}"

echo -e "${GREEN}✅ System dependencies installed${NC}"

# Install requirements from custom nodes if they exist
if [ -d "/app/custom_nodes" ]; then
    echo -e "${BLUE}🔧 Installing custom node requirements...${NC}"

    find /app/custom_nodes -name "requirements.txt" -exec pip install --no-cache-dir -r {} \;

    CUSTOM_REQ="/app/custom_nodes/requirements_custom.txt"
    if [ -f "$CUSTOM_REQ" ]; then
        echo -e "${BLUE}📄 Installing curated requirements from setup script...${NC}"
        pip install --no-cache-dir -r "$CUSTOM_REQ"
    else
        echo -e "${YELLOW}⚠️ requirements_custom.txt not found; skipping curated install${NC}"
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
