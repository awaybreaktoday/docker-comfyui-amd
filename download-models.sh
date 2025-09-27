#!/bin/bash

# ComfyUI Models Download Script
# Downloads essential models for video generation and image processing

set -e

echo "🎬 ComfyUI Models Download Script"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create model directories
echo -e "${BLUE}📁 Creating model directory structure...${NC}"
mkdir -p models/{checkpoints,vae,loras,controlnet,upscale_models,clip_vision,unet,animatediff_models,animatediff_motion_lora}

# Function to download file with progress
download_model() {
    local url=$1
    local output_path=$2
    local description=$3
    local size=$4

    echo -e "${YELLOW}⬇️  Downloading: $description ($size)${NC}"

    if [ -f "$output_path" ]; then
        echo -e "${GREEN}   ✅ Already exists: $(basename "$output_path")${NC}"
        return
    fi

    echo -e "${BLUE}   URL: $url${NC}"
    wget --progress=bar:force:noscroll -O "$output_path" "$url"
    echo -e "${GREEN}   ✅ Downloaded: $(basename "$output_path")${NC}"
}

# Essential Checkpoints
echo -e "${BLUE}🎯 Downloading Essential Checkpoints...${NC}"

download_model \
    "https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt" \
    "models/checkpoints/v1-5-pruned-emaonly.ckpt" \
    "Stable Diffusion 1.5" \
    "4.3GB"

download_model \
    "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors" \
    "models/checkpoints/sd_xl_base_1.0.safetensors" \
    "SDXL Base 1.0" \
    "6.9GB"

# VAE Models
echo -e "${BLUE}🔧 Downloading VAE Models...${NC}"

download_model \
    "https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.ckpt" \
    "models/vae/vae-ft-mse-840000-ema-pruned.ckpt" \
    "SD VAE" \
    "335MB"

download_model \
    "https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors" \
    "models/vae/sdxl_vae.safetensors" \
    "SDXL VAE" \
    "335MB"

# AnimateDiff Models
echo -e "${BLUE}🎬 Downloading AnimateDiff Models...${NC}"

download_model \
    "https://huggingface.co/guoyww/animatediff/resolve/main/mm_sd_v15_v2.ckpt" \
    "models/animatediff_models/mm_sd_v15_v2.ckpt" \
    "AnimateDiff SD1.5 v2" \
    "1.8GB"

download_model \
    "https://huggingface.co/guoyww/animatediff/resolve/main/mm_sdxl_v10_beta.ckpt" \
    "models/animatediff_models/mm_sdxl_v10_beta.ckpt" \
    "AnimateDiff SDXL" \
    "1.8GB"

# Motion LoRA for AnimateDiff
echo -e "${BLUE}🎭 Downloading Motion LoRA Models...${NC}"

download_model \
    "https://huggingface.co/guoyww/animatediff/resolve/main/v3_sd15_mm.ckpt" \
    "models/animatediff_motion_lora/v3_sd15_mm.ckpt" \
    "AnimateDiff Motion LoRA v3" \
    "1.8GB"

# ControlNet Models
echo -e "${BLUE}🎮 Downloading ControlNet Models...${NC}"

download_model \
    "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_openpose.pth" \
    "models/controlnet/control_v11p_sd15_openpose.pth" \
    "ControlNet OpenPose" \
    "1.4GB"

download_model \
    "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_canny.pth" \
    "models/controlnet/control_v11p_sd15_canny.pth" \
    "ControlNet Canny" \
    "1.4GB"

# Upscale Models
echo -e "${BLUE}📈 Downloading Upscale Models...${NC}"

download_model \
    "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth" \
    "models/upscale_models/RealESRGAN_x4plus.pth" \
    "RealESRGAN 4x" \
    "64MB"

download_model \
    "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.4/RealESRGAN_x4plus_anime_6B.pth" \
    "models/upscale_models/RealESRGAN_x4plus_anime_6B.pth" \
    "RealESRGAN 4x Anime" \
    "18MB"

# CLIP Vision (for advanced workflows)
echo -e "${BLUE}👁️ Downloading CLIP Vision Models...${NC}"

download_model \
    "https://huggingface.co/laion/CLIP-ViT-H-14-laion2B-s32B-b79K/resolve/main/open_clip_pytorch_model.bin" \
    "models/clip_vision/clip_vision_vit_h.safetensors" \
    "CLIP Vision ViT-H" \
    "2.5GB"

echo -e "${GREEN}✅ Model downloads completed!${NC}"

# Calculate total disk usage
echo -e "${BLUE}📊 Calculating disk usage...${NC}"
total_size=$(du -sh models/ | cut -f1)
echo -e "${YELLOW}💾 Total models size: $total_size${NC}"

echo -e "${BLUE}📋 Next steps:${NC}"
echo "1. Start ComfyUI: ./run.sh"
echo "2. Models are now available in ComfyUI workflows"
echo "3. For video generation, look for AnimateDiff nodes"
echo "4. For Ollama integration, use the Ollama nodes with your MacBook IP"

echo -e "${YELLOW}💡 Video Generation Tips:${NC}"
echo "• Use AnimateDiff with motion LoRA for smooth videos"
echo "• SDXL models provide higher quality but require more VRAM"
echo "• ControlNet helps guide video generation with poses/edges"
echo "• Start with 16-frame videos, increase as needed"

echo -e "${YELLOW}🔗 Recommended Ollama Models:${NC}"
echo "• qwen2.5-vl:7b (best vision model for descriptions)"
echo "• llava:13b (reliable backup vision model)"
echo "• llama3.1:8b (fast text prompt enhancement)"