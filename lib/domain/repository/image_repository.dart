import 'dart:typed_data';
import '../model/image_model.dart';

/// Repository interface for image operations
abstract class ImageRepository {
  /// Upload an image to the server and return the updated model with server info
  Future<ImageModel?> uploadImage(ImageModel imageModel);
  
  /// Get image data from server by ID
  Future<Uint8List?> getImageBytes(int imageId);
  
  /// Process an image with given processor and instructions
  Future<ImageModel?> processImage(
    int imageId,
    String processorType,
    String instructions,
  );
  
  /// List all available images from server
  Future<List<ImageModel>> listImages();
}
