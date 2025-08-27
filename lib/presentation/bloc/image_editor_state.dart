import 'package:equatable/equatable.dart';

import '../../domain/model/image_model.dart';
import '../../domain/model/image_processor.dart';
import '../../domain/model/processing_job_model.dart';

/// State class for image editor
class ImageEditorState extends Equatable {
  final ImageModel? inputImage;
  final ImageModel? outputImage;
  final ImageProcessor? selectedProcessor;
  final String instructions;
  final bool isProcessing;
  final ProcessingJobModel? currentJob;
  final String? errorMessage;

  const ImageEditorState({
    this.inputImage,
    this.outputImage,
    this.selectedProcessor,
    this.instructions = '',
    this.isProcessing = false,
    this.currentJob,
    this.errorMessage,
  });

  /// Initial state with default processor selected
  factory ImageEditorState.initial() {
    return ImageEditorState(
      selectedProcessor: ImageProcessor.availableProcessors.isNotEmpty
          ? ImageProcessor.availableProcessors.first
          : null,
    );
  }

  /// Check if processing can be started
  bool get canProcess =>
      !isProcessing &&
      inputImage?.hasImage == true &&
      selectedProcessor != null &&
      instructions.trim().isNotEmpty &&
      (currentJob == null || currentJob!.isFinished);

  /// Check if there's an active job running
  bool get hasActiveJob => currentJob != null && currentJob!.isActive;

  /// Get current processing status message
  String? get processingStatus {
    if (currentJob != null) {
      return currentJob!.statusMessage;
    }
    return null;
  }

  /// Copy state with new values
  ImageEditorState copyWith({
    ImageModel? inputImage,
    ImageModel? outputImage,
    ImageProcessor? selectedProcessor,
    String? instructions,
    bool? isProcessing,
    ProcessingJobModel? currentJob,
    String? errorMessage,
  }) {
    return ImageEditorState(
      inputImage: inputImage ?? this.inputImage,
      outputImage: outputImage ?? this.outputImage,
      selectedProcessor: selectedProcessor ?? this.selectedProcessor,
      instructions: instructions ?? this.instructions,
      isProcessing: isProcessing ?? this.isProcessing,
      currentJob: currentJob ?? this.currentJob,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Clear output image and job (used when input changes)
  ImageEditorState clearOutput() {
    return copyWith(
      outputImage: null,
      currentJob: null,
      errorMessage: null,
    );
  }

  @override
  List<Object?> get props => [
        inputImage,
        outputImage,
        selectedProcessor,
        instructions,
        isProcessing,
        currentJob,
        errorMessage,
      ];
}
