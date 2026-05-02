import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef TypingValidationCallback = void Function(String typedText, bool isComplete);
typedef TypingMistakeCallback = void Function(String expected, String entered, int errorIndex);

class TypingValidationWidget extends StatefulWidget {
  final String expectedText;
  final TypingValidationCallback? onChanged;
  final TypingMistakeCallback? onMistake;
  final VoidCallback? onCompleted;
  final bool enabled;

  const TypingValidationWidget({
    super.key,
    required this.expectedText,
    this.onChanged,
    this.onMistake,
    this.onCompleted,
    this.enabled = true,
  });

  @override
  State<TypingValidationWidget> createState() => _TypingValidationWidgetState();
}

class _TypingValidationWidgetState extends State<TypingValidationWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String _typedText = '';
  int _errorIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChanged(String text) {
    setState(() {
      _typedText = text;
    });

    final expected = widget.expectedText;
    var firstError = -1;

    for (var i = 0; i < text.length; i++) {
      if (i >= expected.length || text[i] != expected[i]) {
        firstError = i;
        break;
      }
    }

    if (firstError != -1 && firstError != _errorIndex) {
      HapticFeedback.mediumImpact();
      widget.onMistake?.call(expected, text, firstError);
    }

    _errorIndex = firstError;
    widget.onChanged?.call(text, text.trim() == expected.trim());

    if (text.trim() == expected.trim()) {
      widget.onCompleted?.call();
    }
  }

  List<InlineSpan> _buildTextSpans() {
    final expected = widget.expectedText;
    final typed = _typedText;
    final children = <InlineSpan>[];

    for (var i = 0; i < expected.length; i++) {
      final expectedChar = expected[i];
      final bool hasTyped = i < typed.length;
      final bool isCorrect = hasTyped && typed[i] == expectedChar;
      final bool isCurrent = i == typed.length - 1 && !isCorrect;

      Color color;
      if (hasTyped) {
        color = isCorrect ? Colors.green : Colors.red;
      } else {
        color = Colors.grey.shade600;
      }

      if (isCurrent) {
        color = Colors.orange;
      }

      children.add(TextSpan(
        text: expectedChar,
        style: TextStyle(
          color: color,
          fontWeight: hasTyped ? FontWeight.w600 : FontWeight.w400,
          fontSize: 18,
        ),
      ));
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: RichText(
            text: TextSpan(children: _buildTextSpans()),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          autocorrect: false,
          autofocus: true,
          maxLines: null,
          decoration: InputDecoration(
            hintText: 'Type the sentence exactly as shown',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          onChanged: _handleTextChanged,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mistakes: ${_errorIndex >= 0 ? _errorIndex + 1 : 0}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Length: ${_controller.text.length}/${widget.expectedText.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
