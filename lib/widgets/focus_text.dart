// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';

/// Text that can be focused.
class FocusText extends StatelessWidget {
  /// Create an instance.
  const FocusText({
    required this.text,
    this.autofocus = false,
    super.key,
  });

  /// The text to show.
  final String text;

  /// Whether the resulting [Focus] will be autofocused.
  final bool autofocus;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => Focus(
        child: Text(text),
        autofocus: autofocus,
      );
}
