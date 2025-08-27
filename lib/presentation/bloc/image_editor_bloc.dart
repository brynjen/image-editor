import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repository/image_repository.dart';
import 'image_editor_event.dart';
import 'image_editor_state.dart';

/// BLoC for managing image editor state
class ImageEditorBloc extends Bloc<ImageEditorEvent, ImageEditorState> {
  final ImageRepository _imageRepository;
  
  ImageEditorBloc(this._imageRepository) : super(ImageEditorState.initial()) {
    on<InputImageSelected>(_onInputImageSelected);
    on<ProcessorSelected>(_onProcessorSelected);
    on<InstructionsChanged>(_onInstructionsChanged);
    on<ProcessImageRequested>(_onProcessImageRequested);
    on<OutputImageCleared>(_onOutputImageCleared);
  }

  Future<void> _onInputImageSelected(
    InputImageSelected event,
    Emitter<ImageEditorState> emit,
  ) async {
    emit(state.copyWith(
      inputImage: event.image,
      outputImage: null, // Clear output when input changes
      errorMessage: null,
    ));

    // Upload the image to Serverpod if it's a new local image
    if (event.image != null && !event.image!.isUploaded && event.image!.hasImage) {
      try {
        emit(state.copyWith(isProcessing: true));
        
        final uploadedImage = await _imageRepository.uploadImage(event.image!);
        if (uploadedImage != null) {
          emit(state.copyWith(
            inputImage: uploadedImage,
            isProcessing: false,
          ));
        } else {
          emit(state.copyWith(
            inputImage: null, // Clear the failed image
            isProcessing: false,
            errorMessage: 'Failed to upload image to server',
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          inputImage: null, // Clear the failed image
          isProcessing: false,
          errorMessage: 'Error uploading image: $e',
        ));
      }
    }
  }

  void _onProcessorSelected(
    ProcessorSelected event,
    Emitter<ImageEditorState> emit,
  ) {
    emit(state.copyWith(
      selectedProcessor: event.processor,
      errorMessage: null,
    ));
  }

  void _onInstructionsChanged(
    InstructionsChanged event,
    Emitter<ImageEditorState> emit,
  ) {
    emit(state.copyWith(
      instructions: event.instructions,
      errorMessage: null,
    ));
  }

  Future<void> _onProcessImageRequested(
    ProcessImageRequested event,
    Emitter<ImageEditorState> emit,
  ) async {
    if (!state.canProcess || state.inputImage?.serverpodImageId == null) return;

    emit(state.copyWith(
      isProcessing: true,
      outputImage: null,
      errorMessage: null,
    ));

    try {
      final processedImage = await _imageRepository.processImage(
        state.inputImage!.serverpodImageId!,
        state.selectedProcessor!.id,
        state.instructions,
      );

      if (processedImage != null) {
        emit(state.copyWith(
          isProcessing: false,
          outputImage: processedImage,
        ));
      } else {
        emit(state.copyWith(
          isProcessing: false,
          errorMessage: 'Failed to process image',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: 'Processing failed: ${e.toString()}',
      ));
    }
  }

  void _onOutputImageCleared(
    OutputImageCleared event,
    Emitter<ImageEditorState> emit,
  ) {
    emit(state.copyWith(
      outputImage: null,
      errorMessage: null,
    ));
  }
}
