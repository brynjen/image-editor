/// Represents an available image processing model
class ImageProcessor {
  final String id;
  final String displayName;
  final String description;

  const ImageProcessor({
    required this.id,
    required this.displayName,
    required this.description,
  });

  static const List<ImageProcessor> availableProcessors = [
    ImageProcessor(
      id: 'qwen-image-edit',
      displayName: 'Qwen Image Edit',
      description: 'Advanced image editing with AI',
    ),
  ];
}
