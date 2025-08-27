import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repository/image_repository.dart';
import '../bloc/image_editor_bloc.dart';
import '../bloc/image_editor_event.dart';
import '../bloc/image_editor_state.dart';
import '../widget/image_drop_box.dart';
import '../widget/instruction_text_field.dart';
import '../widget/job_status_widget.dart';
import '../widget/processor_dropdown.dart';
import '../widget/server_status_widget.dart';

/// Main screen for image editing functionality
class ImageEditorScreen extends StatelessWidget {
  final ImageRepository imageRepository;
  
  const ImageEditorScreen({
    super.key,
    required this.imageRepository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ImageEditorBloc(imageRepository),
      child: const _ImageEditorView(),
    );
  }
}

/// Internal view widget that uses BLoC
class _ImageEditorView extends StatefulWidget {
  const _ImageEditorView();

  @override
  State<_ImageEditorView> createState() => _ImageEditorViewState();
}

class _ImageEditorViewState extends State<_ImageEditorView> {
  final TextEditingController _instructionController = TextEditingController();

  @override
  void dispose() {
    _instructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ImageEditorBloc, ImageEditorState>(
      listener: (context, state) {
        // Update text controller when instructions change
        if (_instructionController.text != state.instructions) {
          _instructionController.text = state.instructions;
        }

        // Show success/error messages
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.currentJob?.isCompleted == true && state.outputImage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image processing completed!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Image Editor'),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: ServerStatusWidget(),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 800;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48, // Account for padding
                ),
                child: BlocBuilder<ImageEditorBloc, ImageEditorState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image boxes section
                        if (isWideScreen)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ImageDropBox(
                                    label: 'Input Image',
                                    image: state.inputImage,
                                    isProcessing: state.isProcessing,
                                    onImageChanged: (image) {
                                      context.read<ImageEditorBloc>().add(
                                        InputImageSelected(image),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: ImageDropBox(
                                    label: 'Output Image',
                                    image: state.outputImage,
                                    isProcessing: state.isProcessing,
                                    isReadOnly: true,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: [
                              ImageDropBox(
                                label: 'Input Image',
                                image: state.inputImage,
                                isProcessing: state.isProcessing,
                                onImageChanged: (image) {
                                  context.read<ImageEditorBloc>().add(
                                    InputImageSelected(image),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              ImageDropBox(
                                label: 'Output Image',
                                image: state.outputImage,
                                isProcessing: state.isProcessing,
                                isReadOnly: true,
                              ),
                            ],
                          ),
                        const SizedBox(height: 32),
                        
                        // Controls section
                        if (isWideScreen)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: InstructionTextField(
                                  controller: _instructionController,
                                  onChanged: (value) {
                                    context.read<ImageEditorBloc>().add(
                                      InstructionsChanged(value),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: ProcessorDropdown(
                                  selectedProcessor: state.selectedProcessor,
                                  onProcessorChanged: (processor) {
                                    if (processor != null) {
                                      context.read<ImageEditorBloc>().add(
                                        ProcessorSelected(processor),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              InstructionTextField(
                                controller: _instructionController,
                                onChanged: (value) {
                                  context.read<ImageEditorBloc>().add(
                                    InstructionsChanged(value),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              ProcessorDropdown(
                                selectedProcessor: state.selectedProcessor,
                                onProcessorChanged: (processor) {
                                  if (processor != null) {
                                    context.read<ImageEditorBloc>().add(
                                      ProcessorSelected(processor),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        const SizedBox(height: 32),
                        
                        // Job status widget
                        JobStatusWidget(
                          job: state.currentJob,
                          onCancel: state.hasActiveJob
                              ? () {
                                  // TODO: Implement job cancellation
                                  context.read<ImageEditorBloc>().add(
                                    const OutputImageCleared(),
                                  );
                                }
                              : null,
                        ),
                        
                        // Process button
                        Center(
                          child: SizedBox(
                            width: 200,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: state.canProcess
                                  ? () {
                                      context.read<ImageEditorBloc>().add(
                                        const ProcessImageRequested(),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: state.isProcessing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      state.hasActiveJob ? 'Processing...' : 'Start Processing',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
