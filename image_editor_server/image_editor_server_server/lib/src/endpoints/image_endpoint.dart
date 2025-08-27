import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Endpoint for handling image upload and retrieval operations
class ImageEndpoint extends Endpoint {
  /// Health check endpoint to verify server connectivity
  Future<String> healthCheck(Session session) async {
    session.log('Health check requested');
    return 'OK';
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

  /// Process an image with given instructions
  Future<ImageUploadResponse> processImage(
    Session session,
    ImageProcessRequest request,
  ) async {
    try {
      // Get the original image
      final imageData = await ImageData.db.findById(session, request.imageId);
      if (imageData == null) {
        return ImageUploadResponse(
          success: false,
          message: 'Image not found',
        );
      }

      // For now, we'll just simulate processing by copying the original
      // In a real implementation, you would integrate with your image processing service
      final originalFile = File('storage/images/${imageData.filename}');
      if (!await originalFile.exists()) {
        return ImageUploadResponse(
          success: false,
          message: 'Original image file not found',
        );
      }

      // Generate processed filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageData.filename.split('.').last;
      final processedFilename = '${timestamp}_processed_${imageData.filename}';

      // For now, just copy the original (simulate processing)
      final processedFile = File('storage/images/$processedFilename');
      await originalFile.copy(processedFile.path);

      // Update the database record
      final updatedImageData = imageData.copyWith(
        processorType: request.processorType,
        instructions: request.instructions,
        processedAt: DateTime.now(),
        processedFilename: processedFilename,
      );

      await ImageData.db.updateRow(session, updatedImageData);

      return ImageUploadResponse(
        success: true,
        imageId: imageData.id!,
        message: 'Image processed successfully',
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
