#!/bin/bash
set -e

COMPOSE="docker compose"
IMAGE_TAG="${COMFYUI_IMAGE:-comfyui-rocm:local}"

echo "🔍 Checking for local image: $IMAGE_TAG"
if ! docker image inspect "$IMAGE_TAG" >/dev/null 2>&1; then
    echo "🏗️  Image not found. Building via docker compose..."
    $COMPOSE build
else
    echo "✅ Using existing image $IMAGE_TAG"
fi

echo "🚀 Starting ComfyUI..."
$COMPOSE up -d

echo "📋 Waiting for startup..."
sleep 5

echo "📊 Last 20 log lines:"
$COMPOSE logs --tail=20

cat <<EOF

✅ ComfyUI should now be running with ROCm 6.4.4 support.
🌐 Access: http://localhost:8188
📊 Follow logs: $COMPOSE logs -f
🛑 Stop: ./stop.sh

EOF
