/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class ImageUploadResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ImageUploadResponse._({
    required this.success,
    this.imageId,
    this.message,
    this.filename,
  });

  factory ImageUploadResponse({
    required bool success,
    int? imageId,
    String? message,
    String? filename,
  }) = _ImageUploadResponseImpl;

  factory ImageUploadResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return ImageUploadResponse(
      success: jsonSerialization['success'] as bool,
      imageId: jsonSerialization['imageId'] as int?,
      message: jsonSerialization['message'] as String?,
      filename: jsonSerialization['filename'] as String?,
    );
  }

  bool success;

  int? imageId;

  String? message;

  String? filename;

  /// Returns a shallow copy of this [ImageUploadResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ImageUploadResponse copyWith({
    bool? success,
    int? imageId,
    String? message,
    String? filename,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (imageId != null) 'imageId': imageId,
      if (message != null) 'message': message,
      if (filename != null) 'filename': filename,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'success': success,
      if (imageId != null) 'imageId': imageId,
      if (message != null) 'message': message,
      if (filename != null) 'filename': filename,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ImageUploadResponseImpl extends ImageUploadResponse {
  _ImageUploadResponseImpl({
    required bool success,
    int? imageId,
    String? message,
    String? filename,
  }) : super._(
          success: success,
          imageId: imageId,
          message: message,
          filename: filename,
        );

  /// Returns a shallow copy of this [ImageUploadResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ImageUploadResponse copyWith({
    bool? success,
    Object? imageId = _Undefined,
    Object? message = _Undefined,
    Object? filename = _Undefined,
  }) {
    return ImageUploadResponse(
      success: success ?? this.success,
      imageId: imageId is int? ? imageId : this.imageId,
      message: message is String? ? message : this.message,
      filename: filename is String? ? filename : this.filename,
    );
  }
}
