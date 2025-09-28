#!/bin/bash

# ComfyUI Model Download Utility
# Supports interactive prompts or CLI flags for pulling essential model sets

set -e

echo "🎬 ComfyUI Model Download Utility"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create model directories once
ensure_directories() {
    echo -e "${BLUE}📁 Ensuring model directory structure...${NC}"
    mkdir -p models/{checkpoints,vae,loras,controlnet,upscale_models,clip_vision,unet,diffusion_models,text_encoders,animatediff_models,animatediff_motion_lora}
}

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

declare -A DOWNLOAD_SETS

DOWNLOAD_SETS[essential]="\
https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt models/checkpoints/v1-5-pruned-emaonly.ckpt Stable\ Diffusion\ 1.5 4.3GB
https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors models/checkpoints/sd_xl_base_1.0.safetensors SDXL\ Base\ 1.0 6.9GB
https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.ckpt models/vae/vae-ft-mse-840000-ema-pruned.ckpt SD\ VAE 335MB
https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors models/vae/sdxl_vae.safetensors SDXL\ VAE 335MB
"

DOWNLOAD_SETS[animatediff]="\
https://huggingface.co/guoyww/animatediff/resolve/main/mm_sd_v15_v2.ckpt models/animatediff_models/mm_sd_v15_v2.ckpt AnimateDiff\ SD1.5\ v2 1.8GB
https://huggingface.co/guoyww/animatediff/resolve/main/mm_sdxl_v10_beta.ckpt models/animatediff_models/mm_sdxl_v10_beta.ckpt AnimateDiff\ SDXL 1.8GB
https://huggingface.co/guoyww/animatediff/resolve/main/v3_sd15_mm.ckpt models/animatediff_motion_lora/v3_sd15_mm.ckpt AnimateDiff\ Motion\ LoRA\ v3 1.8GB
"

DOWNLOAD_SETS[controlnet]="\
https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_openpose.pth models/controlnet/control_v11p_sd15_openpose.pth ControlNet\ OpenPose 1.4GB
https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_canny.pth models/controlnet/control_v11p_sd15_canny.pth ControlNet\ Canny 1.4GB
"

DOWNLOAD_SETS[upscale]="\
https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth models/upscale_models/RealESRGAN_x4plus.pth RealESRGAN\ 4x 64MB
https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.4/RealESRGAN_x4plus_anime_6B.pth models/upscale_models/RealESRGAN_x4plus_anime_6B.pth RealESRGAN\ 4x\ Anime 18MB
"

DOWNLOAD_SETS[clip]="\
https://huggingface.co/laion/CLIP-ViT-H-14-laion2B-s32B-b79K/resolve/main/open_clip_pytorch_model.bin models/clip_vision/clip_vision_vit_h.safetensors CLIP\ Vision\ ViT-H 2.5GB
"

DOWNLOAD_SETS[wan]="\
https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors models/diffusion_models/wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors Wan2.2\ High\ Noise\ 14B\ FP8 ~14GB
https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors models/diffusion_models/wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors Wan2.2\ Low\ Noise\ 14B\ FP8 ~14GB
https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors UMT5\ XXL\ Text\ Encoder\ FP8 ~4.7GB
https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors models/vae/wan_2.1_vae.safetensors Wan\ 2.1\ VAE ~335MB
https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors models/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors Wan2.2\ Lightx2v\ LoRA\ (High) ~1.5GB
https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors models/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors Wan2.2\ Lightx2v\ LoRA\ (Low) ~1.5GB
"

download_set() {
    local key=$1
    local entries="${DOWNLOAD_SETS[$key]}"

    if [ -z "$entries" ]; then
        echo -e "${RED}❌ Unknown download set: $key${NC}"
        return 1
    fi

    echo -e "${BLUE}📦 Downloading set: $key${NC}"
    while read -r url path description size; do
        [ -z "$url" ] && continue
        download_model "$url" "$path" "$description" "$size"
    done <<< "$entries"
}

show_menu() {
    echo -e "${BLUE}📋 Choose what to download:${NC}"
    echo "1. Essential models (SD1.5, SDXL, VAEs)"
    echo "2. AnimateDiff bundle"
    echo "3. ControlNet + Upscalers"
    echo "4. Wan2.2 bundle (~35GB)"
    echo "5. Everything"
    echo "6. Quit"
    echo ""
    read -p "Enter choice (1-6): " choice

    case $choice in
        1) ensure_directories; download_set essential ;;
        2) ensure_directories; download_set animatediff ;;
        3) ensure_directories; download_set controlnet; download_set upscale; download_set clip ;;
        4) ensure_directories; download_set wan ;;
        5) ensure_directories; download_set essential; download_set animatediff; download_set controlnet; download_set upscale; download_set clip; download_set wan ;;
        6) echo "Bye"; exit 0 ;;
        *) echo -e "${RED}Invalid choice${NC}"; exit 1 ;;
    esac
}

parse_args() {
    local has_flag=false
    while [[ $# -gt 0 ]]; do
        case $1 in
            --essential) ensure_directories; download_set essential; has_flag=true ;;
            --animatediff) ensure_directories; download_set animatediff; has_flag=true ;;
            --controlnet) ensure_directories; download_set controlnet; ensure_directories; download_set upscale; download_set clip; has_flag=true ;;
            --wan) ensure_directories; download_set wan; has_flag=true ;;
            --all) ensure_directories; download_set essential; download_set animatediff; download_set controlnet; download_set upscale; download_set clip; download_set wan; has_flag=true ;;
            --help|-h)
                cat <<EOF
Usage: $0 [options]

Options:
  --essential   Download SD1.5/SDXL checkpoints plus VAEs
  --animatediff Download AnimateDiff checkpoints and motion LoRA
  --controlnet  Download ControlNet, upscalers, and CLIP Vision bundle
  --wan         Download Wan2.2 diffusion/text encoder/LoRA bundle (~35GB)
  --all         Download every supported model set
  -h, --help    Show this message

With no options the script starts an interactive selector.
EOF
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                exit 1
                ;;
        esac
        shift
    done

    if [ "$has_flag" = false ]; then
        show_menu
    fi
}

calculate_usage() {
    echo -e "${BLUE}📊 Disk usage summary:${NC}"
    for dir in checkpoints diffusion_models vae animatediff_models controlnet clip_vision upscale_models loras; do
        if [ -d "models/$dir" ]; then
            echo -e "${YELLOW}${dir}:${NC} $(du -sh "models/$dir" 2>/dev/null | cut -f1)"
        fi
    done
    if [ -d models ]; then
        echo -e "${YELLOW}💾 Total:${NC} $(du -sh models/ | cut -f1)"
    fi
}

ensure_directories
parse_args "$@"

echo -e "${GREEN}✅ Model downloads complete${NC}"
calculate_usage

echo -e "${BLUE}📋 Next steps:${NC}"
echo "1. Restart ComfyUI if it is running: ./stop.sh && ./run.sh"
echo "2. Inside the container install Python deps if prompted: docker exec -it comfyui-rocm-6.4.4 /app/setup.sh"
echo "3. Refresh ComfyUI to load the new models"

echo -e "${YELLOW}ℹ️ Model reference:${NC} see docs/models.md for detailed descriptions."

echo -e "${YELLOW}💡 Tips:${NC}"
echo "• SD1.5 for fastest inference; SDXL for quality"
echo "• Wan2.2 requires >21GB VRAM and long downloads"
echo "• AnimateDiff bundles provide video-ready motion LoRAs"
