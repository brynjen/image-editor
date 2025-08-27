import 'package:equatable/equatable.dart';

/// Represents a processing job status and information
class ProcessingJobModel extends Equatable {
  final int id;
  final int imageId;
  final String status;
  final String processorType;
  final String instructions;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double progress;
  final int? resultImageId;
  final String? errorMessage;

  const ProcessingJobModel({
    required this.id,
    required this.imageId,
    required this.status,
    required this.processorType,
    required this.instructions,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    required this.progress,
    this.resultImageId,
    this.errorMessage,
  });

  /// Job status constants
  static const String statusPending = 'pending';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusFailed = 'failed';
  static const String statusCancelled = 'cancelled';

  /// Check if job is still running
  bool get isActive => status == statusPending || status == statusInProgress;

  /// Check if job is completed successfully
  bool get isCompleted => status == statusCompleted;

  /// Check if job failed
  bool get isFailed => status == statusFailed;

  /// Check if job was cancelled
  bool get isCancelled => status == statusCancelled;

  /// Check if job is finished (completed, failed, or cancelled)
  bool get isFinished => isCompleted || isFailed || isCancelled;

  /// Get user-friendly status message
  String get statusMessage {
    switch (status) {
      case statusPending:
        return 'Waiting to start...';
      case statusInProgress:
        return 'Processing... ${(progress * 100).toInt()}%';
      case statusCompleted:
        return 'Completed successfully';
      case statusFailed:
        return errorMessage ?? 'Processing failed';
      case statusCancelled:
        return 'Processing cancelled';
      default:
        return 'Unknown status: $status';
    }
  }

  /// Create a copy with updated values
  ProcessingJobModel copyWith({
    int? id,
    int? imageId,
    String? status,
    String? processorType,
    String? instructions,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    double? progress,
    int? resultImageId,
    String? errorMessage,
  }) {
    return ProcessingJobModel(
      id: id ?? this.id,
      imageId: imageId ?? this.imageId,
      status: status ?? this.status,
      processorType: processorType ?? this.processorType,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
      resultImageId: resultImageId ?? this.resultImageId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        imageId,
        status,
        processorType,
        instructions,
        createdAt,
        startedAt,
        completedAt,
        progress,
        resultImageId,
        errorMessage,
      ];
}
