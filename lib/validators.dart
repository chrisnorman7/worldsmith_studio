/// Provides validators.
import 'dart:io';

/// Returns [message] if [value] is `null` or empty.
String? validateNonEmptyValue({
  required final String? value,
  final String message = 'You must supply a value',
}) {
  if (value == null || value.isEmpty) {
    return message;
  }
  return null;
}

/// Ensure the given [value] is a path.
String? validatePath({
  required final String? value,
  final bool allowDirectories = true,
  final String emptyMessage = 'You must provide a file or folder to import',
  final String invalidPathMessage = 'Not a file or folder',
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

/// Ensure the given [value] is an integer.
String? validateInt({
  required final String? value,
  final String message = 'Invalid number',
}) =>
    value == null || value.isEmpty || int.tryParse(value) == null
        ? message
        : null;
