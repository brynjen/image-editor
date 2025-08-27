#!/bin/bash

# Quick status check for DFloat11 model download
echo "🔍 DFloat11 Model Status Check"
echo "=============================="

CACHE_DIR="./qwen-models-cache"

if [ ! -d "$CACHE_DIR" ]; then
    echo "❌ Cache directory doesn't exist yet"
    exit 1
fi

echo "📊 Current cache size: $(du -sh "$CACHE_DIR" | cut -f1)"
echo ""

# Check for base model
base_model_files=$(find "$CACHE_DIR" -name "model_index.json" 2>/dev/null | wc -l)
echo "📁 Base model (Qwen/Qwen-Image-Edit): $([ $base_model_files -gt 0 ] && echo "✅ Found" || echo "❌ Missing")"

# Check for DFloat11 model
dfloat11_model_dir=$(find "$CACHE_DIR" -name "models--DFloat11--*" -type d 2>/dev/null | wc -l)
echo "🗜️  DFloat11 compressed model: $([ $dfloat11_model_dir -gt 0 ] && echo "✅ Found" || echo "❌ Missing")"

if [ $dfloat11_model_dir -gt 0 ]; then
    dfloat11_files=$(find "$CACHE_DIR" -path "*/models--DFloat11--*" -name "*.bin" -o -path "*/models--DFloat11--*" -name "*.safetensors" 2>/dev/null | wc -l)
    echo "   📦 DFloat11 model files: $dfloat11_files"
fi

echo ""

# Overall status
if [ $base_model_files -gt 0 ] && [ $dfloat11_model_dir -gt 0 ]; then
    echo "🎉 Status: COMPLETE - Both models are downloaded!"
    echo "🚀 Ready to run: ./monitor-dfloat11-download.sh (will test the model)"
else
    echo "⏳ Status: INCOMPLETE - Missing components"
    echo "🌙 To download: ./monitor-dfloat11-download.sh (overnight recommended)"
fi

# Check if download is currently running
if pgrep -f "temp_comprehensive_download\|temp_docker_download\|download-dfloat11" > /dev/null; then
    echo "🔄 Download process is currently running"
fi
