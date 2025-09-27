# Optimized ComfyUI container using host ROCm - Reduced size version
FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install build dependencies in one layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

WORKDIR /app

# Create virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install PyTorch and dependencies with no cache
RUN pip install --upgrade --no-cache-dir pip wheel && \
    pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.4

# Clone ComfyUI and remove git history to save space
RUN git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git . && \
    rm -rf .git

# Install ComfyUI requirements
RUN pip install --no-cache-dir -r requirements.txt

# Install MIGraphX extension without git history
RUN cd custom_nodes && \
    git clone --depth 1 https://github.com/pnikolic-amd/ComfyUI_MIGraphX.git && \
    cd ComfyUI_MIGraphX && \
    pip install --no-cache-dir -r requirements.txt && \
    rm -rf .git

# Clean up pip cache
RUN pip cache purge 2>/dev/null || true

# Final stage - minimal runtime image
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PATH="/opt/venv/bin:$PATH"

# Install only runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    libgl1-mesa-dri \
    libglib2.0-0 \
    libgomp1 \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove -y

WORKDIR /app

# Copy virtual environment and app from builder
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app /app

# Create necessary directories
RUN mkdir -p models/checkpoints models/vae models/loras models/controlnet models/unet \
    models/clip models/clip_vision models/style_models models/embeddings \
    models/diffusers models/gligen models/upscale_models \
    output input temp workflows

EXPOSE 8188

# Minimal startup script
RUN echo '#!/bin/bash\n\
echo "=== ComfyUI with Host ROCm (Optimized) ==="\n\
echo "Container: Ubuntu 24.04 LTS (Minimal)"\n\
echo "PyTorch: Stable with ROCm 6.4"\n\
echo "Python: $(python --version)"\n\
echo ""\n\
python -c "import torch; print(f\"PyTorch: {torch.__version__}\"); print(f\"ROCm available: {torch.cuda.is_available()}\")" 2>/dev/null || echo "PyTorch check failed"\n\
echo ""\n\
echo "Starting ComfyUI on 0.0.0.0:8188..."\n\
exec python main.py --listen 0.0.0.0 "$@"' > /app/start.sh && \
    chmod +x /app/start.sh

CMD ["/app/start.sh"]