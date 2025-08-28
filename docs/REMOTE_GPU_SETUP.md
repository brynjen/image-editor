# Remote GPU Server Setup

Guide for setting up the DFloat11 Qwen-Image-Edit model on a remote GPU server (RTX 4090) for use with the Image Editor project.

## 🎯 Overview

This setup allows you to:
- Run the AI model on a powerful remote GPU server (RTX 4090)
- Keep the development environment on your Mac (32GB RAM)
- Configure the Serverpod backend to communicate with the remote AI service
- Maintain full development workflow with remote processing

## 🖥️ Remote GPU Server Requirements

### Hardware
- **GPU**: RTX 4090 (24GB VRAM) ✅
- **RAM**: 50GB+ (for CPU offloading) 
- **Storage**: 30GB+ free space for model
- **Network**: Stable connection to development machine

### Software
- **OS**: Ubuntu 20.04+ with CUDA support
- **CUDA**: 11.8 or 12.x
- **Docker**: Latest version with NVIDIA Container Runtime
- **Python**: 3.10+

## 🚀 Installation Steps

### 1. Prepare Remote Server

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install CUDA (if not already installed)
wget https://developer.download.nvidia.com/compute/cuda/12.2/local_installers/cuda_12.2.0_535.54.03_linux.run
sudo sh cuda_12.2.0_535.54.03_linux.run

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install NVIDIA Container Runtime
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update && sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker

# Test NVIDIA Docker
sudo docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi
```

### 2. Clone Project on Remote Server

```bash
# Clone the repository
git clone <your-repo-url> image-editor
cd image-editor

# Create model cache directory
mkdir -p qwen-models-cache
```

### 3. Download DFloat11 Model

```bash
# Option 1: Use the monitoring script (recommended for overnight download)
nohup ./monitor-dfloat11-download.sh > dfloat11_download.log 2>&1 &

# Option 2: Manual download with Python
python3 -c "
from huggingface_hub import snapshot_download
import os

# Set cache directory
cache_dir = './qwen-models-cache'
os.makedirs(cache_dir, exist_ok=True)
os.environ['HF_HOME'] = cache_dir

# Download base model
print('Downloading base model...')
snapshot_download('Qwen/Qwen-Image-Edit', cache_dir=cache_dir)

# Download DFloat11 compressed weights
print('Downloading DFloat11 compressed weights...')
snapshot_download('DFloat11/Qwen-Image-Edit-DF11', cache_dir=cache_dir)

print('Download complete!')
"
```

### 4. Configure GPU Docker Service

Create `docker-compose.gpu.yaml`:

```yaml
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
```

### 5. Update Requirements for GPU

Update `qwen-image-edit/requirements.txt`:

```txt
torch>=2.0.0
torchvision>=0.15.0
git+https://github.com/huggingface/diffusers
transformers>=4.37.0
dfloat11[cuda12]>=0.1.0  # GPU version with CUDA 12
fastapi>=0.104.0
uvicorn>=0.24.0
pillow>=10.0.0
python-multipart>=0.0.6
pydantic>=2.4.0
requests>=2.31.0
numpy>=1.24.0
accelerate>=0.25.0
```

### 6. Start GPU Service

```bash
# Start the GPU service
docker compose -f docker-compose.gpu.yaml up --build --detach

# Monitor logs
docker compose -f docker-compose.gpu.yaml logs -f qwen-image-edit-gpu

# Check health
curl http://localhost:8000/health
```

## 🔧 Development Machine Configuration

### 1. Configure Remote AI Service

From your Mac development machine:

```bash
# Run the configuration script
./configure-remote-ai.sh
```

Or manually set environment variables:

```bash
# Set remote server IP (replace with your server's IP)
export AI_SERVICE_HOST=192.168.1.100  # Your RTX 4090 server IP
export AI_SERVICE_PORT=8000
export AI_SERVICE_SCHEME=http
export AI_SERVICE_TIMEOUT=60000  # 60 seconds for GPU processing
```

### 2. Update Development Config

Edit `image_editor_server/image_editor_server_server/config/development.yaml`:

```yaml
# AI Service Configuration
aiService:
  host: 192.168.1.100  # Your RTX 4090 server IP
  port: 8000
  scheme: http
  healthCheckPath: /health
  timeout: 60000  # 60 seconds for GPU processing
  maxRetries: 3
  retryDelay: 2000  # 2 seconds between retries
```

### 3. Test Connection

```bash
# Test from development machine
curl http://192.168.1.100:8000/health

# Expected response:
{
  "status": "healthy",
  "model_loaded": true,
  "model_info": {
    "model_name": "Qwen/Qwen-Image-Edit",
    "device": "cuda",
    "model_type": "dfloat11_compressed_diffusion_pipeline"
  }
}
```

## 🧪 Testing the Setup

### 1. Start Development Server

```bash
# On Mac - start Serverpod backend
cd image_editor_server/image_editor_server_server
source .env.ai  # If using environment file
docker compose up --build --detach  # Start database/redis
dart bin/main.dart --apply-migrations

# Expected log:
# Configuring AI service: http://192.168.1.100:8000
```

### 2. Test AI Service Health

```bash
# Test health endpoint
curl "http://localhost:8080/image/checkQwenHealth"

# Expected response:
{
  "qwen_service_healthy": true,
  "available_models": {...},
  "timestamp": "2025-01-XX..."
}
```

### 3. Test Full Workflow

```bash
# 1. Upload test image
curl -X POST "http://localhost:8080/image/uploadImage" \
  -F "filename=test.jpg" \
  -F "name=test.jpg" \
  -F "mimeType=image/jpeg" \
  -F "data=$(base64 -i test.jpg)"

# 2. Start async processing
curl -X POST "http://localhost:8080/image/processImageAsync" \
  -H "Content-Type: application/json" \
  -d '{
    "imageId": 1,
    "processorType": "qwen-image-edit",
    "instructions": "Add a red hat to the person"
  }'

# 3. Check job status
curl "http://localhost:8080/job/getJobStatus/1"
```

## 🔥 Performance Expectations

### With RTX 4090 + DFloat11:
- **Model Loading**: 2-5 minutes (first startup)
- **Processing Time**: 60-120 seconds per image
- **Memory Usage**: 
  - GPU: ~22GB VRAM (with CPU offloading)
  - CPU: ~50GB RAM (for offloaded components)
- **Concurrent Jobs**: 1-2 (depending on available VRAM)

### Network Requirements:
- **Bandwidth**: 10Mbps+ for image transfer
- **Latency**: <100ms between dev machine and GPU server
- **Stability**: Reliable connection for long processing jobs

## 🔒 Security Considerations

### Network Security
```bash
# Restrict access to AI service port
sudo ufw allow from 192.168.1.0/24 to any port 8000
sudo ufw deny 8000

# Use SSH tunneling for extra security
ssh -L 8000:localhost:8000 user@gpu-server
# Then use AI_SERVICE_HOST=localhost
```

### API Security
- Consider adding API keys for production
- Use HTTPS in production environments
- Monitor resource usage and implement rate limiting

## 🐛 Troubleshooting

### Common Issues

**1. CUDA Out of Memory**
```bash
# Reduce concurrent requests
environment:
  - MAX_CONCURRENT_REQUESTS=1
  - CPU_OFFLOAD=true
```

**2. Model Loading Timeout**
```bash
# Increase health check timeout
healthcheck:
  start_period: 900s  # 15 minutes
```

**3. Network Connection Issues**
```bash
# Check firewall
sudo ufw status
sudo ufw allow 8000

# Test connectivity
ping 192.168.1.100
telnet 192.168.1.100 8000
```

**4. Docker GPU Access**
```bash
# Verify NVIDIA runtime
docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi

# Check Docker daemon config
cat /etc/docker/daemon.json
```

### Monitoring Commands

```bash
# GPU usage
nvidia-smi -l 1

# Docker stats
docker stats qwen-image-edit-gpu

# Service logs
docker compose -f docker-compose.gpu.yaml logs -f qwen-image-edit-gpu

# Network connectivity
curl -v http://192.168.1.100:8000/health
```

## 📊 Monitoring Dashboard

Consider setting up monitoring:

```bash
# Install monitoring tools on GPU server
docker run -d \
  --name=nvidia-gpu-exporter \
  --restart=unless-stopped \
  --gpus all \
  -p 9835:9835 \
  utkuozdemir/nvidia_gpu_exporter:1.2.0
```

## 🔄 Maintenance

### Regular Tasks
- Monitor disk space (models are large)
- Update CUDA drivers periodically
- Backup model cache directory
- Monitor GPU temperature and usage
- Check for model updates

### Scaling Options
- Add multiple GPU servers with load balancing
- Implement job queuing for high demand
- Consider cloud GPU instances for peak usage
