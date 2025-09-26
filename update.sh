#!/bin/bash
echo "🔄 Updating ComfyUI..."
docker-compose down
docker-compose build --no-cache
docker-compose up -d
echo "✅ Updated!"
