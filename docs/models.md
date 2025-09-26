# Model Setup Guide - Updated for Latest Versions

Place your models in the appropriate directories:

## Required Directories
- `models/checkpoints/` - Main diffusion models (.safetensors, .ckpt)
- `models/vae/` - VAE models
- `models/loras/` - LoRA files
- `models/controlnet/` - ControlNet models
- `models/clip/` - CLIP models
- `models/unet/` - U-Net models

## Latest Popular Models to Download

### 1. **Stable Diffusion 3 Medium** (Latest)
   - Download from: https://huggingface.co/stabilityai/stable-diffusion-3-medium
   - File: `sd3_medium_incl_clips.safetensors`
   - Works great with MIGraphX extension!

### 2. **SDXL Base 1.0**
   - Download from: https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0
   - File: `sd_xl_base_1.0.safetensors`

### 3. **Stable Diffusion 1.5** (Classic)
   - Download from: https://huggingface.co/runwayml/stable-diffusion-v1-5
   - File: `v1-5-pruned-emaonly.safetensors`

### 4. **Flux Models** (Latest Architecture)
   - Flux.1 Dev: https://huggingface.co/black-forest-labs/FLUX.1-dev
   - Flux.1 Schnell: https://huggingface.co/black-forest-labs/FLUX.1-schnell

## Download Commands
```bash
cd models/checkpoints

# Stable Diffusion 1.5 (Always works)
wget https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors

# SDXL Base (High quality)
wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors

# For SD3 Medium, you'll need to accept terms on Hugging Face first
```

## Performance Tips with Latest Setup

### MIGraphX Optimization
With PyTorch 2.7.1 and the latest MIGraphX extension:
- First run will be slower (model optimization)
- Subsequent runs will be much faster
- Works best with SD3 Medium model

### GPU Memory Management
The latest PyTorch has improved memory handling:
- Better memory allocation for large models
- Enhanced garbage collection
- Support for mixed precision on AMD GPUs

### Recommended Models for AMD GPUs
1. **SD3 Medium** - Best performance with MIGraphX
2. **SDXL Base** - Good balance of quality and speed
3. **SD 1.5** - Fastest generation, lower VRAM usage

After adding models, restart the container for them to be detected:
```bash
./stop.sh && ./run.sh
```

## Troubleshooting Model Issues

### Model Not Loading
- Check file permissions: `ls -la models/checkpoints/`
- Verify file integrity (not corrupted download)
- Check container logs: `./logs.sh`

### Out of Memory Errors
- Use smaller models (SD 1.5 instead of SDXL)
- Reduce batch size in ComfyUI
- Enable model offloading in ComfyUI settings

### Slow Generation
- Wait for MIGraphX optimization (first few runs)
- Use VAE tiling for large images
- Check GPU utilization: `rocm-smi`

## New Features with Latest Stack

### Enhanced VAE Support
- Better VAE handling in PyTorch 2.7.1
- Improved color accuracy
- Faster VAE encoding/decoding

### ControlNet Improvements
- Better compatibility with latest models
- Improved preprocessing
- Enhanced performance on AMD GPUs

### LoRA Support
- Faster LoRA loading
- Better memory management
- Support for larger LoRA files
