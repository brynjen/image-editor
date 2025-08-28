#!/bin/bash

# Configure Remote AI Service for Image Editor
# This script helps configure the Serverpod backend to use a remote AI processing server

echo "🤖 Image Editor - Remote AI Configuration"
echo "=========================================="
echo ""

# Get current configuration
CURRENT_HOST=${AI_SERVICE_HOST:-localhost}
CURRENT_PORT=${AI_SERVICE_PORT:-8000}
CURRENT_SCHEME=${AI_SERVICE_SCHEME:-http}

echo "📋 Current Configuration:"
echo "   Host: $CURRENT_HOST"
echo "   Port: $CURRENT_PORT"
echo "   Scheme: $CURRENT_SCHEME"
echo "   Full URL: $CURRENT_SCHEME://$CURRENT_HOST:$CURRENT_PORT"
echo ""

# Ask user for configuration
echo "🔧 Configure Remote AI Service:"
echo ""

read -p "Enter AI service host (current: $CURRENT_HOST): " NEW_HOST
NEW_HOST=${NEW_HOST:-$CURRENT_HOST}

read -p "Enter AI service port (current: $CURRENT_PORT): " NEW_PORT
NEW_PORT=${NEW_PORT:-$CURRENT_PORT}

read -p "Enter AI service scheme [http/https] (current: $CURRENT_SCHEME): " NEW_SCHEME
NEW_SCHEME=${NEW_SCHEME:-$CURRENT_SCHEME}

echo ""
echo "🎯 New Configuration:"
echo "   Host: $NEW_HOST"
echo "   Port: $NEW_PORT"
echo "   Scheme: $NEW_SCHEME"
echo "   Full URL: $NEW_SCHEME://$NEW_HOST:$NEW_PORT"
echo ""

# Test connection
echo "🔍 Testing connection to AI service..."
HEALTH_URL="$NEW_SCHEME://$NEW_HOST:$NEW_PORT/health"

if command -v curl &> /dev/null; then
    echo "Testing: $HEALTH_URL"
    if curl -s --connect-timeout 10 --max-time 30 "$HEALTH_URL" > /dev/null 2>&1; then
        echo "✅ Connection successful!"
        
        # Try to get health status
        HEALTH_RESPONSE=$(curl -s --connect-timeout 10 --max-time 30 "$HEALTH_URL" 2>/dev/null)
        if [ $? -eq 0 ]; then
            echo "📊 Health Response:"
            echo "$HEALTH_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$HEALTH_RESPONSE"
        fi
    else
        echo "❌ Connection failed!"
        echo "   Make sure the AI service is running on $NEW_HOST:$NEW_PORT"
        echo "   Check firewall settings and network connectivity"
    fi
else
    echo "⚠️  curl not found, skipping connection test"
fi

echo ""

# Ask for confirmation
read -p "Apply this configuration? [y/N]: " CONFIRM
if [[ $CONFIRM =~ ^[Yy]$ ]]; then
    # Create environment file
    ENV_FILE=".env.ai"
    echo "# AI Service Configuration" > "$ENV_FILE"
    echo "# Generated on $(date)" >> "$ENV_FILE"
    echo "AI_SERVICE_HOST=$NEW_HOST" >> "$ENV_FILE"
    echo "AI_SERVICE_PORT=$NEW_PORT" >> "$ENV_FILE"
    echo "AI_SERVICE_SCHEME=$NEW_SCHEME" >> "$ENV_FILE"
    echo "AI_SERVICE_TIMEOUT=30000" >> "$ENV_FILE"
    echo "AI_SERVICE_MAX_RETRIES=3" >> "$ENV_FILE"
    echo "AI_SERVICE_HEALTH_PATH=/health" >> "$ENV_FILE"
    
    echo "✅ Configuration saved to $ENV_FILE"
    echo ""
    echo "🚀 To use this configuration:"
    echo "   1. Source the environment file:"
    echo "      source $ENV_FILE"
    echo ""
    echo "   2. Start the Serverpod server:"
    echo "      cd image_editor_server/image_editor_server_server"
    echo "      dart bin/main.dart --apply-migrations"
    echo ""
    echo "   3. Or export variables manually:"
    echo "      export AI_SERVICE_HOST=$NEW_HOST"
    echo "      export AI_SERVICE_PORT=$NEW_PORT"
    echo "      export AI_SERVICE_SCHEME=$NEW_SCHEME"
    echo ""
    echo "📝 Note: The AI service must be running DFloat11 Qwen-Image-Edit model"
    echo "   with FastAPI server on the specified host and port."
    
else
    echo "❌ Configuration cancelled"
fi

echo ""
echo "🔗 Useful Commands:"
echo "   Test AI service: curl $NEW_SCHEME://$NEW_HOST:$NEW_PORT/health"
echo "   Check models: curl $NEW_SCHEME://$NEW_HOST:$NEW_PORT/models"
echo "   View logs: tail -f image_editor_server/image_editor_server_server/server.log"
