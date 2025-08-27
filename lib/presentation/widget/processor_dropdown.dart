import 'package:flutter/material.dart';

import '../../domain/model/image_processor.dart';

/// A dropdown widget for selecting image processors
class ProcessorDropdown extends StatelessWidget {
  final ImageProcessor? selectedProcessor;
  final Function(ImageProcessor?) onProcessorChanged;

  const ProcessorDropdown({
    super.key,
    this.selectedProcessor,
    required this.onProcessorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image Processor',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ImageProcessor>(
          // ignore: deprecated_member_use
          value: selectedProcessor,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          hint: const Text('Select a processor'),
          isExpanded: true,
          items: ImageProcessor.availableProcessors.map((processor) {
            return DropdownMenuItem<ImageProcessor>(
              value: processor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    processor.displayName,
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Flexible(
                    child: Text(
                      processor.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onProcessorChanged,
        ),
      ],
    );
  }
}
