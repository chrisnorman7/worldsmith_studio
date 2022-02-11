/// Provides the [CenterText] class.
import 'package:flutter/material.dart';

/// A widget that centers [text].
class CenterText extends StatelessWidget {
  /// Create an instance.
  const CenterText({required this.text, Key? key}) : super(key: key);

  /// The text to show.
  final String text;
  @override
  Widget build(BuildContext context) => Center(
        child: Text(text),
      );
}
