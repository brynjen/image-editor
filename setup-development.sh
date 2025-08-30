#!/bin/bash

# Development Setup Script for Flutter Image Editor with Serverpod + FastAPI
# Sets up the complete development environment locally
# 1. Serverpod backend (with PostgreSQL/Redis)
# 2. Qwen Image Edit FastAPI service

set -e

# Add signal handling for graceful interruption
cleanup() {
    echo ""
    echo "🛑 Setup interrupted. Cleaning up..."
    # Stop any running Docker containers
    docker compose -f image_editor_server/image_editor_server_server/docker-compose.yaml stop 2>/dev/null || true
    docker compose -f docker-compose.dev.yaml stop 2>/dev/null || true
    echo "🧹 Cleanup completed"
    exit 130
}

# Trap signals for graceful shutdown
trap cleanup INT TERM

echo "🚀 Setting up Flutter Image Editor Development Environment"
echo "========================================================="
echo "🎯 This will setup:"
echo "   • Serverpod backend (PostgreSQL + Redis)"
echo "   • Qwen Image Edit FastAPI service"
echo "   • All development dependencies"
echo ""

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Installing Flutter SDK..."
    
    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        echo "🍎 Detected macOS - installing Flutter via Homebrew..."
        if ! command -v brew &> /dev/null; then
            echo "📦 Installing Homebrew first..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # Add Homebrew to PATH for current session
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                export PATH="/opt/homebrew/bin:$PATH"
            elif [[ -f "/usr/local/bin/brew" ]]; then
                export PATH="/usr/local/bin:$PATH"
            fi
        fi
        
        if brew install --cask flutter; then
            echo "✅ Flutter installed via Homebrew"
            # Add Flutter to PATH
            export PATH="$(brew --prefix)/bin:$PATH"
        else
            echo "❌ Failed to install Flutter via Homebrew"
            echo "💡 Please install manually: https://docs.flutter.dev/get-started/install/macos"
            exit 1
        fi
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        echo "🐧 Detected Linux - installing Flutter SDK..."
        FLUTTER_VERSION="3.16.0"
        cd /tmp
        
        if wget "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"; then
            tar xf "flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
            sudo mv flutter /opt/
            
            # Add to PATH permanently
            echo 'export PATH="/opt/flutter/bin:$PATH"' >> ~/.bashrc
            echo 'export PATH="/opt/flutter/bin:$PATH"' >> ~/.profile
            
            # Add to PATH for current session
            export PATH="/opt/flutter/bin:$PATH"
            
            echo "✅ Flutter installed to /opt/flutter"
            echo "💡 Added to PATH in ~/.bashrc and ~/.profile"
        else
            echo "❌ Failed to download Flutter"
            echo "💡 Please install manually: https://docs.flutter.dev/get-started/install/linux"
            exit 1
        fi
        
        cd - > /dev/null
        
    else
        echo "❌ Unsupported OS: $OSTYPE"
        echo "💡 Please install Flutter manually: https://docs.flutter.dev/get-started/install"
        exit 1
    fi
    
    # Verify installation
    if command -v flutter &> /dev/null; then
        FLUTTER_VERSION=$(flutter --version | head -n1 | cut -d' ' -f2)
        echo "✅ Flutter installation verified: $FLUTTER_VERSION"
    else
        echo "❌ Flutter installation failed - command not found after install"
        echo "💡 You may need to restart your terminal or run: source ~/.bashrc"
        exit 1
    fi
else
    FLUTTER_VERSION=$(flutter --version | head -n1 | cut -d' ' -f2)
    echo "✅ Flutter found: $FLUTTER_VERSION"
fi

# Check Dart
if ! command -v dart &> /dev/null; then
    echo "❌ Dart not found. Usually comes with Flutter."
    exit 1
else
    DART_VERSION=$(dart --version | cut -d' ' -f4)
    echo "✅ Dart found: $DART_VERSION"
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first:"
    echo "   https://docs.docker.com/get-docker/"
    exit 1
else
    echo "✅ Docker found"
fi

# Check Docker Compose
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose not found. Please install Docker Compose:"
    echo "   https://docs.docker.com/compose/install/"
    exit 1
else
    echo "✅ Docker Compose found"
fi

echo ""
echo "📦 Installing Flutter dependencies..."
if flutter pub get; then
    echo "✅ Flutter dependencies installed"
else
    echo "❌ Failed to install Flutter dependencies"
    exit 1
fi

echo ""
echo "🐳 Setting up Serverpod backend..."
cd image_editor_server/image_editor_server_server

# Install Dart dependencies for server
echo "📦 Installing Serverpod dependencies..."
if dart pub get; then
    echo "✅ Serverpod dependencies installed"
else
    echo "❌ Failed to install Serverpod dependencies"
    exit 1
fi

# Start Docker services (PostgreSQL and Redis)
echo "🐳 Starting PostgreSQL and Redis with Docker..."
if docker compose up --build --detach; then
    echo "✅ Database services started"
    
    # Wait for PostgreSQL to be ready
    echo "⏳ Waiting for PostgreSQL to be ready..."
    sleep 5
    
    # Check if PostgreSQL is responding
    for i in {1..30}; do
        if docker compose exec -T postgres pg_isready -U postgres &> /dev/null; then
            echo "✅ PostgreSQL is ready"
            break
        fi
        if [ $i -eq 30 ]; then
            echo "❌ PostgreSQL failed to start after 30 seconds"
            docker compose logs postgres
            exit 1
        fi
        sleep 1
    done
else
    echo "❌ Failed to start database services"
    exit 1
fi

# Apply database migrations
echo "📊 Applying database migrations..."
if dart bin/main.dart --apply-migrations; then
    echo "✅ Database migrations applied"
else
    echo "❌ Failed to apply database migrations"
    echo "💡 This might be normal if no migrations exist yet"
fi

# Go back to project root
cd ../..

echo ""
echo "🤖 Setting up Qwen Image Edit FastAPI service..."

# Check if models exist
if [ ! -d "qwen-models-cache" ] || [ -z "$(ls -A qwen-models-cache 2>/dev/null)" ]; then
    echo "⚠️  No models found in qwen-models-cache/"
    echo "💡 The FastAPI service will start but won't be functional until models are downloaded."
    echo "   Use: python3 download-dfloat11-simple.py"
    MODELS_AVAILABLE=false
else
    echo "✅ Found model cache directory"
    CACHE_SIZE=$(du -sh qwen-models-cache 2>/dev/null | cut -f1 || echo "unknown")
    echo "📊 Model cache size: $CACHE_SIZE"
    MODELS_AVAILABLE=true
fi

# Create a development Docker Compose that includes both services
echo "🐳 Creating development Docker Compose configuration..."
cat > docker-compose.dev.yaml << 'EOF'
services:
  # PostgreSQL and Redis (from Serverpod)
  postgres:
    image: postgres:15.3
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: image_editor_server
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7.2
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

  # Qwen Image Edit FastAPI service
  qwen-image-edit:
    build: ./qwen-image-edit
    ports:
      - "8000:8000"
    environment:
      - MODEL_NAME=Qwen/Qwen-Image-Edit
      - DEVICE=auto  # Will use CPU or GPU based on availability
      - CPU_OFFLOAD=true  # Enable CPU offloading for memory efficiency
      - CPU_OFFLOAD_BLOCKS=30
      - PIN_MEMORY=true
      - HF_HOME=/app/hf_cache
      - TRANSFORMERS_CACHE=/app/hf_cache
      - HF_DATASETS_CACHE=/app/hf_cache
    volumes:
      - ./qwen-models-cache:/app/hf_cache:ro  # Read-only model cache
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s  # Give time for model loading
    depends_on:
      postgres:
        condition: service_healthy

volumes:
  postgres_data:
  redis_data:
EOF

# Start all services with Docker Compose
echo "🚀 Starting all development services..."
if docker compose -f docker-compose.dev.yaml up --build --detach; then
    echo "✅ All services started successfully"
    
    # Wait for services to be ready
    echo "⏳ Waiting for services to be ready..."
    sleep 10
    
    # Check service health
    echo "🔍 Checking service health..."
    
    # Check PostgreSQL
    if docker compose -f docker-compose.dev.yaml exec -T postgres pg_isready -U postgres &> /dev/null; then
        echo "✅ PostgreSQL is ready"
    else
        echo "⚠️  PostgreSQL may still be starting"
    fi
    
    # Check FastAPI service
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "✅ Qwen Image Edit service is ready"
    else
        echo "⚠️  Qwen Image Edit service may still be loading models"
    fi
    
else
    echo "❌ Failed to start services"
    exit 1
fi

echo ""
echo "🎉 Development Environment Setup Complete!"
echo "=========================================="
echo ""
echo "📋 What's Running:"
echo "  • PostgreSQL: localhost:5432"
echo "  • Redis: localhost:6379"
echo "  • Qwen Image Edit API: localhost:8000"
echo ""
if [ "$MODELS_AVAILABLE" = true ]; then
    echo "✅ AI image processing: Ready"
else
    echo "⚠️  AI image processing: Models needed (run: python3 download-dfloat11-simple.py)"
fi
echo ""
echo "🚀 Next Steps:"
echo ""
echo "1. Start the Serverpod backend:"
echo "   cd image_editor_server/image_editor_server_server"
echo "   dart bin/main.dart"
echo "   # Server will be available at http://localhost:8080"
echo ""
echo "2. In another terminal, start the Flutter app:"
echo "   flutter run"
echo ""
echo "3. Test the services:"
echo "   # Test Serverpod"
echo "   curl \"http://localhost:8080/greeting/hello?name=Test\""
echo "   # Test AI service"
echo "   curl \"http://localhost:8000/health\""
echo ""
echo "🛑 To stop all services when done:"
echo "   docker compose -f docker-compose.dev.yaml stop"
echo ""
echo "📚 Documentation:"
echo "  • Development Guide: docs/DEVELOPMENT.md"
echo "  • API Reference: docs/API.md"
echo "  • Troubleshooting: docs/TROUBLESHOOTING.md"
