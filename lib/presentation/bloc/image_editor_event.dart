import 'package:equatable/equatable.dart';

import '../../domain/model/image_model.dart';
import '../../domain/model/image_processor.dart';

/// Base class for all image editor events
abstract class ImageEditorEvent extends Equatable {
  const ImageEditorEvent();

  @override
  List<Object?> get props => [];
}

/// Event to select an input image
class InputImageSelected extends ImageEditorEvent {
  final ImageModel? image;

  const InputImageSelected(this.image);

  @override
  List<Object?> get props => [image];
}

/// Event to select a processor
class ProcessorSelected extends ImageEditorEvent {
  final ImageProcessor processor;

  const ProcessorSelected(this.processor);

  @override
  List<Object?> get props => [processor];
}

/// Event to update instructions
class InstructionsChanged extends ImageEditorEvent {
  final String instructions;

  const InstructionsChanged(this.instructions);

  @override
  List<Object?> get props => [instructions];
}

/// Event to start image processing
class ProcessImageRequested extends ImageEditorEvent {
  const ProcessImageRequested();
}

/// Event to clear output image
class OutputImageCleared extends ImageEditorEvent {
  const OutputImageCleared();
}

/// Event to poll job status
class JobStatusPolled extends ImageEditorEvent {
  final int jobId;

  const JobStatusPolled(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

/// Event when job status is updated
class JobStatusUpdated extends ImageEditorEvent {
  final int jobId;

  const JobStatusUpdated(this.jobId);

  @override
  List<Object?> get props => [jobId];
}
