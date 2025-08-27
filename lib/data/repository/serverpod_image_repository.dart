import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_editor_server_client/image_editor_server_client.dart';
import '../../domain/model/image_model.dart';
import '../../domain/repository/image_repository.dart';

/// Serverpod implementation of the image repository
class ServerpodImageRepository implements ImageRepository {
  final Client _client;
  
  ServerpodImageRepository(this._client);

  @override
  Future<ImageModel?> uploadImage(ImageModel imageModel) async {
    print('ServerpodImageRepository: Starting upload for ${imageModel.name}');
    try {
      Uint8List? imageBytes;
      
      // Get image bytes from either path or bytes
      if (imageModel.path != null) {
        final file = File(imageModel.path!);
        if (await file.exists()) {
          imageBytes = await file.readAsBytes();
        }
      } else if (imageModel.bytes != null) {
        imageBytes = imageModel.bytes!;
      }
      
      if (imageBytes == null) {
        print('ServerpodImageRepository: No image bytes found');
        return null;
      }

      print('ServerpodImageRepository: Image bytes size: ${imageBytes.length}');

      // Determine MIME type based on file extension
      final extension = imageModel.name.split('.').last.toLowerCase();
      final mimeType = _getMimeType(extension);
      
      print('ServerpodImageRepository: Uploading ${imageModel.name} (${mimeType}, ${imageBytes.length} bytes)');
      
      // Convert bytes to base64 for Serverpod
      final base64Data = base64Encode(imageBytes);
      print('ServerpodImageRepository: Base64 data length: ${base64Data.length}');
      
      final response = await _client.image.uploadImage(
        imageModel.name,
        imageModel.name,
        mimeType,
        base64Data,
      );
      
      print('ServerpodImageRepository: Upload response - success: ${response.success}, message: ${response.message}');

      if (response.success && response.imageId != null) {
        return imageModel.copyWith(
          serverpodImageId: response.imageId,
          serverFilename: response.filename,
          isUploaded: true,
        );
      }
      
      print('ServerpodImageRepository: Upload failed - response not successful');
      return null;
    } catch (e) {
      print('ServerpodImageRepository: Upload error: $e');
      return null;
    }
  }

  @override
  Future<Uint8List?> getImageBytes(int imageId) async {
    try {
      print('ServerpodImageRepository: Getting image bytes for ID: $imageId');
      final base64Data = await _client.image.getImageFile(imageId);
      if (base64Data == null) {
        print('ServerpodImageRepository: No base64 data received');
        return null;
      }
      
      print('ServerpodImageRepository: Received base64 data length: ${base64Data.length}');
      final imageBytes = base64Decode(base64Data);
      print('ServerpodImageRepository: Decoded image bytes: ${imageBytes.length}');
      
      return imageBytes;
    } catch (e) {
      print('ServerpodImageRepository: Error getting image bytes: $e');
      return null;
    }
  }

  @override
  Future<ImageModel?> processImage(
    int imageId,
    String processorType,
    String instructions,
  ) async {
    try {
      final request = ImageProcessRequest(
        imageId: imageId,
        processorType: processorType,
        instructions: instructions,
      );
      
      final response = await _client.image.processImage(request);
      
      if (response.success && response.imageId != null) {
        // Get the updated image data
        final imageData = await _client.image.getImage(response.imageId!);
        if (imageData != null) {
          return ImageModel(
            name: imageData.originalName,
            serverpodImageId: imageData.id!,
            serverFilename: imageData.processedFilename ?? imageData.filename,
            isUploaded: true,
          );
        }
      }
      
      return null;
    } catch (e) {
      print('Error processing image: $e');
      return null;
    }
  }

  @override
  Future<List<ImageModel>> listImages() async {
    try {
      final images = await _client.image.listImages();
      return images.map((imageData) => ImageModel(
        name: imageData.originalName,
        serverpodImageId: imageData.id!,
        serverFilename: imageData.filename,
        isUploaded: true,
      )).toList();
    } catch (e) {
      print('Error listing images: $e');
      return [];
    }
  }

  String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
