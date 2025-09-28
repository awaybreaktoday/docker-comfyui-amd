#!/bin/bash

# Legacy wrapper for full model download set
# Maintained for backward compatibility. Delegates to download-models.sh --all

set -e

echo "🚀 ComfyUI Complete Model Download"
echo "=================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$SCRIPT_DIR/download-models.sh" ]; then
    echo "❌ download-models.sh not found. Please upgrade your checkout."
    exit 1
fi

"$SCRIPT_DIR/download-models.sh" --all
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ All recommended models have been processed via download-models.sh"
else
    echo ""
    echo "⚠️ download-models.sh exited with status $EXIT_CODE"
fi

exit $EXIT_CODE
