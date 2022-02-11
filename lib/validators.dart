/// Provides validators.
import 'dart:io';

/// Returns [message] if [value] is `null` or empty.
String? validateNonEmptyValue({
  required String? value,
  String message = 'You must supply a value',
}) {
  if (value == null || value.isEmpty) {
    return message;
  }
  return null;
}

/// Ensure the given [value] is a path.
String? validatePath({
  required String? value,
  bool allowDirectories = true,
  String emptyMessage = 'You must provide a file or folder to import',
  String invalidPathMessage = 'Not a file or folder',
}) {
  if (value == null || value.isEmpty) {
    return emptyMessage;
  }
  final file = File(value);
  if (file.existsSync()) {
    return null;
  }
  if (allowDirectories) {
    final directory = Directory(value);
    if (directory.existsSync()) {
      return null;
    }
  }
  return invalidPathMessage;
}
