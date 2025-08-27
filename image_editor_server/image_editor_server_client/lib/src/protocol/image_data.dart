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

abstract class ImageData implements _i1.SerializableModel {
  ImageData._({
    this.id,
    required this.filename,
    required this.originalName,
    required this.mimeType,
    required this.size,
    DateTime? uploadedAt,
    this.processorType,
    this.instructions,
    this.processedAt,
    this.processedFilename,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  factory ImageData({
    int? id,
    required String filename,
    required String originalName,
    required String mimeType,
    required int size,
    DateTime? uploadedAt,
    String? processorType,
    String? instructions,
    DateTime? processedAt,
    String? processedFilename,
  }) = _ImageDataImpl;

  factory ImageData.fromJson(Map<String, dynamic> jsonSerialization) {
    return ImageData(
      id: jsonSerialization['id'] as int?,
      filename: jsonSerialization['filename'] as String,
      originalName: jsonSerialization['originalName'] as String,
      mimeType: jsonSerialization['mimeType'] as String,
      size: jsonSerialization['size'] as int,
      uploadedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['uploadedAt']),
      processorType: jsonSerialization['processorType'] as String?,
      instructions: jsonSerialization['instructions'] as String?,
      processedAt: jsonSerialization['processedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['processedAt']),
      processedFilename: jsonSerialization['processedFilename'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String filename;

  String originalName;

  String mimeType;

  int size;

  DateTime uploadedAt;

  String? processorType;

  String? instructions;

  DateTime? processedAt;

  String? processedFilename;

  /// Returns a shallow copy of this [ImageData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ImageData copyWith({
    int? id,
    String? filename,
    String? originalName,
    String? mimeType,
    int? size,
    DateTime? uploadedAt,
    String? processorType,
    String? instructions,
    DateTime? processedAt,
    String? processedFilename,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'filename': filename,
      'originalName': originalName,
      'mimeType': mimeType,
      'size': size,
      'uploadedAt': uploadedAt.toJson(),
      if (processorType != null) 'processorType': processorType,
      if (instructions != null) 'instructions': instructions,
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
      if (processedFilename != null) 'processedFilename': processedFilename,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ImageDataImpl extends ImageData {
  _ImageDataImpl({
    int? id,
    required String filename,
    required String originalName,
    required String mimeType,
    required int size,
    DateTime? uploadedAt,
    String? processorType,
    String? instructions,
    DateTime? processedAt,
    String? processedFilename,
  }) : super._(
          id: id,
          filename: filename,
          originalName: originalName,
          mimeType: mimeType,
          size: size,
          uploadedAt: uploadedAt,
          processorType: processorType,
          instructions: instructions,
          processedAt: processedAt,
          processedFilename: processedFilename,
        );

  /// Returns a shallow copy of this [ImageData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ImageData copyWith({
    Object? id = _Undefined,
    String? filename,
    String? originalName,
    String? mimeType,
    int? size,
    DateTime? uploadedAt,
    Object? processorType = _Undefined,
    Object? instructions = _Undefined,
    Object? processedAt = _Undefined,
    Object? processedFilename = _Undefined,
  }) {
    return ImageData(
      id: id is int? ? id : this.id,
      filename: filename ?? this.filename,
      originalName: originalName ?? this.originalName,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      processorType:
          processorType is String? ? processorType : this.processorType,
      instructions: instructions is String? ? instructions : this.instructions,
      processedAt: processedAt is DateTime? ? processedAt : this.processedAt,
      processedFilename: processedFilename is String?
          ? processedFilename
          : this.processedFilename,
    );
  }
}
