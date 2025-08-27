# Qwen Image Edit Integration Plan

## Overview

This document outlines the implementation plan for integrating **DFloat11 compressed Qwen-Image-Edit** as a local Docker service that communicates with our Serverpod backend. The DFloat11 compression reduces the model size by **32%** (from 41GB to 28GB) while maintaining 100% accuracy, making it suitable for consumer hardware with 24-32GB RAM.

## Architecture

```
Flutter App → Serverpod Backend → qwen-image-edit Docker Container → Processed Image → Storage → Client
```

### Current State
- ✅ Flutter frontend with drag & drop image upload
- ✅ Serverpod backend with image storage and processing endpoints  
- ✅ Database schema for tracking image processing
- ✅ Docker setup for PostgreSQL and Redis
- ❌ **Missing**: qwen-image-edit Docker integration
- ❌ **Missing**: HTTP communication between Serverpod and qwen-image-edit
- ❌ **Missing**: Async processing with progress tracking

### Target State
- User uploads image via Flutter app
- Serverpod stores image and returns image URL for display
- User views uploaded image, enters text prompt, and clicks "Process"
- Frontend sends image URL/ID + text prompt to Serverpod
- Serverpod retrieves image by URL/ID and sends image + prompt to qwen-image-edit Docker container
- qwen-image-edit processes the image and returns result
- Serverpod stores processed image and returns processed image URL
- Client displays the processed result

## DFloat11 Compressed Model

### Key Benefits
- **32% smaller**: 28.43GB vs 41GB original model
- **100% accuracy**: Bit-identical outputs to original model  
- **Memory efficient**: Can run on 24GB GPU with CPU offloading or 32GB GPU
- **Lossless compression**: Uses Huffman coding on BFloat16 exponent bits
- **Fast inference**: On-the-fly GPU decompression via CUDA kernels

### System Requirements
| Configuration | GPU Memory | CPU Memory | Generation Time |
|---------------|------------|------------|----------------|
| GPU Only | 32GB | 16GB+ | ~280 seconds |
| GPU + CPU Offloading | 24GB | 50GB+ | ~570 seconds |

### Model Components
- **Base Model**: `Qwen/Qwen-Image-Edit` (config and pipeline components)
- **Compressed Weights**: `DFloat11/Qwen-Image-Edit-DF11` (compressed transformer weights)

### Download Scripts
- **`monitor-dfloat11-download.sh`**: All-in-one download, monitoring, and testing script
- **`check-dfloat11-status.sh`**: Quick status check for download progress
- **Persistent Storage**: Models stored in `qwen-models-cache/` directory (mapped to Docker volume)

## Implementation Tasks

### Phase 1: Docker Container Setup

#### Task 1.1: Create qwen-image-edit Docker Service
**Priority**: High  
**Estimated Time**: 4-6 hours

Create a Python-based Docker container that runs qwen-image-edit model locally.

**Requirements**:
- Python 3.10+ with PyTorch, transformers, and diffusers
- **DFloat11 compressed Qwen-Image-Edit model** (28GB vs 41GB original)
- dfloat11 package for efficient compressed model loading
- FastAPI web server for HTTP endpoints
- Image processing capabilities (PIL, torchvision)
- CPU offloading support for reduced memory usage (24GB GPU + 50GB RAM or 32GB GPU)

**Deliverables**:
- `qwen-image-edit/Dockerfile`
- `qwen-image-edit/requirements.txt`
- `qwen-image-edit/main.py` (FastAPI server)
- `qwen-image-edit/model_handler.py` (model loading and inference)

#### Task 1.2: Update docker-compose.yaml
**Priority**: High  
**Estimated Time**: 1 hour

Add qwen-image-edit service to existing docker-compose configuration.

**Requirements**:
- Service definition with proper resource limits
- Volume mapping for model cache
- Network configuration for Serverpod communication
- Environment variables for model configuration
- Health check endpoint

**Deliverables**:
- Updated `image_editor_server/image_editor_server_server/docker-compose.yaml`

### Phase 2: API Integration

#### Task 2.1: Define qwen-image-edit HTTP API
**Priority**: High  
**Estimated Time**: 2 hours

Design REST API for image processing communication.

**Endpoints**:
```
POST /process
- Body: multipart/form-data with image file and text prompt
- Response: processed image file or job ID for async processing

GET /health
- Response: service health status

GET /models
- Response: available models and capabilities
```

**Deliverables**:
- API specification document
- OpenAPI/Swagger documentation

#### Task 2.2: Implement HTTP Client in Serverpod
**Priority**: High  
**Estimated Time**: 3-4 hours

Create HTTP client service to communicate with qwen-image-edit container.

**Requirements**:
- HTTP client using Dart's `http` package
- Multipart file upload support
- Error handling and retry logic
- Timeout configuration
- Connection pooling for performance

**Deliverables**:
- `lib/src/services/qwen_image_service.dart`
- Unit tests for HTTP client
- Integration with existing ImageEndpoint

#### Task 2.3: Update Serverpod Image Processing
**Priority**: High  
**Estimated Time**: 2-3 hours

Modify existing `processImage` endpoint to use qwen-image-edit service.

**Changes**:
- Accept image URL/ID + text prompt from frontend
- Retrieve image from storage using URL/ID
- Send image + prompt to qwen-image-edit service via HTTP
- Store processed result and return new image URL
- Handle async processing with job status tracking
- Implement proper error handling and logging

**Deliverables**:
- Updated `lib/src/endpoints/image_endpoint.dart`
- Enhanced error handling and logging

### Phase 3: Async Processing & Job Management

#### Task 3.1: Create Processing Job System
**Priority**: Medium  
**Estimated Time**: 4-5 hours

Implement job queue system for handling long-running image processing tasks.

**Requirements**:
- New database table for processing jobs
- Job status tracking (pending, processing, completed, failed)
- Background processing using Serverpod Future Calls
- Progress reporting capabilities

**Deliverables**:
- `lib/src/protocol/processing_job.yaml`
- `lib/src/endpoints/job_endpoint.dart`
- `lib/src/services/job_processing_service.dart`
- Database migration for job table

#### Task 3.2: Implement Job Status Polling
**Priority**: Medium  
**Estimated Time**: 2-3 hours

Add endpoints for clients to check processing status and retrieve results.

**Endpoints**:
```
GET /job/{jobId}/status - Get job status
GET /job/{jobId}/result - Get processed image when complete
POST /job/{jobId}/cancel - Cancel running job
```

**Deliverables**:
- Job status endpoints
- Client-side polling mechanism in Flutter
- Real-time progress updates

### Phase 4: Frontend Integration

#### Task 4.1: Update Flutter UI for Async Processing
**Priority**: Medium  
**Estimated Time**: 3-4 hours

Enhance Flutter app to handle the two-step workflow: upload then process.

**Requirements**:
- Display uploaded image with URL from Serverpod
- Send image URL/ID + text prompt when user clicks "Process"
- Progress indicators for processing operations
- Job status polling for async processing
- Error handling and retry mechanisms
- Display processed result image

**Deliverables**:
- Updated BLoC state management for two-step workflow
- Enhanced UI components for image display and processing
- Separate upload and process button flows

#### Task 4.2: Add Processing Options
**Priority**: Low  
**Estimated Time**: 2-3 hours

Add UI controls for different processing options and model parameters.

**Features**:
- Model selection dropdown (if multiple models supported)
- Processing quality/speed tradeoffs
- Advanced prompt engineering options
- Batch processing capabilities

**Deliverables**:
- Enhanced processor selection UI
- Advanced options dialog
- Batch processing workflow

### Phase 5: Production Readiness

#### Task 5.1: Performance Optimization
**Priority**: Medium  
**Estimated Time**: 3-4 hours

Optimize system for production workloads.

**Optimizations**:
- Model caching and warm-up strategies
- Request queuing and rate limiting
- Memory management for large images
- GPU utilization optimization
- Container resource tuning

**Deliverables**:
- Performance benchmarks
- Resource usage monitoring
- Optimization documentation

#### Task 5.2: Monitoring and Logging
**Priority**: Medium  
**Estimated Time**: 2-3 hours

Add comprehensive monitoring and logging.

**Requirements**:
- Processing time metrics
- Error rate monitoring
- Resource usage tracking
- Structured logging for debugging
- Health check endpoints

**Deliverables**:
- Monitoring dashboard configuration
- Log aggregation setup
- Alert configuration for failures

#### Task 5.3: Security and Validation
**Priority**: High  
**Estimated Time**: 2-3 hours

Implement security measures and input validation.

**Security Features**:
- Input image validation and sanitization
- File size and format restrictions
- Rate limiting to prevent abuse
- Secure communication between services
- Error message sanitization

**Deliverables**:
- Security audit checklist
- Input validation middleware
- Rate limiting configuration

## Technical Specifications

### Docker Container Requirements

#### qwen-image-edit Container
```dockerfile
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy application code
COPY . /app
WORKDIR /app

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
    CMD curl -f http://localhost:8000/health || exit 1

# Start server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### Required Python Packages
```txt
torch>=2.0.0
transformers>=4.35.0
fastapi>=0.104.0
uvicorn>=0.24.0
pillow>=10.0.0
opencv-python>=4.8.0
python-multipart>=0.0.6
pydantic>=2.4.0
```

### API Specifications

#### Image Processing Request
```json
{
  "image_url": "http://localhost:8080/image/file/123",
  "image_id": 123,
  "prompt": "Remove the background and make it transparent",
  "model": "qwen2-vl-7b-instruct",
  "options": {
    "quality": "high",
    "timeout": 300
  }
}
```

**Note**: The qwen-image-edit service will receive the actual image file from Serverpod, which retrieves it using the image_url/image_id.

#### Image Processing Response
```json
{
  "success": true,
  "processed_image": "<base64_encoded_result>",
  "processing_time": 15.2,
  "model_used": "qwen2-vl-7b-instruct",
  "message": "Image processed successfully"
}
```

### Database Schema Updates

#### Processing Jobs Table
```sql
CREATE TABLE processing_jobs (
    id BIGSERIAL PRIMARY KEY,
    image_id BIGINT NOT NULL REFERENCES image_data(id),
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    processor_type VARCHAR(100) NOT NULL,
    instructions TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    error_message TEXT,
    processing_time_ms INTEGER,
    result_image_id BIGINT REFERENCES image_data(id)
);

CREATE INDEX idx_processing_jobs_status ON processing_jobs(status);
CREATE INDEX idx_processing_jobs_created_at ON processing_jobs(created_at);
```

## Configuration

### Environment Variables

#### Serverpod Backend
```yaml
# config/development.yaml
qwen_image_service:
  base_url: "http://qwen-image-edit:8000"
  timeout_seconds: 300
  max_retries: 3
  max_concurrent_requests: 5
```

#### Docker Compose Service
```yaml
qwen-image-edit:
  build: ./qwen-image-edit
  ports:
    - "8000:8000"
  environment:
    - MODEL_NAME=qwen2-vl-7b-instruct
    - DEVICE=cuda  # or cpu
    - MAX_CONCURRENT_REQUESTS=2
  volumes:
    - ./qwen-image-edit/models:/app/models
    - ./qwen-image-edit/cache:/app/cache
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
```

## Testing Strategy

### Unit Tests
- HTTP client functionality
- Image processing logic
- Error handling scenarios
- Database operations

### Integration Tests
- End-to-end image processing workflow
- Docker container communication
- Database persistence
- File storage operations

### Performance Tests
- Processing time benchmarks
- Concurrent request handling
- Memory usage under load
- GPU utilization efficiency

### Manual Testing Checklist
- [ ] Image upload and URL display
- [ ] Image display from Serverpod storage URL
- [ ] Processing with image URL/ID + text prompt
- [ ] Different image formats (JPEG, PNG, WebP)
- [ ] Various image sizes (small, medium, large)
- [ ] Different processing instructions
- [ ] Error scenarios (invalid image URLs, timeouts)
- [ ] Concurrent processing requests
- [ ] Two-step workflow: upload → display → process → result

## Deployment Considerations

### Development Environment
- Use CPU-based processing for development
- Smaller model variants for faster iteration
- Local Docker containers

### Production Environment
- GPU-enabled containers for performance
- Load balancing for multiple processing containers
- Persistent storage for model cache
- Monitoring and alerting setup

## Success Criteria

1. **Functional Requirements**
   - [ ] Users can upload images and get storage URLs for display
   - [ ] Users can process uploaded images with text prompts
   - [ ] Two-step workflow: upload → display → process → result
   - [ ] Processing completes within acceptable time limits (< 30 seconds for typical images)
   - [ ] Support for common image formats and reasonable file sizes
   - [ ] Proper error handling and user feedback

2. **Performance Requirements**
   - [ ] Handle at least 10 concurrent processing requests
   - [ ] 95% of requests complete successfully
   - [ ] Average processing time < 15 seconds
   - [ ] System remains responsive during processing

3. **Quality Requirements**
   - [ ] Processed images maintain acceptable quality
   - [ ] AI model follows text instructions accurately
   - [ ] No data loss or corruption during processing
   - [ ] Secure handling of user images

## Risks and Mitigation

### Technical Risks
1. **Model Performance**: qwen-image-edit may not perform as expected
   - *Mitigation*: Test with sample images before full integration
   
2. **Resource Requirements**: High GPU/memory usage
   - *Mitigation*: Implement resource monitoring and limits
   
3. **Processing Timeouts**: Long processing times for complex edits
   - *Mitigation*: Implement async processing with status updates

### Operational Risks
1. **Container Stability**: Docker container crashes or hangs
   - *Mitigation*: Health checks, automatic restarts, monitoring
   
2. **Storage Growth**: Processed images consume significant storage
   - *Mitigation*: Implement cleanup policies and storage monitoring

## Implementation Progress

### ✅ Completed Tasks

#### Phase 1: Docker Container Setup
- ✅ **Task 1.1**: Created qwen-image-edit Docker container with Python FastAPI server
  - Built Docker container with Python 3.10-slim base image
  - Installed latest diffusers from GitHub and transformers library
  - Created FastAPI server with health checks and image processing endpoints
  - Implemented QwenImageEditHandler using diffusion pipeline

- ✅ **Task 1.2**: Updated docker-compose.yaml to include qwen-image-edit service
  - Added qwen-image-edit service to docker-compose configuration
  - Configured proper port mapping (8000:8000)
  - Added health checks and volume mounts for model caching
  - Set environment variables for model configuration

#### Phase 2: API Integration
- ✅ **Task 2.1**: Defined REST API specification for qwen-image-edit communication
  - Created FastAPI endpoints: `/health`, `/models`, `/process`, `/process-multipart`
  - Implemented request/response models with Pydantic
  - Added proper error handling and logging

- ✅ **Task 2.2**: Implemented HTTP client service in Serverpod
  - Created `QwenImageService` class for HTTP communication
  - Added retry logic, timeout handling, and connection pooling
  - Implemented health checking and model info retrieval
  - Added proper error handling with custom exceptions

- ✅ **Task 2.3**: Updated Serverpod processImage endpoint
  - Modified `ImageEndpoint` to use `QwenImageService`
  - Implemented proper workflow: retrieve image by ID → process with qwen-image-edit → store result
  - Added fallback processing when qwen service is unavailable
  - Enhanced error handling and logging

#### Phase 3: Async Processing & Job Management
- ✅ **Task 3.1**: Created processing job system with database table and background processing
  - Created `ProcessingJob` and `JobStatusResponse` protocol classes
  - Implemented `JobProcessingService` for managing jobs
  - Created `ImageProcessingFutureCall` for background processing
  - Added database migration for `processing_jobs` table

- ✅ **Task 3.2**: Implemented job status polling endpoints
  - Created `JobEndpoint` with full job management capabilities
  - Added endpoints for creating, monitoring, and canceling jobs
  - Implemented job result retrieval and statistics
  - Added both async and synchronous processing options

### 🔄 Current Status

The system has been updated to use the **DFloat11 compressed model** which is much more suitable for consumer hardware:
- **Docker Container**: ✅ Built with DFloat11 support and persistent model storage
- **Model Selection**: ✅ Updated to use DFloat11/Qwen-Image-Edit-DF11 (28GB vs 41GB original)
- **Dependencies**: ✅ Added dfloat11[cuda12], torchvision, latest diffusers
- **Memory Optimization**: ✅ CPU offloading support for 24GB GPU + 50GB RAM systems
- **Download Scripts**: ✅ Created download-dfloat11-model.py and monitoring script
- **Persistent Storage**: ✅ Models stored in `qwen-models-cache/` folder (survives container restarts)
- **Serverpod Integration**: ✅ Ready and configured with async job system
- **API Endpoints**: ✅ Implemented and tested (both sync and async)
- **Job Management**: ✅ Full async job system with background processing
- **Database**: ✅ Updated with processing_jobs table

### 📊 DFloat11 Model Download

The **DFloat11 compressed Qwen-Image-Edit model** is approximately **28GB** in size (32% smaller than the original 41GB model). 

**Download and monitor the model (run from project root):**

**🌙 Overnight Download (Recommended):**
```bash
# From project root directory (/path/to/image-editor)
# Optimized for overnight download - efficient monitoring, comprehensive logging
./monitor-dfloat11-download.sh

# Or run in background with nohup for complete hands-off operation:
nohup ./monitor-dfloat11-download.sh > overnight_download.log 2>&1 &
```

**Key Features:**
- ✅ **Comprehensive Download**: Ensures both base model AND DFloat11 compressed weights are downloaded
- ✅ **Bandwidth Efficient**: Uses 60-second intervals for overnight monitoring  
- ✅ **Detailed Logging**: Creates `dfloat11_download.log` with timestamped progress
- ✅ **Graceful Cleanup**: Handles interruptions cleanly
- ✅ **Auto-Testing**: Automatically tests the model when download completes
- ✅ **Resume Support**: Can resume interrupted downloads

**Quick Status Check:**
```bash
# Check current download status anytime
./check-dfloat11-status.sh
```

**Current setup:**
- ✅ **Persistent Storage**: Models stored in local `qwen-models-cache/` folder
- ✅ **Container Restarts**: Downloaded data is preserved across container restarts
- ✅ **Progress Monitoring**: Real-time monitoring script available

### ⏳ Next Steps

1. **Validate Model Loading**: Wait for Qwen-Image-Edit model to finish loading
2. **End-to-End Testing**: Test complete async workflow from job creation to completion
3. **Phase 4**: Update Flutter UI for async workflow with job status polling
4. **Phase 5**: Production optimization and deployment

## Resources

- [Qwen ImageEdit Documentation](https://huggingface.co/Qwen/Qwen-Image-Edit)
- [Serverpod Documentation](https://docs.serverpod.dev)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
