import 'dart:typed_data';

/// Represents an image in the image editing process
class ImageModel {
  final String? path;
  final Uint8List? bytes;
  final String name;

  const ImageModel({
    this.path,
    this.bytes,
    required this.name,
  });

  bool get hasImage => path != null || bytes != null;
}
