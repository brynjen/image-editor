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

abstract class ProcessingJob implements _i1.SerializableModel {
  ProcessingJob._({
    this.id,
    required this.imageId,
    String? status,
    required this.processorType,
    required this.instructions,
    DateTime? createdAt,
    this.startedAt,
    this.completedAt,
    this.errorMessage,
    this.processingTimeMs,
    this.resultImageId,
    double? progress,
  })  : status = status ?? 'pending',
        createdAt = createdAt ?? DateTime.now(),
        progress = progress ?? 0.0;

  factory ProcessingJob({
    int? id,
    required int imageId,
    String? status,
    required String processorType,
    required String instructions,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    int? processingTimeMs,
    int? resultImageId,
    double? progress,
  }) = _ProcessingJobImpl;

  factory ProcessingJob.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProcessingJob(
      id: jsonSerialization['id'] as int?,
      imageId: jsonSerialization['imageId'] as int,
      status: jsonSerialization['status'] as String,
      processorType: jsonSerialization['processorType'] as String,
      instructions: jsonSerialization['instructions'] as String,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      startedAt: jsonSerialization['startedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt']),
      errorMessage: jsonSerialization['errorMessage'] as String?,
      processingTimeMs: jsonSerialization['processingTimeMs'] as int?,
      resultImageId: jsonSerialization['resultImageId'] as int?,
      progress: (jsonSerialization['progress'] as num).toDouble(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int imageId;

  String status;

  String processorType;

  String instructions;

  DateTime createdAt;

  DateTime? startedAt;

  DateTime? completedAt;

  String? errorMessage;

  int? processingTimeMs;

  int? resultImageId;

  double progress;

  /// Returns a shallow copy of this [ProcessingJob]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProcessingJob copyWith({
    int? id,
    int? imageId,
    String? status,
    String? processorType,
    String? instructions,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    int? processingTimeMs,
    int? resultImageId,
    double? progress,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'imageId': imageId,
      'status': status,
      'processorType': processorType,
      'instructions': instructions,
      'createdAt': createdAt.toJson(),
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (processingTimeMs != null) 'processingTimeMs': processingTimeMs,
      if (resultImageId != null) 'resultImageId': resultImageId,
      'progress': progress,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProcessingJobImpl extends ProcessingJob {
  _ProcessingJobImpl({
    int? id,
    required int imageId,
    String? status,
    required String processorType,
    required String instructions,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    int? processingTimeMs,
    int? resultImageId,
    double? progress,
  }) : super._(
          id: id,
          imageId: imageId,
          status: status,
          processorType: processorType,
          instructions: instructions,
          createdAt: createdAt,
          startedAt: startedAt,
          completedAt: completedAt,
          errorMessage: errorMessage,
          processingTimeMs: processingTimeMs,
          resultImageId: resultImageId,
          progress: progress,
        );

  /// Returns a shallow copy of this [ProcessingJob]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProcessingJob copyWith({
    Object? id = _Undefined,
    int? imageId,
    String? status,
    String? processorType,
    String? instructions,
    DateTime? createdAt,
    Object? startedAt = _Undefined,
    Object? completedAt = _Undefined,
    Object? errorMessage = _Undefined,
    Object? processingTimeMs = _Undefined,
    Object? resultImageId = _Undefined,
    double? progress,
  }) {
    return ProcessingJob(
      id: id is int? ? id : this.id,
      imageId: imageId ?? this.imageId,
      status: status ?? this.status,
      processorType: processorType ?? this.processorType,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt is DateTime? ? startedAt : this.startedAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
      processingTimeMs:
          processingTimeMs is int? ? processingTimeMs : this.processingTimeMs,
      resultImageId: resultImageId is int? ? resultImageId : this.resultImageId,
      progress: progress ?? this.progress,
    );
  }
}
