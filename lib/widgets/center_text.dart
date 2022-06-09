import 'package:flutter/material.dart';

/// A widget that centers [text].
class CenterText extends StatelessWidget {
  /// Create an instance.
  const CenterText({required this.text, super.key});

  /// The text to show.
  final String text;
  @override
  Widget build(final BuildContext context) => Center(
        child: Text(text),
      );
}
