import 'package:flutter/material.dart';

/// A text field for entering image editing instructions
class InstructionTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const InstructionTextField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Editing Instructions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: 'Describe what you want to do with the image...',
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
