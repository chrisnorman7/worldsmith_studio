import 'dart:math';

import 'package:flutter/material.dart';

import 'get_text.dart';

final _regExp = RegExp(r'^(\d+)[, ]?(\d+)$');

/// A widget for getting a pair of coordinates.
class GetCoordinates extends StatelessWidget {
  /// Create an instance.
  const GetCoordinates({
    required this.value,
    required this.onDone,
    this.labelText = 'Coordinates',
    this.actions = const [],
    this.title = 'Get Coordinates',
    this.validator,
    Key? key,
  }) : super(key: key);

  /// The function to be called when editing is complete.
  final ValueChanged<Point<int>> onDone;

  /// The original value.
  final Point<int> value;

  /// The actions for the app bar.
  final List<Widget> actions;

  /// The title of the resulting widget.
  final String title;

  /// The label text for the resulting text field.
  final String labelText;

  /// A validator for the coordinates.
  final FormFieldValidator<Point<int>>? validator;

  @override
  Widget build(BuildContext context) => GetText(
        onDone: (value) {
          final Point<int> coordinates = getPoint(value);
          onDone(coordinates);
        },
        actions: actions,
        labelText: labelText,
        text: '${value.x},${value.y}',
        title: title,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'You must supply a value.';
          } else if (_regExp.hasMatch(value)) {
            final coordinates = getPoint(value);
            final func = validator;
            if (func == null) {
              return null;
            }
            return func(coordinates);
          } else {
            return 'Invalid number.';
          }
        },
      );

  /// Get a valid set of coordinates from the given [value].
  Point<int> getPoint(String value) {
    final match = _regExp.firstMatch(value)!;
    final x = int.parse(match.group(1)!);
    final y = int.parse(match.group(2)!);
    final coordinates = Point(x, y);
    return coordinates;
  }
}
