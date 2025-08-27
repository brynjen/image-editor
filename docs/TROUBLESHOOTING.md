# Troubleshooting Guide

Common issues and solutions for the Image Editor project.

## 🚨 Quick Diagnostics

### System Health Check
```bash
# Check if all services are running
docker ps

# Test server connectivity
curl -s http://localhost:8080
# Expected: OK 2025-08-27 14:14:36.439003Z

# Test API endpoint
curl "http://localhost:8080/greeting/hello?name=Test"
# Expected: {"message":"Hello Test",...}
```

### Service Status
```bash
# Check Docker services
docker compose ps

# View service logs
docker compose logs postgres
docker compose logs redis
docker compose logs qwen-image-edit  # If AI model is running
```

## 🐛 Common Issues

### Backend Server Issues

#### ❌ Server won't start

**Symptoms:**
- `dart bin/main.dart --apply-migrations` fails
- Connection refused errors
- Port already in use

**Solutions:**

1. **Check if ports are available:**
   ```bash
   lsof -i :8080  # Check if port 8080 is in use
   lsof -i :5432  # Check if PostgreSQL port is in use
   ```

2. **Kill processes using ports:**
   ```bash
   sudo kill -9 $(lsof -ti:8080)
   sudo kill -9 $(lsof -ti:5432)
   ```

3. **Restart Docker services:**
   ```bash
   docker compose down
   docker compose up --build --detach
   ```

4. **Check Docker is running:**
   ```bash
   docker --version
   docker compose --version
   ```

#### ❌ Database connection errors

**Symptoms:**
- "Connection to database failed"
- Migration errors
- PostgreSQL not accessible

**Solutions:**

1. **Wait for PostgreSQL to fully start:**
   ```bash
   # PostgreSQL takes 20-30 seconds to initialize
   docker compose logs postgres | grep "ready to accept connections"
   ```

2. **Check database credentials:**
   ```bash
   # Verify config/development.yaml
   cat config/development.yaml | grep -A 5 database
   ```

3. **Test database connection:**
   ```bash
   docker compose exec postgres psql -U postgres -d image_editor -c '\dt'
   ```

4. **Reset database:**
   ```bash
   docker compose down -v  # Remove volumes
   docker compose up --build --detach
   ```

#### ❌ Redis connection errors

**Symptoms:**
- Session management fails
- Cache errors in logs

**Solutions:**

1. **Check Redis status:**
   ```bash
   docker compose exec redis redis-cli ping
   # Expected: PONG
   ```

2. **Restart Redis:**
   ```bash
   docker compose restart redis
   ```

### Frontend Issues

#### ❌ Flutter build errors

**Symptoms:**
- Compilation errors
- Dependency resolution failures
- "No such file or directory" errors

**Solutions:**

1. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Check Flutter/Dart versions:**
   ```bash
   flutter --version
   dart --version
   # Ensure Flutter 3.9.0+ and Dart 3.9.0+
   ```

3. **Update dependencies:**
   ```bash
   flutter pub upgrade
   ```

4. **Check for platform-specific issues:**
   ```bash
   # iOS
   cd ios && pod install && cd ..
   
   # Android
   flutter clean && flutter pub get
   ```

#### ❌ Serverpod client errors

**Symptoms:**
- "Class not found" errors
- Protocol mismatch errors
- Generated client out of sync

**Solutions:**

1. **Regenerate Serverpod client:**
   ```bash
   cd image_editor_server/image_editor_server_server
   serverpod generate
   cd ../../
   flutter pub get
   ```

2. **Check path dependency:**
   ```yaml
   # Verify pubspec.yaml has correct path
   dependencies:
     image_editor_server_client:
       path: ./image_editor_server/image_editor_server_client
   ```

3. **Clean both server and client:**
   ```bash
   cd image_editor_server/image_editor_server_server
   dart pub get
   serverpod generate
   cd ../../
   flutter clean && flutter pub get
   ```

### Image Upload Issues

#### ❌ Image upload fails

**Symptoms:**
- "Upload failed" messages
- Network errors
- Server returns 500 errors

**Solutions:**

1. **Check storage directory:**
   ```bash
   cd image_editor_server/image_editor_server_server
   ls -la storage/
   # Should show images/ directory with write permissions
   ```

2. **Create storage directory:**
   ```bash
   mkdir -p storage/images
   chmod 755 storage/images
   ```

3. **Check file size limits:**
   ```bash
   # Images should be < 10MB by default
   ls -lh path/to/test/image.jpg
   ```

4. **Test with smaller image:**
   ```bash
   # Try with a small PNG/JPEG file first
   ```

5. **Check server logs:**
   ```bash
   # Look for upload-related errors
   dart bin/main.dart --apply-migrations --verbose
   ```

#### ❌ Image processing fails

**Symptoms:**
- Processing jobs stuck in "pending"
- AI service unavailable errors
- Timeout errors

**Solutions:**

1. **Check AI service status:**
   ```bash
   curl -s http://localhost:8000/health
   # Should return AI service health status
   ```

2. **Check Docker logs:**
   ```bash
   docker compose logs qwen-image-edit
   ```

3. **Restart AI service:**
   ```bash
   docker compose restart qwen-image-edit
   ```

4. **Check model download:**
   ```bash
   ./check-dfloat11-status.sh
   # Verify model is downloaded and ready
   ```

### AI Model Issues

#### ❌ Model download fails

**Symptoms:**
- Download stops or times out
- "Model not found" errors
- Out of disk space

**Solutions:**

1. **Check disk space:**
   ```bash
   df -h .
   # Need ~30GB free space for DFloat11 model
   ```

2. **Resume download:**
   ```bash
   ./monitor-dfloat11-download.sh
   # Script supports resume functionality
   ```

3. **Check internet connection:**
   ```bash
   ping huggingface.co
   curl -I https://huggingface.co/Qwen/Qwen-Image-Edit
   ```

4. **Clear cache and retry:**
   ```bash
   rm -rf qwen-models-cache/
   ./monitor-dfloat11-download.sh
   ```

#### ❌ Model loading fails

**Symptoms:**
- Container exits with code 137 (OOM)
- "Model not loaded" errors
- Very slow inference

**Solutions:**

1. **Check available RAM:**
   ```bash
   free -h
   # Need 24GB+ RAM for DFloat11 model with CPU offloading
   ```

2. **Enable CPU offloading:**
   ```yaml
   # In docker-compose.yaml
   environment:
     - CPU_OFFLOAD=true
   ```

3. **Reduce concurrent requests:**
   ```yaml
   environment:
     - MAX_CONCURRENT_REQUESTS=1
   ```

## 🔍 Debug Procedures

### Enable Verbose Logging

#### Server Logging
```bash
cd image_editor_server/image_editor_server_server
dart bin/main.dart --apply-migrations --verbose
```

#### Flutter Logging
```bash
flutter run --debug --verbose
```

#### Docker Logging
```bash
# Follow logs in real-time
docker compose logs -f

# Specific service logs
docker compose logs -f postgres
docker compose logs -f qwen-image-edit
```

### Network Debugging

#### Test API Endpoints
```bash
# Basic connectivity
curl -v http://localhost:8080

# Upload test
curl -X POST "http://localhost:8080/image/uploadImage" \
  -F "filename=test.jpg" \
  -F "name=test.jpg" \
  -F "mimeType=image/jpeg" \
  -F "data=iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg=="

# Processing test
curl -X POST "http://localhost:8080/image/processImageAsync" \
  -H "Content-Type: application/json" \
  -d '{"imageId":1,"processorType":"qwen-image-edit","instructions":"test"}'
```

#### Check Port Accessibility
```bash
# From inside container
docker compose exec postgres nc -z localhost 5432
docker compose exec redis nc -z localhost 6379

# From host
nc -z localhost 8080
nc -z localhost 5432
```

### Database Debugging

#### Connect to Database
```bash
docker compose exec postgres psql -U postgres -d image_editor
```

#### Common SQL Queries
```sql
-- Check tables
\dt

-- View image data
SELECT id, filename, original_name, uploaded_at FROM image_data LIMIT 10;

-- View processing jobs
SELECT id, status, processor_type, progress, created_at FROM processing_job ORDER BY created_at DESC LIMIT 10;

-- Check database size
SELECT pg_size_pretty(pg_database_size('image_editor'));
```

## 🛠️ Performance Issues

### Slow Image Upload

**Causes & Solutions:**

1. **Large image files:**
   - Resize images before upload
   - Implement client-side compression

2. **Network latency:**
   - Check local network configuration
   - Use wired connection for development

3. **Server processing:**
   - Check server CPU/memory usage
   - Optimize image validation logic

### Slow Image Processing

**Causes & Solutions:**

1. **CPU-only inference:**
   - Use GPU if available: `DEVICE=cuda`
   - Increase CPU cores for Docker

2. **Memory constraints:**
   - Increase Docker memory limit
   - Enable CPU offloading: `CPU_OFFLOAD=true`

3. **Model loading time:**
   - Model loads once on startup
   - Keep container running between requests

### Memory Issues

#### Monitor Memory Usage
```bash
# System memory
free -h

# Docker container memory
docker stats

# Process memory
ps aux | grep dart
ps aux | grep flutter
```

#### Optimize Memory Usage
```bash
# Increase Docker memory limit
# Docker Desktop: Settings > Resources > Memory

# Reduce Flutter memory usage
flutter run --release  # Use release mode

# Optimize AI model memory
# Set CPU_OFFLOAD=true in docker-compose.yaml
```

## 📞 Getting Help

### Log Collection
```bash
# Collect all relevant logs
mkdir debug-logs
docker compose logs > debug-logs/docker-logs.txt
dart bin/main.dart --apply-migrations --verbose > debug-logs/server-logs.txt 2>&1 &
flutter run --verbose > debug-logs/flutter-logs.txt 2>&1 &
```

### System Information
```bash
# System info
uname -a
docker --version
flutter --version

# Disk space
df -h

# Memory
free -h

# Network
netstat -tulpn | grep -E ':(8080|5432|6379)'
```

### Create Issue Report

When reporting issues, include:

1. **Environment:**
   - OS version
   - Flutter/Dart versions
   - Docker version

2. **Steps to reproduce:**
   - Exact commands run
   - Expected vs actual behavior

3. **Logs:**
   - Server logs
   - Docker logs
   - Flutter logs
   - Error messages

4. **Configuration:**
   - docker-compose.yaml changes
   - config/development.yaml settings
   - Any custom modifications

### Community Resources

- **Serverpod Documentation**: https://serverpod.dev
- **Flutter Documentation**: https://docs.flutter.dev
- **Docker Documentation**: https://docs.docker.com
- **Project Issues**: Create GitHub issue with logs and reproduction steps
