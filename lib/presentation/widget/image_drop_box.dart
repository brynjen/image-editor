import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/model/image_model.dart';
import 'server_image_widget.dart';

/// A widget that allows users to drag and drop or select images
class ImageDropBox extends StatelessWidget {
  final String label;
  final ImageModel? image;
  final Function(ImageModel?)? onImageChanged;
  final bool isProcessing;
  final bool isReadOnly;

  const ImageDropBox({
    super.key,
    required this.label,
    this.image,
    this.onImageChanged,
    this.isProcessing = false,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 300,
            maxHeight: 400,
          ),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(8),
              dashPattern: const [6, 3],
              color: Theme.of(context).colorScheme.outline,
              strokeWidth: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: _buildContent(context),
              ),
            ),
          ),
        ),
        if (isProcessing) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (image?.hasImage == true) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: _buildImageWidget(),
          ),
          // Only show close button for input images (not read-only)
          if (!isReadOnly && onImageChanged != null)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => onImageChanged!(null),
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.error,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
        ],
      );
    }

    // Show different content for read-only vs interactive boxes
    if (isReadOnly) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Processed image will appear here',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onImageChanged != null ? _selectImage : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Click to select image',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'or drag and drop here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    // For images from server, use ServerImageWidget to load and display
    if (image?.isFromServer == true && image!.serverpodImageId != null) {
      return ServerImageWidget(
        imageId: image!.serverpodImageId!,
        imageName: image!.name,
        fit: BoxFit.cover,
      );
    } else if (image?.path != null) {
      return Image.file(
        File(image!.path!),
        fit: BoxFit.cover,
      );
    } else if (image?.bytes != null) {
      return Image.memory(
        image!.bytes!,
        fit: BoxFit.cover,
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _selectImage() async {
    if (onImageChanged == null || isReadOnly) return;
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final imageModel = ImageModel(
          path: file.path,
          bytes: file.bytes,
          name: file.name,
        );
        onImageChanged!(imageModel);
      }
    } catch (e) {
      // Handle error silently for now
      debugPrint('Error selecting image: $e');
    }
  }
}
