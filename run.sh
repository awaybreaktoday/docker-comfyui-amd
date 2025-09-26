#!/bin/bash
echo "🏗️  Building ComfyUI container with ROCm 6.4.4 support..."
docker-compose build

echo "🚀 Starting ComfyUI..."
docker-compose up -d

echo "📋 Waiting for startup..."
sleep 5

echo "📊 Container logs:"
docker-compose logs --tail=20

echo ""
echo "✅ ComfyUI should be running with ROCm 6.4.4 support!"
echo "🌐 Access at: http://localhost:8188"
echo "📊 View logs: docker-compose logs -f"
echo "🛑 Stop: docker-compose down"
echo ""
echo "🆕 This version includes:"
echo "   - Ubuntu 24.04 LTS (Noble Numbat)"
echo "   - PyTorch with ROCm 6.4 (compatible with host ROCm 6.4.4)"
echo "   - Full consumer GPU support (RX 7000/9000 series)"
echo "   - Enhanced performance optimizations"
echo "   - MIGraphX extension for AMD GPU acceleration"
