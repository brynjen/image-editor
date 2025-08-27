# API Documentation

Complete API reference for the Image Editor Serverpod backend.

## 🌐 Base URL

- **Development**: `http://localhost:8080`
- **Production**: `https://your-domain.com`

## 📋 Endpoints Overview

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/greeting/hello` | GET | Test endpoint |
| `/image/uploadImage` | POST | Upload image file |
| `/image/getImage/{id}` | GET | Get image metadata |
| `/image/getImageFile/{id}` | GET | Download image file |
| `/image/processImage` | POST | Process image (sync) |
| `/image/processImageAsync` | POST | Start async processing |
| `/image/listImages` | GET | List all images |
| `/job/getJobStatus/{id}` | GET | Get job status |
| `/job/listJobs` | GET | List processing jobs |

## 🔍 Detailed Endpoints

### Test Endpoint

#### GET `/greeting/hello`

Test endpoint to verify server connectivity.

**Parameters:**
- `name` (query, string): Name to include in greeting

**Response:**
```json
{
  "message": "Hello Test",
  "author": "Serverpod",
  "timestamp": "2025-08-27T14:14:36.439003Z"
}
```

**Example:**
```bash
curl "http://localhost:8080/greeting/hello?name=Test"
```

### Image Management

#### POST `/image/uploadImage`

Upload an image file to the server.

**Parameters:**
- `filename` (form, string): Original filename
- `name` (form, string): Display name
- `mimeType` (form, string): MIME type (image/jpeg, image/png, etc.)
- `data` (form, string): Base64-encoded image data

**Response:**
```json
{
  "success": true,
  "message": "Image uploaded successfully",
  "imageId": 123,
  "filename": "unique_server_filename.jpg"
}
```

**Example:**
```bash
curl -X POST "http://localhost:8080/image/uploadImage" \
  -F "filename=test.jpg" \
  -F "name=test.jpg" \
  -F "mimeType=image/jpeg" \
  -F "data=iVBORw0KGgoAAAANSUhEUgAA..."
```

#### GET `/image/getImage/{id}`

Get image metadata by ID.

**Parameters:**
- `id` (path, int): Image ID

**Response:**
```json
{
  "id": 123,
  "filename": "unique_server_filename.jpg",
  "originalName": "test.jpg",
  "mimeType": "image/jpeg",
  "size": 245760,
  "uploadedAt": "2025-08-27T14:14:36.439003Z",
  "processorType": null,
  "instructions": null,
  "processedAt": null,
  "processedFilename": null
}
```

#### GET `/image/getImageFile/{id}`

Download image file by ID.

**Parameters:**
- `id` (path, int): Image ID

**Response:**
- **Content-Type**: `image/*` (based on original MIME type)
- **Body**: Base64-encoded image data

**Example:**
```bash
curl "http://localhost:8080/image/getImageFile/123" > image.jpg
```

#### GET `/image/listImages`

List all uploaded images.

**Response:**
```json
[
  {
    "id": 123,
    "filename": "unique_server_filename.jpg",
    "originalName": "test.jpg",
    "mimeType": "image/jpeg",
    "size": 245760,
    "uploadedAt": "2025-08-27T14:14:36.439003Z"
  }
]
```

### Image Processing

#### POST `/image/processImage`

Process an image synchronously (deprecated - use async version).

**Request Body:**
```json
{
  "imageId": 123,
  "processorType": "qwen-image-edit",
  "instructions": "Add a hat to the person in the image"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Image processed successfully",
  "imageId": 124,
  "processingTime": 45.2
}
```

#### POST `/image/processImageAsync`

Start asynchronous image processing.

**Request Body:**
```json
{
  "imageId": 123,
  "processorType": "qwen-image-edit",
  "instructions": "Add a hat to the person in the image"
}
```

**Response:**
```json
{
  "id": 456,
  "imageId": 123,
  "status": "pending",
  "processorType": "qwen-image-edit",
  "instructions": "Add a hat to the person in the image",
  "createdAt": "2025-08-27T14:14:36.439003Z",
  "progress": 0.0,
  "resultImageId": null,
  "errorMessage": null
}
```

### Job Management

#### GET `/job/getJobStatus/{id}`

Get the status of a processing job.

**Parameters:**
- `id` (path, int): Job ID

**Response:**
```json
{
  "success": true,
  "job": {
    "id": 456,
    "imageId": 123,
    "status": "in_progress",
    "processorType": "qwen-image-edit",
    "instructions": "Add a hat to the person in the image",
    "createdAt": "2025-08-27T14:14:36.439003Z",
    "startedAt": "2025-08-27T14:15:00.000000Z",
    "completedAt": null,
    "progress": 0.65,
    "resultImageId": null,
    "errorMessage": null
  },
  "message": "Job is in progress"
}
```

#### GET `/job/listJobs`

List all processing jobs.

**Query Parameters:**
- `status` (optional, string): Filter by status (pending, in_progress, completed, failed)
- `limit` (optional, int): Maximum number of jobs to return (default: 50)
- `offset` (optional, int): Number of jobs to skip (default: 0)

**Response:**
```json
[
  {
    "id": 456,
    "imageId": 123,
    "status": "completed",
    "processorType": "qwen-image-edit",
    "instructions": "Add a hat to the person in the image",
    "createdAt": "2025-08-27T14:14:36.439003Z",
    "startedAt": "2025-08-27T14:15:00.000000Z",
    "completedAt": "2025-08-27T14:18:30.000000Z",
    "progress": 1.0,
    "resultImageId": 124,
    "errorMessage": null
  }
]
```

## 📊 Data Models

### ImageData

```typescript
interface ImageData {
  id: number;                    // Primary key
  filename: string;              // Unique server filename
  originalName: string;          // Original uploaded filename
  mimeType: string;              // MIME type (image/jpeg, image/png, etc.)
  size: number;                  // File size in bytes
  uploadedAt: string;            // ISO 8601 timestamp
  processorType?: string;        // AI processor used (nullable)
  instructions?: string;         // Processing instructions (nullable)
  processedAt?: string;          // Processing timestamp (nullable)
  processedFilename?: string;    // Processed image filename (nullable)
}
```

### ProcessingJob

```typescript
interface ProcessingJob {
  id: number;                    // Primary key
  imageId: number;               // Reference to ImageData
  status: JobStatus;             // Job status
  processorType: string;         // AI processor type
  instructions: string;          // Processing instructions
  createdAt: string;             // ISO 8601 timestamp
  startedAt?: string;            // When processing started (nullable)
  completedAt?: string;          // When processing completed (nullable)
  progress: number;              // Progress (0.0 - 1.0)
  resultImageId?: number;        // Reference to result ImageData (nullable)
  errorMessage?: string;         // Error details (nullable)
}

type JobStatus = 'pending' | 'in_progress' | 'completed' | 'failed' | 'cancelled';
```

### ImageProcessRequest

```typescript
interface ImageProcessRequest {
  imageId: number;               // ID of image to process
  processorType: string;         // AI processor to use
  instructions: string;          // Processing instructions
}
```

### UploadResponse

```typescript
interface UploadResponse {
  success: boolean;              // Upload success status
  message: string;               // Status message
  imageId?: number;              // ID of uploaded image (nullable)
  filename?: string;             // Server filename (nullable)
}
```

### ProcessResponse

```typescript
interface ProcessResponse {
  success: boolean;              // Processing success status
  message: string;               // Status message
  imageId?: number;              // ID of processed image (nullable)
  processingTime?: number;       // Processing time in seconds (nullable)
}
```

### JobStatusResponse

```typescript
interface JobStatusResponse {
  success: boolean;              // Request success status
  job?: ProcessingJob;           // Job details (nullable)
  message: string;               // Status message
}
```

## 🔧 Supported Processors

### qwen-image-edit
- **Description**: DFloat11 compressed Qwen-Image-Edit model
- **Capabilities**: General image editing with text instructions
- **Example Instructions**:
  - "Add a hat to the person"
  - "Change the background to a beach scene"
  - "Make the image black and white"
  - "Add sunglasses to the person"

### nano-banana (Future)
- **Description**: Lightweight image processor
- **Capabilities**: Basic image modifications
- **Status**: Planned for future implementation

## 🔒 Authentication

Currently, the API does not require authentication for development. For production deployment, implement:

- API key authentication
- JWT token-based authentication
- Rate limiting per user/IP
- Role-based access control

## ⚠️ Error Handling

### HTTP Status Codes

- **200 OK**: Successful request
- **400 Bad Request**: Invalid request parameters
- **404 Not Found**: Resource not found
- **500 Internal Server Error**: Server error
- **503 Service Unavailable**: AI processing service unavailable

### Error Response Format

```json
{
  "success": false,
  "message": "Error description",
  "error": "SPECIFIC_ERROR_CODE",
  "details": {
    "field": "validation error details"
  }
}
```

### Common Errors

#### Image Upload Errors
- `INVALID_IMAGE_FORMAT`: Unsupported image format
- `FILE_TOO_LARGE`: Image exceeds size limit
- `UPLOAD_FAILED`: Server storage error

#### Processing Errors
- `IMAGE_NOT_FOUND`: Invalid image ID
- `PROCESSOR_UNAVAILABLE`: AI service not available
- `PROCESSING_FAILED`: AI processing error
- `INVALID_INSTRUCTIONS`: Empty or invalid prompt

#### Job Errors
- `JOB_NOT_FOUND`: Invalid job ID
- `JOB_CANCELLED`: Job was cancelled
- `JOB_TIMEOUT`: Processing timed out

## 🚀 Rate Limits

### Development
- No rate limits applied

### Production (Recommended)
- **Image Upload**: 10 uploads per minute per IP
- **Processing**: 5 jobs per minute per IP
- **API Calls**: 100 requests per minute per IP

## 📝 Examples

### Complete Workflow Example

```bash
# 1. Upload an image
UPLOAD_RESPONSE=$(curl -X POST "http://localhost:8080/image/uploadImage" \
  -F "filename=test.jpg" \
  -F "name=test.jpg" \
  -F "mimeType=image/jpeg" \
  -F "data=$(base64 -i test.jpg)")

IMAGE_ID=$(echo $UPLOAD_RESPONSE | jq -r '.imageId')

# 2. Start async processing
JOB_RESPONSE=$(curl -X POST "http://localhost:8080/image/processImageAsync" \
  -H "Content-Type: application/json" \
  -d "{
    \"imageId\": $IMAGE_ID,
    \"processorType\": \"qwen-image-edit\",
    \"instructions\": \"Add a red hat to the person\"
  }")

JOB_ID=$(echo $JOB_RESPONSE | jq -r '.id')

# 3. Poll job status
while true; do
  STATUS_RESPONSE=$(curl "http://localhost:8080/job/getJobStatus/$JOB_ID")
  STATUS=$(echo $STATUS_RESPONSE | jq -r '.job.status')
  PROGRESS=$(echo $STATUS_RESPONSE | jq -r '.job.progress')
  
  echo "Status: $STATUS, Progress: $(echo "$PROGRESS * 100" | bc)%"
  
  if [ "$STATUS" = "completed" ] || [ "$STATUS" = "failed" ]; then
    break
  fi
  
  sleep 2
done

# 4. Download result if completed
if [ "$STATUS" = "completed" ]; then
  RESULT_IMAGE_ID=$(echo $STATUS_RESPONSE | jq -r '.job.resultImageId')
  curl "http://localhost:8080/image/getImageFile/$RESULT_IMAGE_ID" > result.jpg
  echo "Result saved to result.jpg"
fi
```
