# Lightweight ComfyUI container using host ROCm - UPDATED TO ROCM 6.4.4
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install Python and dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    wget \
    curl \
    libgl1-mesa-glx \
    libglib2.0-0 \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# Install latest PyTorch with ROCm 6.4 support (compatible with ROCm 6.4.4)
RUN pip install --upgrade pip && \
    pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.4

# Install ComfyUI requirements
RUN pip install -r requirements.txt

# Install MIGraphX extension
RUN cd custom_nodes && \
    git clone https://github.com/pnikolic-amd/ComfyUI_MIGraphX.git && \
    cd ComfyUI_MIGraphX && \
    pip install -r requirements.txt

# Create directories
RUN mkdir -p models/{checkpoints,vae,loras,controlnet,unet,clip,clip_vision,style_models,embeddings,diffusers,gligen,upscale_models} \
    && mkdir -p {output,input,temp,workflows}

EXPOSE 8188

# Startup script with enhanced diagnostics for ROCm 6.4.4
RUN echo '#!/bin/bash\n\
echo "=== ComfyUI with Host ROCm 6.4.4 (Latest) ==="\n\
echo "Container: Ubuntu 24.04 LTS"\n\
echo "PyTorch: Latest nightly with ROCm 6.4 (Host: 6.4.4)"\n\
echo "Consumer GPU Support: RX 7000/9000 series fully supported"\n\
echo "ROCm path: $ROCM_PATH"\n\
echo "Python: $(python --version)"\n\
echo ""\n\
echo "Checking ROCm 6.4.4 libraries..."\n\
ls -la /opt/rocm/lib/ | head -3 2>/dev/null || echo "ROCm libs not accessible"\n\
echo ""\n\
echo "PyTorch status:"\n\
python -c "import torch; print(f\"PyTorch: {torch.__version__}\"); print(f\"CUDA/ROCm available: {torch.cuda.is_available()}\"); print(f\"Device count: {torch.cuda.device_count()}\")" 2>/dev/null || echo "PyTorch check failed"\n\
echo ""\n\
if [ -f /opt/rocm/bin/rocm-smi ]; then\n\
    echo "GPU status (ROCm 6.4.4):"\n\
    /opt/rocm/bin/rocm-smi --showid 2>/dev/null || echo "rocm-smi failed"\n\
    echo ""\n\
fi\n\
echo "Starting ComfyUI on 0.0.0.0:8188..."\n\
echo "Note: Optimized for ROCm 6.4.4 with consumer GPU support"\n\
exec python main.py --listen 0.0.0.0 "$@"' > /app/start.sh && \
    chmod +x /app/start.sh

CMD ["/app/start.sh"]
