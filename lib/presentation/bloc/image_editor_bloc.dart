import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/model/image_model.dart';
import '../../domain/repository/image_repository.dart';
import 'image_editor_event.dart';
import 'image_editor_state.dart';

/// BLoC for managing image editor state
class ImageEditorBloc extends Bloc<ImageEditorEvent, ImageEditorState> {
  final ImageRepository _imageRepository;
  Timer? _jobPollingTimer;
  
  ImageEditorBloc(this._imageRepository) : super(ImageEditorState.initial()) {
    on<InputImageSelected>(_onInputImageSelected);
    on<ProcessorSelected>(_onProcessorSelected);
    on<InstructionsChanged>(_onInstructionsChanged);
    on<ProcessImageRequested>(_onProcessImageRequested);
    on<OutputImageCleared>(_onOutputImageCleared);
    on<JobStatusPolled>(_onJobStatusPolled);
    on<JobStatusUpdated>(_onJobStatusUpdated);
  }

  @override
  Future<void> close() {
    _jobPollingTimer?.cancel();
    return super.close();
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
      currentJob: null,
      errorMessage: null,
    ));

    try {
      // Start async processing
      final job = await _imageRepository.processImageAsync(
        state.inputImage!.serverpodImageId!,
        state.selectedProcessor!.id,
        state.instructions,
      );

      if (job != null) {
        emit(state.copyWith(
          isProcessing: false,
          currentJob: job,
        ));

        // Start polling for job status
        _startJobPolling(job.id);
      } else {
        emit(state.copyWith(
          isProcessing: false,
          errorMessage: 'Failed to start image processing',
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
    _stopJobPolling();
    emit(state.copyWith(
      outputImage: null,
      currentJob: null,
      errorMessage: null,
    ));
  }

  Future<void> _onJobStatusPolled(
    JobStatusPolled event,
    Emitter<ImageEditorState> emit,
  ) async {
    try {
      final updatedJob = await _imageRepository.getJobStatus(event.jobId);
      if (updatedJob != null) {
        emit(state.copyWith(currentJob: updatedJob));

        // If job is completed, get the result image
        if (updatedJob.isCompleted && updatedJob.resultImageId != null) {
          final resultImage = await _getImageModel(updatedJob.resultImageId!);
          if (resultImage != null) {
            emit(state.copyWith(outputImage: resultImage));
          }
          _stopJobPolling();
        } else if (updatedJob.isFailed || updatedJob.isCancelled) {
          emit(state.copyWith(
            errorMessage: updatedJob.errorMessage ?? 'Processing failed',
          ));
          _stopJobPolling();
        }
      }
    } catch (e) {
      print('Error polling job status: $e');
    }
  }

  Future<void> _onJobStatusUpdated(
    JobStatusUpdated event,
    Emitter<ImageEditorState> emit,
  ) async {
    // This can be used for external job status updates if needed
    add(JobStatusPolled(event.jobId));
  }

  /// Start polling for job status updates
  void _startJobPolling(int jobId) {
    _stopJobPolling(); // Stop any existing timer
    
    _jobPollingTimer = Timer.periodic(
      const Duration(seconds: 2), // Poll every 2 seconds
      (timer) {
        add(JobStatusPolled(jobId));
      },
    );
  }

  /// Stop job polling
  void _stopJobPolling() {
    _jobPollingTimer?.cancel();
    _jobPollingTimer = null;
  }

  /// Get image model from image ID
  Future<ImageModel?> _getImageModel(int imageId) async {
    try {
      // This would need to be implemented in the repository
      // For now, create a basic image model
      return ImageModel(
        name: 'processed_image.png',
        serverpodImageId: imageId,
        isUploaded: true,
      );
    } catch (e) {
      print('Error getting image model: $e');
      return null;
    }
  }
}
