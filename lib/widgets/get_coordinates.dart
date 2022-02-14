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

  @override
  Widget build(BuildContext context) => GetText(
        onDone: (value) {
          final match = _regExp.firstMatch(value)!;
          final x = int.parse(match.group(1)!);
          final y = int.parse(match.group(2)!);
          onDone(Point(x, y));
        },
        actions: actions,
        labelText: labelText,
        text: '${value.x},${value.y}',
        title: title,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'You must supply a value.';
          } else if (_regExp.hasMatch(value)) {
            return null;
          } else {
            return 'Invalid number.';
          }
        },
      );
}
