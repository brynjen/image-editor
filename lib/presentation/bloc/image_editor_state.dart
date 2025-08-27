import 'package:equatable/equatable.dart';

import '../../domain/model/image_model.dart';
import '../../domain/model/image_processor.dart';

/// State class for image editor
class ImageEditorState extends Equatable {
  final ImageModel? inputImage;
  final ImageModel? outputImage;
  final ImageProcessor? selectedProcessor;
  final String instructions;
  final bool isProcessing;
  final String? errorMessage;

  const ImageEditorState({
    this.inputImage,
    this.outputImage,
    this.selectedProcessor,
    this.instructions = '',
    this.isProcessing = false,
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
      instructions.trim().isNotEmpty;

  /// Copy state with new values
  ImageEditorState copyWith({
    ImageModel? inputImage,
    ImageModel? outputImage,
    ImageProcessor? selectedProcessor,
    String? instructions,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return ImageEditorState(
      inputImage: inputImage ?? this.inputImage,
      outputImage: outputImage ?? this.outputImage,
      selectedProcessor: selectedProcessor ?? this.selectedProcessor,
      instructions: instructions ?? this.instructions,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Clear output image (used when input changes)
  ImageEditorState clearOutput() {
    return copyWith(
      outputImage: null,
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
        errorMessage,
      ];
}
