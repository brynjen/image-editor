#!/bin/bash

# Monitor DFloat11 Qwen model download progress
# Usage: Run from the project root directory (image-editor/)
#   ./monitor-dfloat11-download.sh

echo "🌙 DFloat11 Model Downloader & Monitor (Overnight Edition)"
echo "========================================================"
echo "Expected total size: ~28GB (32% smaller than original 41GB)"
echo "Components: Base model (Qwen/Qwen-Image-Edit) + Compressed weights (DFloat11/Qwen-Image-Edit-DF11)"
echo "⚠️  This will use significant bandwidth - ideal for overnight download"
echo "Press Ctrl+C to stop"
echo ""

CACHE_DIR="./qwen-models-cache"
LOG_FILE="dfloat11_download.log"

# Function to log with timestamp
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check if download is complete
is_download_complete() {
    if [ -d "$CACHE_DIR" ]; then
        # Check for base model
        base_model_files=$(find "$CACHE_DIR" -name "model_index.json" 2>/dev/null | wc -l)
        
        # Check for DFloat11 compressed model (look for models--DFloat11 directory)
        dfloat11_model_dir=$(find "$CACHE_DIR" -name "models--DFloat11--*" -type d 2>/dev/null | wc -l)
        
        if [ "$base_model_files" -gt 0 ] && [ "$dfloat11_model_dir" -gt 0 ]; then
            # Double check by looking for actual model files in DFloat11 directory
            dfloat11_files=$(find "$CACHE_DIR" -path "*/models--DFloat11--*" -name "*.bin" -o -path "*/models--DFloat11--*" -name "*.safetensors" 2>/dev/null | wc -l)
            if [ "$dfloat11_files" -gt 0 ]; then
                return 0  # Complete
            fi
        fi
    fi
    return 1  # Not complete
}

# Function to start download
start_download() {
    log_message "🚀 Starting comprehensive DFloat11 model download..."
    
    # Check available space first
    available_space=$(df -h . | awk 'NR==2 {print $4}')
    log_message "💾 Available disk space: $available_space"
    
    # Create a comprehensive download script that ensures both models are downloaded
    cat > temp_comprehensive_download.py << 'EOF'
import os
import sys
from pathlib import Path
from huggingface_hub import snapshot_download
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def main():
    cache_dir = Path("./qwen-models-cache")
    cache_dir.mkdir(exist_ok=True)
    
    # Set environment variables
    os.environ['HF_HOME'] = str(cache_dir)
    os.environ['TRANSFORMERS_CACHE'] = str(cache_dir)
    os.environ['HF_DATASETS_CACHE'] = str(cache_dir)
    
    models_to_download = [
        ("Qwen/Qwen-Image-Edit", "Base Qwen-Image-Edit model"),
        ("DFloat11/Qwen-Image-Edit-DF11", "DFloat11 compressed weights")
    ]
    
    for repo_id, description in models_to_download:
        try:
            logger.info(f"📥 Downloading {description} ({repo_id})...")
            model_path = snapshot_download(
                repo_id=repo_id,
                cache_dir=cache_dir,
                resume_download=True,
                local_files_only=False,
            )
            logger.info(f"✅ {description} downloaded to: {model_path}")
        except Exception as e:
            logger.error(f"❌ Failed to download {description}: {e}")
            sys.exit(1)
    
    logger.info("🎉 All models downloaded successfully!")

if __name__ == "__main__":
    main()
EOF
    
    # Try Docker-based download first (recommended)
    if command -v docker &> /dev/null; then
        log_message "📦 Using Docker-based comprehensive download"
        
        # Create comprehensive Docker download
        cat > temp_docker_download.py << 'EOF'
import subprocess
import sys
from pathlib import Path

def main():
    cache_dir = Path("./qwen-models-cache").absolute()
    
    # Create temporary Dockerfile for comprehensive download
    dockerfile_content = '''
FROM python:3.10-slim

WORKDIR /app
RUN apt-get update && apt-get install -y git wget curl && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir huggingface_hub torch transformers

COPY temp_comprehensive_download.py /app/download_script.py
CMD ["python", "download_script.py"]
'''
    
    temp_dir = Path("temp_download")
    temp_dir.mkdir(exist_ok=True)
    
    with open(temp_dir / "Dockerfile", 'w') as f:
        f.write(dockerfile_content)
    
    # Copy the download script
    subprocess.run(['cp', 'temp_comprehensive_download.py', str(temp_dir / 'temp_comprehensive_download.py')])
    
    try:
        # Build and run
        subprocess.run(['docker', 'build', '-t', 'dfloat11-comprehensive', str(temp_dir)], check=True)
        subprocess.run(['docker', 'run', '--rm', '-v', f'{cache_dir}:/app/qwen-models-cache', 'dfloat11-comprehensive'], check=True)
        
        print("🎉 Comprehensive download completed!")
        
    finally:
        # Cleanup
        import shutil
        if temp_dir.exists():
            shutil.rmtree(temp_dir)
        subprocess.run(['docker', 'rmi', 'dfloat11-comprehensive'], capture_output=True)

if __name__ == "__main__":
    main()
EOF
        
        python3 temp_docker_download.py > download_output.log 2>&1 &
        DOWNLOAD_PID=$!
        log_message "Docker-based comprehensive download started with PID: $DOWNLOAD_PID"
        
    else
        log_message "⚠️  Docker not available, using direct Python download..."
        log_message "💡 Note: Ensure required packages are installed: pip install -r download-requirements.txt"
        
        python3 temp_comprehensive_download.py > download_output.log 2>&1 &
        DOWNLOAD_PID=$!
        log_message "Direct Python download started with PID: $DOWNLOAD_PID"
    fi
}

# Cleanup function for graceful shutdown
cleanup() {
    log_message "🛑 Received interrupt signal, cleaning up..."
    
    # Kill download processes
    if [ ! -z "$DOWNLOAD_PID" ]; then
        kill $DOWNLOAD_PID 2>/dev/null
        log_message "Stopped download process (PID: $DOWNLOAD_PID)"
    fi
    
    # Clean up temporary files
    rm -f temp_comprehensive_download.py temp_docker_download.py download_output.log 2>/dev/null
    
    log_message "🧹 Cleanup completed"
    exit 0
}

# Set up signal handlers for graceful shutdown
trap cleanup SIGINT SIGTERM

# Check if download is already complete
if is_download_complete; then
    log_message "✅ Both models appear to be already downloaded!"
    size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
    log_message "📊 Current cache size: $size"
    
    # Try to start the container to test the model
    log_message "🚀 Attempting to start qwen-image-edit container for testing..."
    cd image_editor_server/image_editor_server_server
    docker compose up -d qwen-image-edit
    cd ../..
else
    # Check if download is already running
    if pgrep -f "temp_comprehensive_download\|temp_docker_download" > /dev/null; then
        log_message "🔄 Download already running..."
    else
        log_message "📥 Starting comprehensive download (both base model and DFloat11 compressed weights)..."
        start_download
        sleep 10  # Give download time to start
    fi
fi

log_message "🔍 Starting monitoring loop (updates every 60 seconds for overnight efficiency)..."
echo ""

# Main monitoring loop
LOOP_COUNT=0
while true; do
    LOOP_COUNT=$((LOOP_COUNT + 1))
    size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
    
    # Check if download processes are running
    download_running=""
    if pgrep -f "temp_comprehensive_download\|temp_docker_download" > /dev/null; then
        download_running="(Download active)"
    fi
    
    # Every 10th loop (10 minutes), show more detailed status
    if [ $((LOOP_COUNT % 10)) -eq 0 ]; then
        log_message "📊 Detailed Status Check (#$LOOP_COUNT):"
        if [ -d "$CACHE_DIR" ]; then
            base_model_count=$(find "$CACHE_DIR" -name "model_index.json" 2>/dev/null | wc -l)
            dfloat11_model_count=$(find "$CACHE_DIR" -name "models--DFloat11--*" -type d 2>/dev/null | wc -l)
            log_message "   📁 Base models found: $base_model_count"
            log_message "   🗜️  DFloat11 models found: $dfloat11_model_count"
            log_message "   💾 Current size: $size"
            
            if [ -f "download_output.log" ]; then
                last_log=$(tail -n 1 download_output.log 2>/dev/null)
                if [ ! -z "$last_log" ]; then
                    log_message "   📝 Last download log: $last_log"
                fi
            fi
        fi
    else
        echo "$(date '+%H:%M:%S') - Size: $size $download_running"
    fi
    
    # Check if download is complete
    if is_download_complete; then
        log_message "🎉 Download completed! Both models are now available."
        log_message "📊 Final cache size: $size"
        
        # Try to start the container
        log_message "🚀 Starting qwen-image-edit container to test the model..."
        cd image_editor_server/image_editor_server_server
        docker compose build qwen-image-edit
        docker compose up -d qwen-image-edit
        cd ../..
        
        # Wait a bit and test health endpoint
        log_message "⏳ Waiting for container to initialize..."
        sleep 30
        
        if curl -s -m 5 http://localhost:8000/health > /dev/null 2>&1; then
            log_message "✅ SUCCESS! DFloat11 Model loaded and service is responding!"
            log_message "🎊 Ready to process images with 32% compressed model"
            break
        else
            log_message "⚠️  Model downloaded but container not responding yet. Check logs with: docker compose logs qwen-image-edit"
        fi
        break
    fi
    
    # Sleep for 60 seconds (efficient for overnight monitoring)
    sleep 60
done

# Final cleanup
cleanup
