import 'package:flutter/material.dart';

/// Input widget for memorization practice
/// Allows users to type sentences from memory
class MemorizationInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const MemorizationInput({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<MemorizationInput> createState() => _MemorizationInputState();
}

class _MemorizationInputState extends State<MemorizationInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Type the sentence from memory:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TextField(
            controller: widget.controller,
            maxLines: null,
            expands: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Remember and type the sentence here',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onSubmit,
                child: const Text('Submit'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
