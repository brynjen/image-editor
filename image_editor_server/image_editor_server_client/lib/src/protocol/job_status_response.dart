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

abstract class JobStatusResponse implements _i1.SerializableModel {
  JobStatusResponse._({
    required this.jobId,
    required this.status,
    required this.progress,
    this.message,
    this.resultImageId,
    this.processingTimeMs,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  factory JobStatusResponse({
    required int jobId,
    required String status,
    required double progress,
    String? message,
    int? resultImageId,
    int? processingTimeMs,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _JobStatusResponseImpl;

  factory JobStatusResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return JobStatusResponse(
      jobId: jsonSerialization['jobId'] as int,
      status: jsonSerialization['status'] as String,
      progress: (jsonSerialization['progress'] as num).toDouble(),
      message: jsonSerialization['message'] as String?,
      resultImageId: jsonSerialization['resultImageId'] as int?,
      processingTimeMs: jsonSerialization['processingTimeMs'] as int?,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      startedAt: jsonSerialization['startedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startedAt']),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt']),
    );
  }

  int jobId;

  String status;

  double progress;

  String? message;

  int? resultImageId;

  int? processingTimeMs;

  DateTime createdAt;

  DateTime? startedAt;

  DateTime? completedAt;

  /// Returns a shallow copy of this [JobStatusResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  JobStatusResponse copyWith({
    int? jobId,
    String? status,
    double? progress,
    String? message,
    int? resultImageId,
    int? processingTimeMs,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'status': status,
      'progress': progress,
      if (message != null) 'message': message,
      if (resultImageId != null) 'resultImageId': resultImageId,
      if (processingTimeMs != null) 'processingTimeMs': processingTimeMs,
      'createdAt': createdAt.toJson(),
      if (startedAt != null) 'startedAt': startedAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _JobStatusResponseImpl extends JobStatusResponse {
  _JobStatusResponseImpl({
    required int jobId,
    required String status,
    required double progress,
    String? message,
    int? resultImageId,
    int? processingTimeMs,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) : super._(
          jobId: jobId,
          status: status,
          progress: progress,
          message: message,
          resultImageId: resultImageId,
          processingTimeMs: processingTimeMs,
          createdAt: createdAt,
          startedAt: startedAt,
          completedAt: completedAt,
        );

  /// Returns a shallow copy of this [JobStatusResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  JobStatusResponse copyWith({
    int? jobId,
    String? status,
    double? progress,
    Object? message = _Undefined,
    Object? resultImageId = _Undefined,
    Object? processingTimeMs = _Undefined,
    DateTime? createdAt,
    Object? startedAt = _Undefined,
    Object? completedAt = _Undefined,
  }) {
    return JobStatusResponse(
      jobId: jobId ?? this.jobId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      message: message is String? ? message : this.message,
      resultImageId: resultImageId is int? ? resultImageId : this.resultImageId,
      processingTimeMs:
          processingTimeMs is int? ? processingTimeMs : this.processingTimeMs,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt is DateTime? ? startedAt : this.startedAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
    );
  }
}
