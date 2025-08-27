import 'dart:typed_data';

/// Represents an image in the image editing process
class ImageModel {
  final String? path;
  final Uint8List? bytes;
  final String name;
  final int? serverpodImageId;
  final String? serverFilename;
  final bool isUploaded;

  const ImageModel({
    this.path,
    this.bytes,
    required this.name,
    this.serverpodImageId,
    this.serverFilename,
    this.isUploaded = false,
  });

  bool get hasImage => path != null || bytes != null || serverpodImageId != null;
  
  bool get isFromServer => serverpodImageId != null && serverFilename != null;

  ImageModel copyWith({
    String? path,
    Uint8List? bytes,
    String? name,
    int? serverpodImageId,
    String? serverFilename,
    bool? isUploaded,
  }) {
    return ImageModel(
      path: path ?? this.path,
      bytes: bytes ?? this.bytes,
      name: name ?? this.name,
      serverpodImageId: serverpodImageId ?? this.serverpodImageId,
      serverFilename: serverFilename ?? this.serverFilename,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }
}
