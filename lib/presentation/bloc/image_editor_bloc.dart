import 'package:flutter_bloc/flutter_bloc.dart';

import 'image_editor_event.dart';
import 'image_editor_state.dart';

/// BLoC for managing image editor state
class ImageEditorBloc extends Bloc<ImageEditorEvent, ImageEditorState> {
  ImageEditorBloc() : super(ImageEditorState.initial()) {
    on<InputImageSelected>(_onInputImageSelected);
    on<ProcessorSelected>(_onProcessorSelected);
    on<InstructionsChanged>(_onInstructionsChanged);
    on<ProcessImageRequested>(_onProcessImageRequested);
    on<OutputImageCleared>(_onOutputImageCleared);
  }

  void _onInputImageSelected(
    InputImageSelected event,
    Emitter<ImageEditorState> emit,
  ) {
    emit(state.copyWith(
      inputImage: event.image,
      outputImage: null, // Clear output when input changes
      errorMessage: null,
    ));
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
    if (!state.canProcess) return;

    emit(state.copyWith(
      isProcessing: true,
      outputImage: null,
      errorMessage: null,
    ));

    try {
      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 3));

      // For now, just copy the input image to output as a placeholder
      emit(state.copyWith(
        isProcessing: false,
        outputImage: state.inputImage,
      ));
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
