import 'package:flutter/material.dart';

import '../util.dart';
import 'get_number.dart';

/// A list tile that displays and allows the editing of a numerical [value].
class NumberListTile extends StatelessWidget {
  /// Create an instance.
  const NumberListTile({
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.title = 'Number',
    this.subtitle,
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

  /// The initial value.
  final double value;

  /// The function to be called with the new value.
  final ValueChanged<double> onChanged;

  /// The minimum value.
  final double? min;

  /// The maximum value.
  final double? max;

  /// The title for the resulting [ListTile].
  final String title;

  /// The subtitle to use for the resulting [ListTile].
  final String? subtitle;

  /// Whether the resulting [ListTile] should be autofocused.
  final bool autofocus;

  @override
  Widget build(BuildContext context) => ListTile(
        autofocus: autofocus,
        title: Text(title),
        subtitle: Text(subtitle ?? value.toString()),
        onTap: () => pushWidget(
          context: context,
          builder: (context) => GetNumber(
            value: value,
            onDone: (value) {
              Navigator.pop(context);
              onChanged(value);
            },
            max: max,
            min: min,
            title: title,
          ),
        ),
      );
}
