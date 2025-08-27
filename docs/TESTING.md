# Testing Guide

Comprehensive testing procedures for the Image Editor project.

## 🧪 Testing Overview

### Testing Strategy
- **Unit Tests**: Individual components and functions
- **Integration Tests**: API endpoints and database operations
- **End-to-End Tests**: Complete user workflows
- **Manual Tests**: UI interactions and edge cases
- **Performance Tests**: Load and stress testing

### Testing Pyramid
```
    E2E Tests (Few)
      ↑
  Integration Tests (Some)
      ↑
   Unit Tests (Many)
```

## 🚀 Quick Test Suite

### Automated Test Run
```bash
# Run all tests
./run-all-tests.sh

# Or run individually:
flutter test                    # Flutter unit tests
cd image_editor_server/image_editor_server_server && dart test  # Server tests
```

### Manual Verification
```bash
# 1. Start services
cd image_editor_server/image_editor_server_server
docker compose up --build --detach
dart bin/main.dart --apply-migrations

# 2. Test connectivity
curl "http://localhost:8080/greeting/hello?name=Test"

# 3. Run Flutter app
cd ../../
flutter run

# 4. Test basic workflow (manual)
# - Upload image via drag & drop
# - Enter processing instructions
# - Click "Start Processing"
# - Verify async progress updates
```

## 🔧 Unit Tests

### Flutter Unit Tests

**Location**: `test/`

**Run Tests:**
```bash
flutter test
flutter test --coverage  # With coverage report
```

**Key Test Files:**
- `test/domain/model/image_model_test.dart`
- `test/presentation/bloc/image_editor_bloc_test.dart`
- `test/data/repository/serverpod_image_repository_test.dart`

**Example Test:**
```dart
// test/domain/model/image_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:image_editor/domain/model/image_model.dart';

void main() {
  group('ImageModel', () {
    test('should create image model with required fields', () {
      final image = ImageModel(
        name: 'test.jpg',
        serverpodImageId: 123,
        isUploaded: true,
      );

      expect(image.name, 'test.jpg');
      expect(image.serverpodImageId, 123);
      expect(image.isUploaded, true);
    });

    test('should detect if image has valid data', () {
      final imageWithPath = ImageModel(name: 'test.jpg', path: '/path/to/image.jpg');
      final imageWithBytes = ImageModel(name: 'test.jpg', bytes: Uint8List(100));
      final imageEmpty = ImageModel(name: 'test.jpg');

      expect(imageWithPath.hasImage, true);
      expect(imageWithBytes.hasImage, true);
      expect(imageEmpty.hasImage, false);
    });
  });
}
```

### Server Unit Tests

**Location**: `image_editor_server/image_editor_server_server/test/`

**Run Tests:**
```bash
cd image_editor_server/image_editor_server_server
dart test
dart test --coverage  # With coverage
```

**Key Test Files:**
- `test/endpoints/image_endpoint_test.dart`
- `test/services/qwen_image_service_test.dart`
- `test/services/job_processing_service_test.dart`

**Example Test:**
```dart
// test/endpoints/image_endpoint_test.dart
import 'package:test/test.dart';
import 'package:serverpod_test/serverpod_test.dart';

void main() {
  group('ImageEndpoint', () {
    late TestSession session;

    setUp(() async {
      session = await IntegrationTestServer().session();
    });

    tearDown(() async {
      await session.close();
    });

    test('should upload image successfully', () async {
      final response = await session.serverpod.endpoints.image.uploadImage(
        'test.jpg',
        'test.jpg',
        'image/jpeg',
        'base64-encoded-data',
      );

      expect(response.success, true);
      expect(response.imageId, isNotNull);
    });
  });
}
```

## 🔗 Integration Tests

### API Integration Tests

**Test API endpoints with real database:**

```bash
# Setup test environment
cd image_editor_server/image_editor_server_server
docker compose -f docker-compose.test.yaml up --build --detach
dart test test/integration/
```

**Example Integration Test:**
```dart
// test/integration/image_workflow_test.dart
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  group('Image Workflow Integration', () {
    late String baseUrl;

    setUpAll(() {
      baseUrl = 'http://localhost:8080';
    });

    test('complete image processing workflow', () async {
      // 1. Upload image
      final uploadResponse = await http.post(
        Uri.parse('$baseUrl/image/uploadImage'),
        body: {
          'filename': 'test.jpg',
          'name': 'test.jpg',
          'mimeType': 'image/jpeg',
          'data': 'base64-test-data',
        },
      );

      expect(uploadResponse.statusCode, 200);
      final uploadData = jsonDecode(uploadResponse.body);
      expect(uploadData['success'], true);
      final imageId = uploadData['imageId'];

      // 2. Start async processing
      final processResponse = await http.post(
        Uri.parse('$baseUrl/image/processImageAsync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'imageId': imageId,
          'processorType': 'qwen-image-edit',
          'instructions': 'Add a red hat',
        }),
      );

      expect(processResponse.statusCode, 200);
      final processData = jsonDecode(processResponse.body);
      final jobId = processData['id'];

      // 3. Poll job status
      String status = 'pending';
      int attempts = 0;
      while (status != 'completed' && status != 'failed' && attempts < 30) {
        await Future.delayed(Duration(seconds: 2));
        
        final statusResponse = await http.get(
          Uri.parse('$baseUrl/job/getJobStatus/$jobId'),
        );
        
        expect(statusResponse.statusCode, 200);
        final statusData = jsonDecode(statusResponse.body);
        status = statusData['job']['status'];
        attempts++;
      }

      expect(status, 'completed');
    });
  });
}
```

### Database Integration Tests

**Test database operations:**

```dart
// test/integration/database_test.dart
import 'package:test/test.dart';
import 'package:serverpod_test/serverpod_test.dart';

void main() {
  group('Database Operations', () {
    late TestSession session;

    setUp(() async {
      session = await IntegrationTestServer().session();
    });

    tearDown(() async {
      await session.close();
    });

    test('should store and retrieve image data', () async {
      // Create test image data
      final imageData = ImageData(
        filename: 'test_123.jpg',
        originalName: 'test.jpg',
        mimeType: 'image/jpeg',
        size: 1024,
        uploadedAt: DateTime.now(),
      );

      // Store in database
      final stored = await ImageData.db.insertRow(session, imageData);
      expect(stored.id, isNotNull);

      // Retrieve from database
      final retrieved = await ImageData.db.findById(session, stored.id!);
      expect(retrieved?.filename, 'test_123.jpg');
      expect(retrieved?.originalName, 'test.jpg');
    });
  });
}
```

## 🎭 End-to-End Tests

### Flutter Integration Tests

**Location**: `integration_test/`

**Setup:**
```yaml
# pubspec.yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  flutter_test:
    sdk: flutter
```

**Run Tests:**
```bash
flutter test integration_test/
```

**Example E2E Test:**
```dart
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:image_editor/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Image Editor E2E', () {
    testWidgets('complete image processing workflow', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Find upload area
      final uploadArea = find.byKey(Key('image_drop_box_input'));
      expect(uploadArea, findsOneWidget);

      // Simulate image selection (mock)
      await tester.tap(uploadArea);
      await tester.pumpAndSettle();

      // Enter processing instructions
      final instructionField = find.byKey(Key('instruction_text_field'));
      await tester.enterText(instructionField, 'Add a red hat to the person');
      await tester.pumpAndSettle();

      // Select processor
      final processorDropdown = find.byKey(Key('processor_dropdown'));
      await tester.tap(processorDropdown);
      await tester.pumpAndSettle();
      
      final qwenOption = find.text('qwen-image-edit');
      await tester.tap(qwenOption);
      await tester.pumpAndSettle();

      // Start processing
      final processButton = find.byKey(Key('process_button'));
      await tester.tap(processButton);
      await tester.pumpAndSettle();

      // Verify job status widget appears
      final jobStatus = find.byKey(Key('job_status_widget'));
      expect(jobStatus, findsOneWidget);

      // Wait for processing (with timeout)
      await tester.pumpAndSettle(Duration(seconds: 30));

      // Verify result appears
      final outputImage = find.byKey(Key('image_drop_box_output'));
      expect(outputImage, findsOneWidget);
    });
  });
}
```

### API End-to-End Tests

**Test complete API workflows:**

```bash
#!/bin/bash
# test/e2e/api_workflow_test.sh

set -e

BASE_URL="http://localhost:8080"
TEST_IMAGE="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg=="

echo "🧪 Running API E2E Tests"

# Test 1: Health check
echo "1. Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s "$BASE_URL/greeting/hello?name=E2ETest")
if [[ $HEALTH_RESPONSE == *"Hello E2ETest"* ]]; then
  echo "✅ Health check passed"
else
  echo "❌ Health check failed"
  exit 1
fi

# Test 2: Image upload
echo "2. Testing image upload..."
UPLOAD_RESPONSE=$(curl -s -X POST "$BASE_URL/image/uploadImage" \
  -F "filename=test.png" \
  -F "name=test.png" \
  -F "mimeType=image/png" \
  -F "data=$TEST_IMAGE")

IMAGE_ID=$(echo $UPLOAD_RESPONSE | jq -r '.imageId')
if [[ $IMAGE_ID != "null" && $IMAGE_ID != "" ]]; then
  echo "✅ Image upload passed (ID: $IMAGE_ID)"
else
  echo "❌ Image upload failed"
  exit 1
fi

# Test 3: Image retrieval
echo "3. Testing image retrieval..."
IMAGE_DATA=$(curl -s "$BASE_URL/image/getImage/$IMAGE_ID")
FILENAME=$(echo $IMAGE_DATA | jq -r '.filename')
if [[ $FILENAME != "null" ]]; then
  echo "✅ Image retrieval passed"
else
  echo "❌ Image retrieval failed"
  exit 1
fi

# Test 4: Async processing
echo "4. Testing async processing..."
JOB_RESPONSE=$(curl -s -X POST "$BASE_URL/image/processImageAsync" \
  -H "Content-Type: application/json" \
  -d "{\"imageId\":$IMAGE_ID,\"processorType\":\"qwen-image-edit\",\"instructions\":\"test processing\"}")

JOB_ID=$(echo $JOB_RESPONSE | jq -r '.id')
if [[ $JOB_ID != "null" && $JOB_ID != "" ]]; then
  echo "✅ Async processing started (Job ID: $JOB_ID)"
else
  echo "❌ Async processing failed"
  exit 1
fi

# Test 5: Job status polling
echo "5. Testing job status polling..."
for i in {1..10}; do
  STATUS_RESPONSE=$(curl -s "$BASE_URL/job/getJobStatus/$JOB_ID")
  STATUS=$(echo $STATUS_RESPONSE | jq -r '.job.status')
  echo "   Status: $STATUS"
  
  if [[ $STATUS == "completed" || $STATUS == "failed" ]]; then
    break
  fi
  sleep 2
done

echo "✅ All API E2E tests passed!"
```

## 📊 Performance Tests

### Load Testing

**Using Apache Bench:**
```bash
# Test image upload endpoint
ab -n 100 -c 10 -p test_image.json -T application/json \
  http://localhost:8080/image/uploadImage

# Test health endpoint
ab -n 1000 -c 50 http://localhost:8080/greeting/hello?name=LoadTest
```

**Using Artillery:**
```yaml
# artillery-config.yaml
config:
  target: 'http://localhost:8080'
  phases:
    - duration: 60
      arrivalRate: 10

scenarios:
  - name: "Image Upload Load Test"
    requests:
      - post:
          url: "/image/uploadImage"
          form:
            filename: "load_test.jpg"
            name: "load_test.jpg"
            mimeType: "image/jpeg"
            data: "base64-test-data"
```

```bash
artillery run artillery-config.yaml
```

### Memory and CPU Monitoring

**Monitor during tests:**
```bash
# System monitoring
htop

# Docker monitoring
docker stats

# Specific process monitoring
ps aux | grep dart
ps aux | grep flutter
```

**Memory leak detection:**
```bash
# Flutter memory profiling
flutter run --profile
# Use Flutter Inspector to monitor memory

# Server memory monitoring
dart --observe bin/main.dart --apply-migrations
# Connect to Observatory for memory analysis
```

## 🔍 Test Data Management

### Test Database Setup

**Create test database:**
```bash
# test/setup/test_db_setup.sh
docker compose -f docker-compose.test.yaml up --build --detach
sleep 10  # Wait for database to start

# Run test migrations
cd image_editor_server/image_editor_server_server
dart bin/main.dart --apply-migrations --config=test
```

### Test Image Assets

**Create test images:**
```bash
# test/assets/create_test_images.sh
mkdir -p test/assets/images

# Create various test images
convert -size 100x100 xc:red test/assets/images/red_100x100.png
convert -size 500x500 xc:blue test/assets/images/blue_500x500.jpg
convert -size 1920x1080 xc:green test/assets/images/green_1920x1080.png

# Create corrupted image for error testing
echo "not an image" > test/assets/images/corrupted.jpg
```

### Mock Services

**Mock AI service for testing:**
```dart
// test/mocks/mock_qwen_service.dart
class MockQwenImageService implements QwenImageService {
  @override
  Future<bool> checkHealth() async => true;

  @override
  Future<String?> processImage(String imageBase64, String prompt) async {
    // Return mock processed image
    await Future.delayed(Duration(seconds: 1)); // Simulate processing
    return 'mock-processed-image-base64';
  }
}
```

## 📈 Test Coverage

### Generate Coverage Reports

**Flutter coverage:**
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Server coverage:**
```bash
cd image_editor_server/image_editor_server_server
dart test --coverage=coverage
dart pub global activate coverage
dart pub global run coverage:format_coverage \
  --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
genhtml coverage/lcov.info -o coverage/html
```

### Coverage Goals

- **Unit Tests**: > 80% line coverage
- **Integration Tests**: > 60% API endpoint coverage
- **E2E Tests**: > 90% critical user journey coverage

## 🚨 Continuous Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_PASSWORD: password
          POSTGRES_DB: image_editor_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run Flutter tests
        run: flutter test --coverage
      
      - name: Setup Dart
        uses: dart-lang/setup-dart@v1
      
      - name: Run server tests
        working-directory: image_editor_server/image_editor_server_server
        run: |
          dart pub get
          dart test --coverage=coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

### Pre-commit Hooks

```bash
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: flutter-test
        name: Flutter Test
        entry: flutter test
        language: system
        pass_filenames: false
        
      - id: dart-analyze
        name: Dart Analyze
        entry: flutter analyze
        language: system
        pass_filenames: false
```

## 📋 Test Checklist

### Before Release

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] E2E tests cover critical user journeys
- [ ] Performance tests meet requirements
- [ ] Security tests pass
- [ ] Cross-platform tests complete (iOS/Android/Web)
- [ ] Database migration tests pass
- [ ] API backward compatibility verified
- [ ] Error handling scenarios tested
- [ ] Memory leak tests pass

### Manual Testing Checklist

- [ ] Image upload (drag & drop)
- [ ] Image upload (file picker)
- [ ] Various image formats (JPG, PNG, GIF, WebP)
- [ ] Large image files (>5MB)
- [ ] Network error scenarios
- [ ] Server restart during processing
- [ ] Multiple concurrent users
- [ ] Mobile responsive design
- [ ] Accessibility features
- [ ] Browser compatibility
