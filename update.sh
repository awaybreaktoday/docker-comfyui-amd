#!/bin/bash
echo "🔄 Rebuilding ComfyUI image..."
docker compose down
docker compose build --pull --no-cache
docker compose up -d
echo "✅ Updated!"
