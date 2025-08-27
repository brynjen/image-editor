import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/image_repository.dart';

/// Widget that loads and displays an image from the server
class ServerImageWidget extends StatefulWidget {
  final int imageId;
  final String imageName;
  final BoxFit fit;

  const ServerImageWidget({
    super.key,
    required this.imageId,
    required this.imageName,
    this.fit = BoxFit.cover,
  });

  @override
  State<ServerImageWidget> createState() => _ServerImageWidgetState();
}

class _ServerImageWidgetState extends State<ServerImageWidget> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final imageRepository = RepositoryProvider.of<ImageRepository>(context);
      final bytes = await imageRepository.getImageBytes(widget.imageId);
      
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
          _error = bytes == null ? 'Failed to load image' : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading image: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _imageBytes == null) {
      return Container(
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to Load',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.imageName,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Image.memory(
      _imageBytes!,
      fit: widget.fit,
    );
  }
}
