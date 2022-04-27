import 'package:worldsmith/worldsmith.dart';

/// A class to hold a [text] string, and a [sound].
class CustomMessage {
  /// Create an instance.
  const CustomMessage({
    this.text,
    this.sound,
  });

  /// The text to use.
  final String? text;

  /// The sound to use.
  final Sound? sound;
}
