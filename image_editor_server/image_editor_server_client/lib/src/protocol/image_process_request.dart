/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class ImageProcessRequest implements _i1.SerializableModel {
  ImageProcessRequest._({
    required this.imageId,
    required this.processorType,
    required this.instructions,
  });

  factory ImageProcessRequest({
    required int imageId,
    required String processorType,
    required String instructions,
  }) = _ImageProcessRequestImpl;

  factory ImageProcessRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return ImageProcessRequest(
      imageId: jsonSerialization['imageId'] as int,
      processorType: jsonSerialization['processorType'] as String,
      instructions: jsonSerialization['instructions'] as String,
    );
  }

  int imageId;

  String processorType;

  String instructions;

  /// Returns a shallow copy of this [ImageProcessRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ImageProcessRequest copyWith({
    int? imageId,
    String? processorType,
    String? instructions,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'imageId': imageId,
      'processorType': processorType,
      'instructions': instructions,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ImageProcessRequestImpl extends ImageProcessRequest {
  _ImageProcessRequestImpl({
    required int imageId,
    required String processorType,
    required String instructions,
  }) : super._(
          imageId: imageId,
          processorType: processorType,
          instructions: instructions,
        );

  /// Returns a shallow copy of this [ImageProcessRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ImageProcessRequest copyWith({
    int? imageId,
    String? processorType,
    String? instructions,
  }) {
    return ImageProcessRequest(
      imageId: imageId ?? this.imageId,
      processorType: processorType ?? this.processorType,
      instructions: instructions ?? this.instructions,
    );
  }
}
