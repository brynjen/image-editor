#!/bin/bash

# Comprehensive setup script for remote GPU server (RTX 4090)
# Sets up Docker, downloads models, and starts the AI service
# Based on HuggingFace DFloat11/Qwen-Image-Edit-DF11 implementation

set -e

# Add signal handling for graceful interruption
cleanup() {
    echo ""
    echo "🛑 Script interrupted. Cleaning up..."
    # Kill any background processes
    jobs -p | xargs -r kill 2>/dev/null || true
    # Remove temporary files
    rm -f /tmp/nvidia-gpgkey 2>/dev/null || true
    echo "🧹 Cleanup completed"
    exit 130
}

# Trap signals for graceful shutdown
trap cleanup SIGINT SIGTERM

echo "🚀 Setting up Remote GPU Server for Qwen Image Edit (DFloat11)"
echo "============================================================="
echo "📖 Based on: https://huggingface.co/DFloat11/Qwen-Image-Edit-DF11"

# Check if running on Ubuntu with GPU
echo "🔍 Checking for NVIDIA GPU and nvidia-smi command..."
echo "PATH: $PATH"
echo "Trying to locate nvidia-smi..."

# Try multiple ways to find nvidia-smi
NVIDIA_SMI=""
if command -v nvidia-smi &> /dev/null; then
    NVIDIA_SMI="nvidia-smi"
    echo "✅ Found nvidia-smi via 'command -v'"
elif [ -x "/usr/bin/nvidia-smi" ]; then
    NVIDIA_SMI="/usr/bin/nvidia-smi"
    echo "✅ Found nvidia-smi at /usr/bin/nvidia-smi"
elif [ -x "/usr/local/cuda/bin/nvidia-smi" ]; then
    NVIDIA_SMI="/usr/local/cuda/bin/nvidia-smi"
    echo "✅ Found nvidia-smi at /usr/local/cuda/bin/nvidia-smi"
else
    echo "❌ NVIDIA GPU driver/nvidia-smi not found. This script is for GPU servers."
    echo "🔍 Searched locations:"
    echo "  - PATH directories: $(echo $PATH | tr ':' '\n' | head -5)"
    echo "  - /usr/bin/nvidia-smi"
    echo "  - /usr/local/cuda/bin/nvidia-smi"
    echo ""
    echo "💡 Please ensure NVIDIA drivers are installed:"
    echo "   sudo apt update && sudo apt install nvidia-driver-535"
    echo "   # or appropriate driver version for your GPU"
    exit 1
fi

echo "✅ GPU detected:"
$NVIDIA_SMI --query-gpu=name,memory.total --format=csv,noheader,nounits

# Check GPU memory requirements
GPU_MEMORY=$($NVIDIA_SMI --query-gpu=memory.total --format=csv,noheader,nounits | head -n1)
if [ "$GPU_MEMORY" -lt 24000 ]; then
    echo "⚠️  Warning: GPU has ${GPU_MEMORY}MB memory. DFloat11 model recommends 24GB+ for optimal performance."
    echo "🔧 Will enable CPU offloading to reduce GPU memory usage."
    USE_CPU_OFFLOAD="true"
    CPU_OFFLOAD_BLOCKS="30"
else
    echo "✅ GPU has sufficient memory (${GPU_MEMORY}MB) for DFloat11 model."
    USE_CPU_OFFLOAD="false"
    CPU_OFFLOAD_BLOCKS="0"
fi

# Install Docker if not present
echo "🔍 Checking Docker installation..."
echo "PATH: $PATH"
echo "Trying to locate docker command..."

# Try multiple ways to find docker
DOCKER_CMD=""
if command -v docker &> /dev/null; then
    DOCKER_CMD="docker"
    echo "✅ Found docker via 'command -v'"
elif [ -x "/usr/bin/docker" ]; then
    DOCKER_CMD="/usr/bin/docker"
    echo "✅ Found docker at /usr/bin/docker"
elif [ -x "/usr/local/bin/docker" ]; then
    DOCKER_CMD="/usr/local/bin/docker"
    echo "✅ Found docker at /usr/local/bin/docker"
elif [ -x "/snap/bin/docker" ]; then
    DOCKER_CMD="/snap/bin/docker"
    echo "✅ Found docker at /snap/bin/docker (snap installation)"
else
    echo "❌ Docker not found in any common locations"
    echo "🔍 Searched locations:"
    echo "  - PATH directories: $(echo $PATH | tr ':' '\n' | head -5)"
    echo "  - /usr/bin/docker"
    echo "  - /usr/local/bin/docker"
    echo "  - /snap/bin/docker"
    echo ""
    echo "📦 Installing Docker..."
    
    # Check if we're being run with sudo (which can cause issues)
    if [ "$EUID" -eq 0 ]; then
        echo "⚠️  Running as root. Docker installation may have permission issues."
        echo "💡 Consider running this script as a regular user with sudo privileges."
    fi
    
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker installed successfully"
    echo "⚠️  You may need to log out and back in for Docker group membership to take effect"
    
    # Try to find docker again after installation
    if command -v docker &> /dev/null; then
        DOCKER_CMD="docker"
    elif [ -x "/usr/bin/docker" ]; then
        DOCKER_CMD="/usr/bin/docker"
    else
        echo "❌ Docker installation may have failed. Please check manually."
        exit 1
    fi
fi

# Now test Docker functionality
echo "🔧 Testing Docker functionality..."
if $DOCKER_CMD --version &> /dev/null; then
    DOCKER_VERSION=$($DOCKER_CMD --version 2>/dev/null || echo "unknown")
    echo "📋 Docker version: $DOCKER_VERSION"
    
    # Check if Docker daemon is running
    if sudo $DOCKER_CMD info &> /dev/null; then
        echo "✅ Docker daemon is running"
    else
        echo "⚠️  Docker is installed but daemon is not running"
        echo "🔧 Starting Docker daemon..."
        sudo systemctl start docker
        sudo systemctl enable docker
        sleep 2  # Give daemon time to start
        if sudo $DOCKER_CMD info &> /dev/null; then
            echo "✅ Docker daemon started successfully"
        else
            echo "❌ Failed to start Docker daemon. Please check manually:"
            echo "   sudo systemctl status docker"
            echo "   sudo journalctl -u docker.service"
            exit 1
        fi
    fi
else
    echo "❌ Docker command found but not functional"
    exit 1
fi

# Install NVIDIA Container Toolkit
echo "🔍 Checking NVIDIA Container Toolkit..."
if ! command -v nvidia-container-runtime &> /dev/null && ! command -v nvidia-ctk &> /dev/null; then
    echo "🔧 Installing NVIDIA Container Toolkit (using current method)..."
    
    # Get distribution info
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    echo "📋 Detected distribution: $distribution"
    
    # Use the new repository setup method (apt-key is deprecated)
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    
    # Update package list
    echo "📦 Updating package lists..."
    sudo apt-get update
    
    # Try to install nvidia-container-toolkit
    if sudo apt-get install -y nvidia-container-toolkit; then
        echo "✅ NVIDIA Container Toolkit installed successfully"
        
        # Configure Docker to use the toolkit
        echo "🔧 Configuring Docker to use NVIDIA Container Toolkit..."
        sudo nvidia-ctk runtime configure --runtime=docker
        sudo systemctl restart docker
        echo "✅ Docker configured for NVIDIA GPU support"
        
        # Verify installation
        if $DOCKER_CMD run --rm --gpus all nvidia/cuda:12.0-base-ubuntu20.04 nvidia-smi &> /dev/null; then
            echo "✅ GPU support in Docker verified"
        else
            echo "⚠️  GPU support installed but test failed. This might be normal if no CUDA image is available."
        fi
    else
        echo "❌ Failed to install nvidia-container-toolkit from repository"
        echo "🔄 Trying alternative installation method..."
        
        # Fallback: try installing nvidia-docker2 (older method)
        if sudo apt-get install -y nvidia-docker2; then
            echo "✅ Installed nvidia-docker2 (legacy support)"
            sudo systemctl restart docker
        else
            echo "❌ All NVIDIA Container Toolkit installation methods failed"
            echo "💡 Manual installation may be required. Please check:"
            echo "   - NVIDIA drivers are properly installed"
            echo "   - Repository is accessible: https://nvidia.github.io/libnvidia-container/"
            echo "   - Distribution '$distribution' is supported"
            echo ""
            echo "🔧 You can try manual installation:"
            echo "   curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg"
            echo "   echo 'deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://nvidia.github.io/libnvidia-container/stable/deb/\$(ARCH) /' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list"
            echo "   sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit"
            exit 1
        fi
    fi
else
    echo "✅ NVIDIA Container Toolkit already installed"
    # Verify it's configured with Docker
    if $DOCKER_CMD info 2>/dev/null | grep -q nvidia; then
        echo "✅ Docker is configured for NVIDIA GPU support"
    else
        echo "⚠️  NVIDIA Container Toolkit found but Docker may not be configured"
        echo "🔧 Configuring Docker..."
        if command -v nvidia-ctk &> /dev/null; then
            sudo nvidia-ctk runtime configure --runtime=docker
            sudo systemctl restart docker
            echo "✅ Docker reconfigured for NVIDIA GPU support"
        fi
    fi
fi

# Create project directory
PROJECT_DIR="$HOME/qwen-image-editor"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo "📁 Working in: $PROJECT_DIR"

# Download model using the HuggingFace DFloat11 approach
echo "🔍 Checking for existing DFloat11 models..."
if [ ! -d "qwen-models-cache" ]; then
    echo "📁 Creating qwen-models-cache directory..."
    mkdir -p qwen-models-cache
    NEED_DOWNLOAD=true
elif [ -z "$(ls -A qwen-models-cache 2>/dev/null)" ]; then
    echo "📁 qwen-models-cache directory is empty"
    NEED_DOWNLOAD=true
else
    # Check if we have the required model files
    echo "🔍 Checking existing model files..."
    QWEN_BASE_EXISTS=false
    DFLOAT11_EXISTS=false
    
    # Look for Qwen base model indicators
    if find qwen-models-cache -name "*Qwen*Image*Edit*" -type d | head -1 | grep -q .; then
        QWEN_BASE_EXISTS=true
        echo "✅ Found Qwen-Image-Edit base model"
    fi
    
    # Look for DFloat11 compressed model indicators  
    if find qwen-models-cache -name "*DFloat11*" -type d | head -1 | grep -q . || \
       find qwen-models-cache -name "*.dfloat11" -type f | head -1 | grep -q .; then
        DFLOAT11_EXISTS=true
        echo "✅ Found DFloat11 compressed model"
    fi
    
    # Calculate total cache size
    CACHE_SIZE=$(du -sh qwen-models-cache 2>/dev/null | cut -f1 || echo "unknown")
    echo "📊 Model cache size: $CACHE_SIZE"
    
    if [ "$QWEN_BASE_EXISTS" = true ] && [ "$DFLOAT11_EXISTS" = true ]; then
        echo "✅ Both required models found in cache - skipping download"
        NEED_DOWNLOAD=false
    else
        echo "⚠️  Incomplete model cache detected"
        if [ "$QWEN_BASE_EXISTS" = false ]; then
            echo "   - Missing: Qwen-Image-Edit base model"
        fi
        if [ "$DFLOAT11_EXISTS" = false ]; then
            echo "   - Missing: DFloat11 compressed model"
        fi
        echo "🔄 Will download missing models..."
        NEED_DOWNLOAD=true
    fi
fi

if [ "$NEED_DOWNLOAD" = true ]; then
    echo ""
    echo "❌ Required DFloat11 models not found!"
    echo "============================================"
    echo ""
    echo "📋 Missing models:"
    if [ "$QWEN_BASE_EXISTS" = false ]; then
        echo "   • Qwen-Image-Edit base model"
    fi
    if [ "$DFLOAT11_EXISTS" = false ]; then
        echo "   • DFloat11 compressed model"
    fi
    echo ""
    echo "📥 To download the required models (~28GB), please run:"
    echo ""
    echo "   python3 download-dfloat11-simple.py"
    echo ""
    echo "💡 This dedicated download script provides:"
    echo "   • Better progress reporting and logging"
    echo "   • Resumable downloads if interrupted"
    echo "   • Disk space validation"
    echo "   • Proper error handling and recovery"
    echo ""
    echo "⏱️  Expected download time: 30-60 minutes (depending on connection)"
    echo "💾 Required disk space: ~35GB free"
    echo ""
    echo "🔄 After download completes, re-run this setup script:"
    echo "   ./setup-remote-gpu-server.sh"
    echo ""
    echo "🛑 Setup script stopped - please download models first."
    exit 1
else
    echo "✅ All required models found in cache"
    echo "📊 Model cache size: $CACHE_SIZE"
fi

# Create optimized Docker Compose for RTX 4090
cat > docker-compose.gpu.yaml << EOF
services:
  qwen-image-edit:
    build: ./qwen-image-edit
    ports:
      - "8000:8000"
    environment:
      # Base model configuration
      - MODEL_NAME=Qwen/Qwen-Image-Edit
      - DEVICE=cuda  # Use RTX 4090 GPU
      
      # DFloat11 optimization settings (from HuggingFace example)
      - CPU_OFFLOAD=${USE_CPU_OFFLOAD}  # Optimize based on GPU memory
      - CPU_OFFLOAD_BLOCKS=${CPU_OFFLOAD_BLOCKS}  # Number of blocks to offload
      - PIN_MEMORY=true  # Enable memory pinning for faster transfers
      
      # Performance settings
      - MAX_CONCURRENT_REQUESTS=2  # RTX 4090 can handle multiple requests
      
      # HuggingFace cache directories
      - HF_HOME=/app/hf_cache
      - TRANSFORMERS_CACHE=/app/hf_cache
      - HF_DATASETS_CACHE=/app/hf_cache
      
    volumes:
      - ./qwen-models-cache:/app/hf_cache  # Persistent model storage
      - qwen_gpu_cache:/app/cache
      
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
      timeout: 15s
      retries: 3
      start_period: 300s  # Allow time for DFloat11 model loading
      
    restart: unless-stopped

volumes:
  qwen_gpu_cache:
EOF

# Create a test script for the GPU server
cat > test-gpu-server.py << 'EOF'
#!/usr/bin/env python3
"""Test script for RTX 4090 GPU server."""

import requests
import json

def test_gpu_server():
    """Test the GPU server health and capabilities."""
    print("🧪 Testing RTX 4090 GPU Server")
    print("=" * 40)
    
    try:
        response = requests.get("http://localhost:8000/health", timeout=10)
        if response.status_code == 200:
            health = response.json()
            print(f"✅ Status: {health['status']}")
            print(f"🤖 Model Loaded: {health['model_loaded']}")
            
            if 'model_info' in health:
                info = health['model_info']
                print(f"📦 Model: {info.get('model_name', 'unknown')}")
                print(f"💾 Device: {info.get('device', 'unknown')}")
                print(f"🔧 Type: {info.get('model_type', 'unknown')}")
                print(f"📏 Size: {info.get('estimated_size', 'unknown')}")
                print(f"🗜️  Compression: {info.get('compression_ratio', 'unknown')}")
            
            return True
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    test_gpu_server()
EOF

chmod +x test-gpu-server.py

echo ""
echo "🎉 Remote GPU Server Setup Completed!"
echo "====================================="
echo ""
echo "📋 Next Steps:"
echo "1. Copy the qwen-image-edit directory from your dev machine:"
echo "   scp -r /path/to/qwen-image-edit user@server:$PROJECT_DIR/"
echo ""
echo "2. Start the DFloat11 service on RTX 4090:"
echo "   cd $PROJECT_DIR"
echo "   docker compose -f docker-compose.gpu.yaml up --build --detach"
echo ""
echo "3. Test the service:"
echo "   python3 test-gpu-server.py"
echo "   # Or manually:"
echo "   curl http://localhost:8000/health"
echo ""
echo "4. Configure Flutter app to use this server:"
echo "   Host: $(hostname -I | awk '{print $1}')"
echo "   Port: 8000"
echo "   Protocol: HTTP"
echo ""
echo "🔥 Expected Performance (RTX 4090 + DFloat11):"
echo "   • Model Size: 28.43 GB (32% smaller than original)"
echo "   • GPU Memory: ~22-30 GB (depending on CPU offload)"
echo "   • Processing Time: ~280 seconds (A100 reference)"
echo "   • Quality: Bit-identical to original BFloat16 model"
echo ""
echo "📖 Based on: https://huggingface.co/DFloat11/Qwen-Image-Edit-DF11"