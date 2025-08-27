#!/bin/bash

# Monitor Qwen model download progress
echo "Monitoring Qwen-Image-Edit model download..."
echo "Expected total size: ~54GB"
echo "Press Ctrl+C to stop monitoring"
echo ""

while true; do
    size=$(du -sh /Users/brynjenordli/git/image-editor/qwen-models-cache/ 2>/dev/null | cut -f1)
    container_status=$(docker compose -f image_editor_server/image_editor_server_server/docker-compose.yaml ps qwen-image-edit --format "{{.Status}}" 2>/dev/null)
    
    echo "$(date '+%H:%M:%S') - Downloaded: $size - Container: $container_status"
    
    # Check if we can curl the health endpoint
    if curl -s -m 2 http://localhost:8000/health > /dev/null 2>&1; then
        echo "🎉 Model loaded! Service is responding to health checks."
        break
    fi
    
    sleep 30
done
