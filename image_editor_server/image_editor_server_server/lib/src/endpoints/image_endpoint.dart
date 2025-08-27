import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/qwen_image_service.dart';
import '../services/job_processing_service.dart';

/// Endpoint for handling image upload and retrieval operations
class ImageEndpoint extends Endpoint {
  late final QwenImageService _qwenImageService;
  late final JobProcessingService _jobProcessingService;

  @override
  void initialize(Server server, String name, String? moduleName) {
    super.initialize(server, name, moduleName);
    _qwenImageService = QwenImageService();
    _jobProcessingService = JobProcessingService(_qwenImageService);
  }
  /// Health check endpoint to verify server connectivity
  Future<String> healthCheck(Session session) async {
    session.log('Health check requested');
    return 'OK';
  }

  /// Check Qwen Image Edit service health
  Future<Map<String, dynamic>> checkQwenHealth(Session session) async {
    session.log('Qwen health check requested');
    try {
      final isHealthy = await _qwenImageService.isHealthy();
      final models = await _qwenImageService.getModels();
      
      return {
        'qwen_service_healthy': isHealthy,
        'available_models': models,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      session.log('Error checking Qwen health: $e');
      return {
        'qwen_service_healthy': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
  /// Upload an image file and return the stored image data
  Future<ImageUploadResponse> uploadImage(
    Session session,
    String filename,
    String originalName,
    String mimeType,
    String imageDataBase64,
  ) async {
    try {
      session.log('Upload image requested: $originalName');
      
      // Decode base64 image data
      final imageBytes = base64Decode(imageDataBase64);
      session.log('Decoded image bytes: ${imageBytes.length}');
      
      // Create storage directory if it doesn't exist
      final storageDir = Directory('storage/images');
      if (!await storageDir.exists()) {
        await storageDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = originalName.split('.').last;
      final uniqueFilename = '${timestamp}_$filename.$extension';
      
      // Save file to storage
      final file = File('storage/images/$uniqueFilename');
      await file.writeAsBytes(imageBytes);

      // Create database record
      final imageData = ImageData(
        filename: uniqueFilename,
        originalName: originalName,
        mimeType: mimeType,
        size: imageBytes.length,
        uploadedAt: DateTime.now(),
      );

      final savedImage = await ImageData.db.insertRow(session, imageData);

      return ImageUploadResponse(
        success: true,
        imageId: savedImage.id!,
        message: 'Image uploaded successfully',
        filename: uniqueFilename,
      );
    } catch (e) {
      session.log('Error uploading image: $e');
      return ImageUploadResponse(
        success: false,
        message: 'Failed to upload image: $e',
      );
    }
  }

  /// Get image data by ID
  Future<ImageData?> getImage(Session session, int imageId) async {
    try {
      return await ImageData.db.findById(session, imageId);
    } catch (e) {
      session.log('Error getting image: $e');
      return null;
    }
  }

  /// Get image file bytes by ID as base64
  Future<String?> getImageFile(Session session, int imageId) async {
    try {
      session.log('Get image file requested: $imageId');
      final imageData = await ImageData.db.findById(session, imageId);
      if (imageData == null) {
        session.log('Image data not found for ID: $imageId');
        return null;
      }

      final file = File('storage/images/${imageData.filename}');
      if (!await file.exists()) {
        session.log('Image file not found: ${imageData.filename}');
        return null;
      }

      final imageBytes = await file.readAsBytes();
      session.log('Read image bytes: ${imageBytes.length}');
      
      // Return as base64 string
      return base64Encode(imageBytes);
    } catch (e) {
      session.log('Error getting image file: $e');
      return null;
    }
  }

  /// Create an async processing job for an image
  Future<ProcessingJob> processImageAsync(
    Session session,
    ImageProcessRequest request,
  ) async {
    try {
      session.log('Creating async processing job for image ${request.imageId}');

      // Verify the image exists
      final imageData = await ImageData.db.findById(session, request.imageId);
      if (imageData == null) {
        throw Exception('Image with ID ${request.imageId} not found');
      }

      // Create the processing job
      final job = await _jobProcessingService.createJob(
        session: session,
        imageId: request.imageId,
        processorType: request.processorType,
        instructions: request.instructions,
      );

      // Schedule the job for background processing
      await session.serverpod.futureCallWithDelay(
        'imageProcessing',
        ProcessingJob(
          id: job.id!,
          imageId: job.imageId,
          status: job.status,
          processorType: job.processorType,
          instructions: job.instructions,
          createdAt: job.createdAt,
          progress: job.progress,
        ),
        Duration.zero,
      );

      session.log('Created and scheduled processing job ${job.id}');
      return job;

    } catch (e) {
      session.log('Error creating async processing job: $e');
      rethrow;
    }
  }

  /// Process an image with given instructions using Qwen Image Edit service (synchronous - deprecated)
  /// Use processImageAsync for better performance and user experience
  Future<ImageUploadResponse> processImage(
    Session session,
    ImageProcessRequest request,
  ) async {
    try {
      session.log('Processing image request: ${request.imageId}, processor: ${request.processorType}');
      
      // Get the original image data
      final imageData = await ImageData.db.findById(session, request.imageId);
      if (imageData == null) {
        return ImageUploadResponse(
          success: false,
          message: 'Image not found',
        );
      }

      // Check if the original image file exists
      final originalFile = File('storage/images/${imageData.filename}');
      if (!await originalFile.exists()) {
        return ImageUploadResponse(
          success: false,
          message: 'Original image file not found',
        );
      }

      // Check if Qwen service is healthy
      final isHealthy = await _qwenImageService.isHealthy();
      if (!isHealthy) {
        session.log('Qwen Image service is not healthy, falling back to copy');
        // Fallback: just copy the original image
        return await _fallbackProcessing(session, imageData, request);
      }

      // Read the original image file and convert to base64
      final imageBytes = await originalFile.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      session.log('Sending image to Qwen service for processing');
      
      // Process the image using Qwen service
      final result = await _qwenImageService.processImage(
        imageBase64: imageBase64,
        prompt: request.instructions,
        model: request.processorType,
      );

      if (!result.success || result.processedImageBase64 == null) {
        session.log('Qwen processing failed: ${result.message}');
        // Fallback to copying original
        return await _fallbackProcessing(session, imageData, request);
      }

      // Decode the processed image
      final processedImageBytes = base64Decode(result.processedImageBase64!);
      
      // Generate processed filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final processedFilename = '${timestamp}_processed_${imageData.filename}';

      // Save the processed image
      final processedFile = File('storage/images/$processedFilename');
      await processedFile.writeAsBytes(processedImageBytes);

      // Create new database record for processed image
      final processedImageData = ImageData(
        filename: processedFilename,
        originalName: 'processed_${imageData.originalName}',
        mimeType: imageData.mimeType,
        size: processedImageBytes.length,
        uploadedAt: DateTime.now(),
        processorType: request.processorType,
        instructions: request.instructions,
        processedAt: DateTime.now(),
      );

      final savedProcessedImage = await ImageData.db.insertRow(session, processedImageData);

      session.log('Image processed successfully in ${result.processingTime?.toStringAsFixed(2)}s');

      return ImageUploadResponse(
        success: true,
        imageId: savedProcessedImage.id!,
        message: 'Image processed successfully using ${result.modelUsed}',
        filename: processedFilename,
      );

    } catch (e) {
      session.log('Error processing image: $e');
      return ImageUploadResponse(
        success: false,
        message: 'Failed to process image: $e',
      );
    }
  }

  /// Fallback processing method that just copies the original image
  Future<ImageUploadResponse> _fallbackProcessing(
    Session session,
    ImageData imageData,
    ImageProcessRequest request,
  ) async {
    try {
      session.log('Using fallback processing (copy original)');
      
      // Generate processed filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final processedFilename = '${timestamp}_fallback_${imageData.filename}';

      // Copy the original file
      final originalFile = File('storage/images/${imageData.filename}');
      final processedFile = File('storage/images/$processedFilename');
      await originalFile.copy(processedFile.path);

      // Create new database record for processed image
      final processedImageData = ImageData(
        filename: processedFilename,
        originalName: 'fallback_${imageData.originalName}',
        mimeType: imageData.mimeType,
        size: imageData.size,
        uploadedAt: DateTime.now(),
        processorType: request.processorType,
        instructions: request.instructions,
        processedAt: DateTime.now(),
      );

      final savedProcessedImage = await ImageData.db.insertRow(session, processedImageData);

      return ImageUploadResponse(
        success: true,
        imageId: savedProcessedImage.id!,
        message: 'Image processed using fallback method (Qwen service unavailable)',
        filename: processedFilename,
      );
    } catch (e) {
      throw Exception('Fallback processing failed: $e');
    }
  }

  /// List all images for a user (for now, all images)
  Future<List<ImageData>> listImages(Session session) async {
    session.log('List images requested');
    try {
      final images = await ImageData.db.find(session);
      session.log('Found ${images.length} images');
      return images;
    } catch (e) {
      session.log('Error listing images: $e');
      return [];
    }
  }
}
