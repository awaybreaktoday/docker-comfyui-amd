#!/bin/bash

# ComfyUI Docker Setup Script
# Automatically downloads and installs custom nodes for video generation and Ollama integration

set -e

echo "🚀 ComfyUI Custom Nodes Setup Script"
echo "====================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create directories if they don't exist
echo -e "${BLUE}📁 Creating directory structure...${NC}"
mkdir -p custom_nodes
mkdir -p models/{checkpoints,vae,loras,controlnet,upscale_models,clip_vision,unet}
mkdir -p output input temp workflows

cd custom_nodes

# Function to clone or update GitHub repos with shallow clones
download_extension() {
    local repo_url=$1
    local dir_name=$2
    local description=$3

    echo -e "${YELLOW}⬇️  Installing: $description${NC}"

    if [ -d "$dir_name/.git" ]; then
        if git -C "$dir_name" pull --ff-only; then
            echo -e "${GREEN}   ✅ Updated existing clone${NC}"
            return
        fi
        echo -e "${YELLOW}   ⚠️ Update failed, recloning...${NC}"
        rm -rf "$dir_name"
    elif [ -d "$dir_name" ]; then
        echo -e "${YELLOW}   Directory exists without git metadata. Removing stale copy...${NC}"
        rm -rf "$dir_name"
    fi

    if git clone --depth 1 "$repo_url" "$dir_name"; then
        echo -e "${GREEN}   ✅ $description installed${NC}"
    else
        echo -e "${RED}   ❌ Failed to clone $description${NC}"
        return 1
    fi
}

# Essential Extensions
echo -e "${BLUE}🔧 Installing Essential Extensions...${NC}"

download_extension "https://github.com/stavsap/comfyui-ollama" "comfyui-ollama" "Ollama Integration"
download_extension "https://github.com/pythongosssss/ComfyUI-Custom-Scripts" "ComfyUI-Custom-Scripts" "Custom Scripts (ShowText, etc.)"
download_extension "https://github.com/ltdrdata/ComfyUI-Manager" "ComfyUI-Manager" "Extension Manager"

# Video Generation Extensions
echo -e "${BLUE}🎬 Installing Video Generation Extensions...${NC}"

download_extension "https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved" "ComfyUI-AnimateDiff-Evolved" "AnimateDiff (Video Generation)"
download_extension "https://github.com/Stability-AI/ComfyUI-SAI_API" "ComfyUI-SAI_API" "Stability AI API (SVD)"
download_extension "https://github.com/kijai/ComfyUI-CogVideoXWrapper" "ComfyUI-CogVideoXWrapper" "CogVideoX Video Model"
download_extension "https://github.com/ZHO-ZHO-ZHO/ComfyUI-VideoHelperSuite" "ComfyUI-VideoHelperSuite" "Video Processing Suite"
download_extension "https://github.com/melMass/comfy_mtb" "comfy_mtb" "MTB Nodes (Video Utils)"

# Advanced Vision & LLM Extensions
echo -e "${BLUE}👁️ Installing Vision & LLM Extensions...${NC}"

download_extension "https://github.com/ZHO-ZHO-ZHO/ComfyUI-Qwen2-VL" "ComfyUI-Qwen2-VL" "Qwen2.5-VL Integration"
download_extension "https://github.com/alisson-anjos/ComfyUI-Ollama-Describer" "ComfyUI-Ollama-Describer" "Ollama Image Describer"
download_extension "https://github.com/kijai/ComfyUI-Florence2" "ComfyUI-Florence2" "Florence2 Vision Model"

# Image Enhancement Extensions
echo -e "${BLUE}🖼️ Installing Image Enhancement Extensions...${NC}"

download_extension "https://github.com/ltdrdata/ComfyUI-Impact-Pack" "ComfyUI-Impact-Pack" "Advanced Image Processing"
download_extension "https://github.com/cubiq/ComfyUI_essentials" "ComfyUI_essentials" "Essential Image Tools"
download_extension "https://github.com/WASasquatch/was-node-suite-comfyui" "was-node-suite-comfyui" "WAS Node Suite"

# ControlNet Extensions
echo -e "${BLUE}🎮 Installing ControlNet Extensions...${NC}"

download_extension "https://github.com/Fannovel16/comfyui_controlnet_aux" "comfyui_controlnet_aux" "ControlNet Auxiliary"
download_extension "https://github.com/ltdrdata/ComfyUI-Inspire-Pack" "ComfyUI-Inspire-Pack" "Inspire Pack (ControlNet)"

echo -e "${BLUE}📦 Installing Python dependencies...${NC}"

# Create requirements file for container installation
cat > requirements_custom.txt << EOF
ollama>=0.3.0
opencv-python
imageio
imageio-ffmpeg
torchvision
accelerate
transformers
diffusers
controlnet-aux
insightface
onnxruntime
mediapipe
segment-anything
ultralytics
EOF

echo -e "${GREEN}✅ Custom nodes downloaded successfully!${NC}"
echo -e "${BLUE}📋 Next steps:${NC}"
echo "1. Run: docker compose restart"
echo "2. The container will automatically install Python dependencies"
echo "3. Access ComfyUI at http://localhost:8188"
echo "4. Install models using: ./download-models.sh"

echo -e "${YELLOW}💡 Tips:${NC}"
echo "• Use ComfyUI Manager to install additional nodes via web interface"
echo "• For Ollama: Set URL to http://YOUR-MACBOOK-IP:11434 in Ollama nodes"
echo "• Video models will be downloaded on first use"
echo "• Check ./logs.sh for any installation issues"
