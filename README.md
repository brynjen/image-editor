# Image Editor

A Flutter image editor application with AI-powered image processing using Serverpod backend and DFloat11 compressed Qwen-Image-Edit model.

## ✨ Features

- **Drag & drop image upload** with instant server sync
- **AI image processing** with real-time progress tracking
- **Async job system** for long-running AI operations
- **Modern Flutter UI** with BLoC state management
- **Serverpod backend** with PostgreSQL and Redis
- **DFloat11 compressed model** (32% smaller, 28GB vs 41GB)

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.9.0+)
- Docker and Docker Compose
- Git

### 1. Clone Repository
```bash
git clone <your-repo-url>
cd image-editor
```

### 2. Start Backend
```bash
cd image_editor_server/image_editor_server_server
docker compose up --build --detach
dart bin/main.dart --apply-migrations
```
Server starts at `http://localhost:8080`

### 3. Start Frontend
```bash
cd ../../  # Back to project root
flutter pub get
flutter run
```

### 4. Setup AI Processing (Optional - for AI image editing)

**Option A: Local CPU Processing (Limited)**
```bash
# Download compressed model (~28GB) - requires 32GB+ RAM
./monitor-dfloat11-download.sh
```

**Option B: Remote GPU Server (Recommended)**
```bash
# Configure remote RTX 4090 server for optimal performance
./configure-remote-ai.sh
```
See **[Remote GPU Setup Guide](docs/REMOTE_GPU_SETUP.md)** for detailed instructions.

## 🎯 Usage

1. **Upload**: Drag & drop image → Auto-uploads to server
2. **Process**: Enter prompt → Click "Start Processing" → View progress
3. **Result**: Processed image appears automatically when complete

## 📚 Documentation

- **[Development Guide](docs/DEVELOPMENT.md)** - Detailed setup, architecture, and development workflow
- **[API Documentation](docs/API.md)** - Complete API reference and endpoints
- **[DFloat11 Integration](QWEN_IMAGE_EDIT_INTEGRATION.md)** - AI model setup and configuration
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Testing Guide](docs/TESTING.md)** - Testing procedures and verification

## 🏗️ Architecture

- **Frontend**: Flutter with BLoC state management
- **Backend**: Serverpod with PostgreSQL/Redis
- **AI Processing**: DFloat11 compressed Qwen-Image-Edit (Docker)
- **Storage**: Local file system with database metadata
- **Jobs**: Async processing system with real-time updates

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.