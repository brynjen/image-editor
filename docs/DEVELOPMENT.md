# Development Guide

Complete development setup, architecture details, and workflow for the Image Editor project.

## 🏗️ Architecture

### System Overview
```
Flutter App ↔ Serverpod Backend ↔ PostgreSQL Database
     ↓              ↓                    ↓
 BLoC State    AI Processing         File Storage
 Management    (Docker/Qwen)        (Images/Jobs)
```

### Component Breakdown

#### Frontend (Flutter)
- **State Management**: BLoC pattern with events/states
- **Repository Pattern**: Clean separation of data sources
- **Domain Models**: Business logic entities
- **UI Components**: Reusable widgets and screens

#### Backend (Serverpod)
- **Endpoints**: RESTful API with automatic client generation
- **Database**: PostgreSQL with automatic migrations
- **File Storage**: Local filesystem with metadata tracking
- **Job System**: Async processing with background workers

#### AI Processing (Docker)
- **DFloat11 Model**: 32% compressed Qwen-Image-Edit
- **FastAPI Service**: HTTP API for image processing
- **Background Jobs**: Long-running AI operations
- **Progress Tracking**: Real-time status updates

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK (3.9.0+)
- Dart SDK (3.9.0+) 
- Docker & Docker Compose
- Git
- IDE (VS Code recommended)

### Initial Setup

1. **Clone Repository**
   ```bash
   git clone <your-repo-url>
   cd image-editor
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Start Development Environment**
   ```bash
   cd image_editor_server/image_editor_server_server
   docker compose up --build --detach
   dart bin/main.dart --apply-migrations
   ```

4. **Verify Setup**
   ```bash
   # Test server
   curl "http://localhost:8080/greeting/hello?name=Test"
   
   # Check database
   docker compose logs postgres | tail -5
   ```

## 📁 Project Structure

```
image-editor/
├── lib/                          # Flutter app source
│   ├── data/                     # Data layer
│   │   └── repository/           # Repository implementations
│   ├── domain/                   # Business logic
│   │   ├── model/                # Domain models
│   │   └── repository/           # Repository interfaces
│   └── presentation/             # UI layer
│       ├── bloc/                 # BLoC state management
│       ├── screen/               # App screens
│       └── widget/               # Reusable widgets
│
├── image_editor_server/          # Serverpod backend
│   ├── image_editor_server_server/    # Server implementation
│   │   ├── lib/src/endpoints/    # API endpoints
│   │   ├── lib/src/protocol/     # Data models (YAML)
│   │   ├── lib/src/services/     # Business logic services
│   │   ├── migrations/           # Database migrations
│   │   └── storage/              # File storage
│   └── image_editor_server_client/    # Generated client
│
├── qwen-image-edit/              # AI processing Docker service
├── docs/                         # Documentation
└── QWEN_IMAGE_EDIT_INTEGRATION.md   # AI model integration guide
```

## 🔄 Development Workflow

### Serverpod Protocol Changes

**Important**: Always follow the proper Serverpod workflow:

1. **Edit Protocol Files** (`.yaml` files in `lib/src/protocol/`)
   ```bash
   cd image_editor_server/image_editor_server_server
   # Edit .yaml files in lib/src/protocol/
   ```

2. **Generate Code**
   ```bash
   serverpod generate
   ```

3. **Client Updates Automatically**
   - Flutter app uses generated client via path dependency
   - No manual copying required!

### Database Migrations

```bash
cd image_editor_server/image_editor_server_server

# Create migration
serverpod create-migration

# Apply migrations
dart bin/main.dart --apply-migrations
```

### Adding New Endpoints

1. Create endpoint class in `lib/src/endpoints/`
2. Add protocol models in `lib/src/protocol/`
3. Run `serverpod generate`
4. Update Flutter repository to use new client methods

### Flutter Development

```bash
# Hot reload during development
flutter run

# Clean build
flutter clean && flutter pub get && flutter run

# Run tests
flutter test
```

## 🔧 Configuration

### Server Configuration

Edit `image_editor_server/image_editor_server_server/config/development.yaml`:

```yaml
database:
  host: localhost
  port: 5432
  name: image_editor
  username: postgres
  password: password

apiServer:
  port: 8080
  publicHost: localhost

redis:
  enabled: true
  host: localhost
  port: 6379
```

### Client Configuration

Edit `lib/data/repository/serverpod_client_config.dart`:

```dart
static const String _defaultHost = 'localhost';
static const int _defaultPort = 8080;
```

### Docker Services

The `docker-compose.yaml` includes:
- **PostgreSQL**: Database with persistent volume
- **Redis**: Caching and session management
- **Qwen-Image-Edit**: AI processing service (optional)

## 🧪 Development Testing

### Unit Tests
```bash
# Flutter tests
flutter test

# Server tests  
cd image_editor_server/image_editor_server_server
dart test
```

### Integration Testing
```bash
# Start all services
docker compose up --build --detach
dart bin/main.dart --apply-migrations

# Test API endpoints
curl "http://localhost:8080/greeting/hello?name=Test"
curl -X POST "http://localhost:8080/image/uploadImage" # with form data
```

### Manual Testing Workflow
1. Start backend services
2. Run Flutter app: `flutter run`
3. Test image upload (drag & drop)
4. Test image processing with different prompts
5. Verify async job system with progress updates
6. Check file storage in `storage/images/`

## 🚀 Production Deployment

### Backend Deployment
1. Update configuration for production environment
2. Set up proper database with backups
3. Configure reverse proxy (nginx)
4. Set up SSL certificates
5. Deploy with Docker or native Dart

### Frontend Deployment
```bash
# Web deployment
flutter build web

# Mobile deployment
flutter build apk        # Android
flutter build ios        # iOS
```

## 📊 Database Schema

### Core Tables

**ImageData**
- `id`: Primary key (auto-increment)
- `filename`: Unique server filename
- `originalName`: Original uploaded filename
- `mimeType`: Image MIME type
- `size`: File size in bytes
- `uploadedAt`: Upload timestamp
- `processorType`: AI processor used (nullable)
- `instructions`: Processing instructions (nullable)
- `processedAt`: Processing timestamp (nullable)
- `processedFilename`: Processed image filename (nullable)

**ProcessingJob** (for async operations)
- `id`: Primary key
- `imageId`: Reference to ImageData
- `status`: Job status (pending/in_progress/completed/failed)
- `processorType`: AI processor type
- `instructions`: Processing instructions
- `progress`: Progress percentage (0.0-1.0)
- `createdAt/startedAt/completedAt`: Timestamps
- `resultImageId`: Reference to result ImageData (nullable)
- `errorMessage`: Error details (nullable)

## 🔍 Debugging

### Server Debugging
```bash
# Verbose server logs
dart bin/main.dart --apply-migrations --verbose

# Database connection test
docker compose exec postgres psql -U postgres -d image_editor -c '\dt'

# Redis connection test
docker compose exec redis redis-cli ping
```

### Flutter Debugging
```bash
# Debug mode with logging
flutter run --debug --verbose

# Performance profiling
flutter run --profile

# Inspector
flutter inspector
```

### Common Debug Points
- Network requests in `ServerpodImageRepository`
- BLoC state transitions in `ImageEditorBloc`
- File upload/download in `ImageEndpoint`
- Job processing in `JobProcessingService`

## 📝 Code Style

### Dart/Flutter
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter analyze` to check code quality
- Format with `dart format`

### Architecture Guidelines
- **Single Responsibility**: One class, one purpose
- **Repository Pattern**: Abstract data sources
- **BLoC Pattern**: Separate business logic from UI
- **Clean Architecture**: Domain → Data → Presentation layers

### Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `UPPER_SNAKE_CASE`
- **Endpoints**: `camelCase` methods

## 🔐 Security Considerations

### Development
- Database credentials in config files (not in code)
- File upload validation and sanitization
- Input validation on all endpoints
- Rate limiting for API endpoints

### Production
- Environment variables for secrets
- HTTPS/TLS encryption
- Database connection encryption
- File access permissions
- API authentication/authorization
