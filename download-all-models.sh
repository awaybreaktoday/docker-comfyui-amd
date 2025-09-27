#!/bin/bash

# Complete Model Download Script for ComfyUI
# Downloads all essential models for image generation, video generation, and Wan2.2

set -e

echo "🚀 ComfyUI Complete Model Download"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to download with progress
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
    wget --progress=bar:force:noscroll -O "$output_path" "$url" || {
        echo -e "${RED}   ❌ Failed to download: $description${NC}"
        echo -e "${RED}   Please download manually from: $url${NC}"
        return 1
    }
    echo -e "${GREEN}   ✅ Downloaded: $(basename "$output_path")${NC}"
}

# Create all model directories
echo -e "${BLUE}📁 Creating model directory structure...${NC}"
mkdir -p models/{checkpoints,vae,loras,controlnet,upscale_models,clip_vision,diffusion_models,text_encoders,animatediff_models,animatediff_motion_lora}

# Show menu
echo -e "${BLUE}📋 Choose what to download:${NC}"
echo "1. Essential Models (SD1.5, SDXL, VAE) - ~12GB"
echo "2. Video Generation (AnimateDiff) - ~8GB"
echo "3. Wan2.2 Video Models (Official) - ~35GB"
echo "4. All Models - ~55GB total"
echo "5. Custom selection"

read -p "Enter choice (1-5): " choice

case $choice in
    1|4|5)
        echo -e "${BLUE}🎯 Downloading Essential Checkpoints...${NC}"

        # Stable Diffusion 1.5
        download_model \
            "https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt" \
            "models/checkpoints/v1-5-pruned-emaonly.ckpt" \
            "Stable Diffusion 1.5" \
            "4.3GB"

        # SDXL Base
        download_model \
            "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors" \
            "models/checkpoints/sd_xl_base_1.0.safetensors" \
            "SDXL Base 1.0" \
            "6.9GB"

        echo -e "${BLUE}🔧 Downloading VAE Models...${NC}"

        # SD VAE
        download_model \
            "https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.ckpt" \
            "models/vae/vae-ft-mse-840000-ema-pruned.ckpt" \
            "SD VAE" \
            "335MB"

        # SDXL VAE
        download_model \
            "https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors" \
            "models/vae/sdxl_vae.safetensors" \
            "SDXL VAE" \
            "335MB"
        ;;
esac

case $choice in
    2|4|5)
        echo -e "${BLUE}🎬 Downloading AnimateDiff Models...${NC}"

        # AnimateDiff SD1.5 v2
        download_model \
            "https://huggingface.co/guoyww/animatediff/resolve/main/mm_sd_v15_v2.ckpt" \
            "models/animatediff_models/mm_sd_v15_v2.ckpt" \
            "AnimateDiff SD1.5 v2" \
            "1.8GB"

        # Motion LoRA
        download_model \
            "https://huggingface.co/guoyww/animatediff/resolve/main/v3_sd15_mm.ckpt" \
            "models/animatediff_motion_lora/v3_sd15_mm.ckpt" \
            "AnimateDiff Motion LoRA v3" \
            "1.8GB"

        # DreamShaper (works well with AnimateDiff)
        download_model \
            "https://huggingface.co/Lykon/DreamShaper/resolve/main/DreamShaper_8_pruned.safetensors" \
            "models/checkpoints/DreamShaper_8_pruned.safetensors" \
            "DreamShaper V8" \
            "4.3GB"
        ;;
esac

case $choice in
    3|4)
        echo -e "${BLUE}🎬 Downloading Wan2.2 Official Models...${NC}"

        # Wan2.2 Diffusion Models
        download_model \
            "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors" \
            "models/diffusion_models/wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors" \
            "Wan2.2 T2V High Noise 14B FP8" \
            "~14GB"

        download_model \
            "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors" \
            "models/diffusion_models/wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors" \
            "Wan2.2 T2V Low Noise 14B FP8" \
            "~14GB"

        # Text Encoder
        download_model \
            "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
            "models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
            "UMT5 XXL Text Encoder FP8" \
            "~4.7GB"

        # Wan VAE
        download_model \
            "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" \
            "models/vae/wan_2.1_vae.safetensors" \
            "Wan 2.1 VAE" \
            "~335MB"

        # Speed LoRAs
        download_model \
            "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors" \
            "models/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors" \
            "Lightx2v 4-steps LoRA (High Noise)" \
            "~1.5GB"

        download_model \
            "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors" \
            "models/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors" \
            "Lightx2v 4-steps LoRA (Low Noise)" \
            "~1.5GB"
        ;;
esac

case $choice in
    5)
        echo -e "${YELLOW}Custom selection completed based on your choices above${NC}"
        ;;
esac

echo -e "${GREEN}✅ Model downloads completed!${NC}"

# Calculate disk usage
echo -e "${BLUE}📊 Disk usage summary:${NC}"
if [ -d "models/checkpoints" ]; then
    echo -e "${YELLOW}Checkpoints:${NC} $(du -sh models/checkpoints 2>/dev/null | cut -f1)"
fi
if [ -d "models/diffusion_models" ]; then
    echo -e "${YELLOW}Diffusion models:${NC} $(du -sh models/diffusion_models 2>/dev/null | cut -f1)"
fi
if [ -d "models/vae" ]; then
    echo -e "${YELLOW}VAE:${NC} $(du -sh models/vae 2>/dev/null | cut -f1)"
fi
if [ -d "models/animatediff_models" ]; then
    echo -e "${YELLOW}AnimateDiff:${NC} $(du -sh models/animatediff_models 2>/dev/null | cut -f1)"
fi
echo -e "${YELLOW}💾 Total:${NC} $(du -sh models/ | cut -f1)"

echo -e "${BLUE}📋 Next steps:${NC}"
echo "1. Restart ComfyUI (if running): ./stop.sh && ./run.sh"
echo "2. Install missing dependencies: docker exec -it comfyui-rocm-6.4.4 bash /app/setup.sh"
echo "3. Refresh ComfyUI browser (F5)"
echo "4. Load your workflows - models should be available"

echo -e "${YELLOW}💡 Usage Tips:${NC}"
echo "• For fast image generation: Use SD1.5 models"
echo "• For high quality: Use SDXL models (needs more VRAM)"
echo "• For video generation: Use AnimateDiff or Wan2.2 models"
echo "• Wan2.2: 640x640, ~21GB VRAM, 2-9 min per video"