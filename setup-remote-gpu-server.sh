#!/bin/bash

# Setup script for remote GPU server (RTX 4090)
# Run this on your Ubuntu machine with RTX 4090

echo "🚀 Setting up Remote GPU Server for DFloat11 Qwen-Image-Edit"
echo "============================================================="
echo ""

# Check if running on correct system
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "❌ This script is designed for Linux systems"
    echo "   Please run this on your Ubuntu RTX 4090 server"
    exit 1
fi

# Check for NVIDIA GPU
if ! command -v nvidia-smi &> /dev/null; then
    echo "❌ NVIDIA drivers not found"
    echo "   Please install NVIDIA drivers and CUDA first"
    exit 1
fi

echo "🔍 System Check:"
echo "   OS: $(lsb_release -d | cut -f2)"
echo "   GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader,nounits | head -1)"
echo "   CUDA: $(nvcc --version 2>/dev/null | grep release | cut -d' ' -f6 || echo 'Not found')"
echo ""

# Check disk space
available_space=$(df -h . | awk 'NR==2 {print $4}')
echo "💾 Available disk space: $available_space"

# Check if we have enough space (need ~35GB)
available_gb=$(df . | awk 'NR==2 {print $4}')
if [ $available_gb -lt 35000000 ]; then
    echo "⚠️  Warning: Low disk space. Need ~35GB for models."
    read -p "Continue anyway? [y/N]: " continue_anyway
    if [[ ! $continue_anyway =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""

# Step 1: Install Python dependencies
echo "📦 Step 1: Installing Python dependencies..."
if command -v pip3 &> /dev/null; then
    pip3 install -r download-requirements.txt
    if [ $? -eq 0 ]; then
        echo "✅ Python dependencies installed"
    else
        echo "❌ Failed to install Python dependencies"
        echo "   Try: sudo apt update && sudo apt install python3-pip"
        exit 1
    fi
else
    echo "❌ pip3 not found"
    echo "   Install with: sudo apt update && sudo apt install python3-pip"
    exit 1
fi

echo ""

# Step 2: Download models
echo "📥 Step 2: Downloading DFloat11 models..."
echo "   This will download ~28GB of data"
echo "   Estimated time: 30-60 minutes depending on connection"
echo ""

read -p "Start download now? [Y/n]: " start_download
if [[ ! $start_download =~ ^[Nn]$ ]]; then
    echo "🌐 Starting download..."
    python3 download-dfloat11-simple.py
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Models downloaded successfully!"
    else
        echo ""
        echo "❌ Download failed. Check the logs above."
        exit 1
    fi
else
    echo "⏭️  Skipping download. Run later with:"
    echo "   python3 download-dfloat11-simple.py"
fi

echo ""

# Step 3: Setup Docker (if not already installed)
echo "🐳 Step 3: Checking Docker installation..."
if command -v docker &> /dev/null; then
    echo "✅ Docker is installed: $(docker --version)"
    
    # Check if user is in docker group
    if groups $USER | grep &>/dev/null '\bdocker\b'; then
        echo "✅ User is in docker group"
    else
        echo "⚠️  Adding user to docker group..."
        sudo usermod -aG docker $USER
        echo "   Please log out and back in for group changes to take effect"
    fi
    
    # Check for NVIDIA Docker support
    if docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi &>/dev/null; then
        echo "✅ NVIDIA Docker support is working"
    else
        echo "❌ NVIDIA Docker support not working"
        echo "   Install with:"
        echo "   curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -"
        echo "   distribution=\$(. /etc/os-release;echo \$ID\$VERSION_ID)"
        echo "   curl -s -L https://nvidia.github.io/nvidia-docker/\$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list"
        echo "   sudo apt-get update && sudo apt-get install -y nvidia-docker2"
        echo "   sudo systemctl restart docker"
    fi
else
    echo "❌ Docker not found. Installing..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "   Please log out and back in, then re-run this script"
    exit 1
fi

echo ""

# Step 4: Test model loading
echo "🧪 Step 4: Testing model setup..."
if [ -d "./qwen-models-cache" ]; then
    cache_size=$(du -sh ./qwen-models-cache | cut -f1)
    echo "📊 Model cache size: $cache_size"
    
    # Quick verification
    python3 -c "
import sys
sys.path.append('.')
try:
    from pathlib import Path
    cache_dir = Path('./qwen-models-cache')
    
    base_models = list(cache_dir.glob('**/model_index.json'))
    dfloat11_dirs = list(cache_dir.glob('**/models--DFloat11--*'))
    
    print(f'📁 Base models found: {len(base_models)}')
    print(f'🗜️  DFloat11 models found: {len(dfloat11_dirs)}')
    
    if base_models and dfloat11_dirs:
        print('✅ Model verification passed!')
    else:
        print('❌ Model verification failed')
        sys.exit(1)
        
except Exception as e:
    print(f'❌ Verification error: {e}')
    sys.exit(1)
"
    
    if [ $? -eq 0 ]; then
        echo "✅ Model verification passed!"
    else
        echo "❌ Model verification failed"
        exit 1
    fi
else
    echo "❌ Model cache directory not found"
    echo "   Run the download first: python3 download-dfloat11-simple.py"
    exit 1
fi

echo ""

# Step 5: Create GPU docker-compose file
echo "📝 Step 5: Creating GPU docker-compose configuration..."
cat > docker-compose.gpu.yaml << 'EOF'
version: '3.8'

services:
  qwen-image-edit-gpu:
    build: ./qwen-image-edit
    ports:
      - "8000:8000"
    environment:
      - MODEL_NAME=Qwen/Qwen-Image-Edit
      - DEVICE=cuda
      - CPU_OFFLOAD=true
      - MAX_CONCURRENT_REQUESTS=2
      - HF_HOME=/app/hf_cache
      - TRANSFORMERS_CACHE=/app/hf_cache
      - HF_DATASETS_CACHE=/app/hf_cache
    volumes:
      - ./qwen-models-cache:/app/hf_cache
      - qwen_app_cache:/app/cache
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 600s  # 10 minutes for model loading
    restart: unless-stopped

volumes:
  qwen_app_cache:
EOF

echo "✅ Created docker-compose.gpu.yaml"

echo ""

# Step 6: Final instructions
echo "🎉 Setup Complete!"
echo "================"
echo ""
echo "📋 Next Steps:"
echo "1. Start the GPU service:"
echo "   docker compose -f docker-compose.gpu.yaml up --build --detach"
echo ""
echo "2. Monitor the logs (model loading takes 5-10 minutes):"
echo "   docker compose -f docker-compose.gpu.yaml logs -f qwen-image-edit-gpu"
echo ""
echo "3. Test the health endpoint:"
echo "   curl http://localhost:8000/health"
echo ""
echo "4. Configure your Mac development machine:"
echo "   ./configure-remote-ai.sh"
echo "   # Enter this server's IP address"
echo ""
echo "🔧 Server Info for Mac Configuration:"
echo "   IP Address: $(hostname -I | awk '{print $1}')"
echo "   Port: 8000"
echo "   Health URL: http://$(hostname -I | awk '{print $1}'):8000/health"
echo ""
echo "📊 Model Cache:"
echo "   Location: $(pwd)/qwen-models-cache"
echo "   Size: $(du -sh ./qwen-models-cache 2>/dev/null | cut -f1 || echo 'Not calculated')"
echo ""
echo "⚠️  Important: If you added user to docker group, please log out and back in!"
