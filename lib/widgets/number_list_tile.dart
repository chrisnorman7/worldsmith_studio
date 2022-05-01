// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';

import '../intents.dart';
import 'get_number.dart';
import 'push_widget_list_tile.dart';

/// A list tile that displays and allows the editing of a numerical [value].
class NumberListTile extends StatelessWidget {
  /// Create an instance.
  const NumberListTile({
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.modifier = 1.0,
    this.title = 'Number',
    this.subtitle,
    this.autofocus = false,
    this.actions = const [],
    super.key,
  });

  /// The initial value.
  final double value;

  /// The function to be called with the new value.
  final ValueChanged<double> onChanged;

  /// The minimum value.
  final double? min;

  /// The maximum value.
  final double? max;

  /// How much to increment and decrement [value].
  final double modifier;

  /// The title for the resulting [ListTile].
  final String title;

  /// The subtitle to use for the resulting [ListTile].
  final String? subtitle;

  /// Whether the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Actions for the resulting [GetNumber].
  final List<Widget> actions;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final minValue = min;
    final maxValue = max;
    return CallbackShortcuts(
      bindings: {
        DecreaseIntent.hotkey: () {
          var n = value - modifier;
          if (minValue != null && n < minValue) {
            n = minValue;
          }
          onChanged(n);
        },
        IncreaseIntent.hotkey: () {
          var n = value + modifier;
          if (maxValue != null && n > maxValue) {
            n = maxValue;
          }
          onChanged(n);
        },
        HomeIntent.hotkey: () {
          if (minValue != null) {
            onChanged(minValue);
          }
        },
        EndIntent.hotkey: () {
          if (maxValue != null) {
            onChanged(maxValue);
          }
        }
      },
      child: PushWidgetListTile(
        autofocus: autofocus,
        title: title,
        subtitle: subtitle ?? value.toString(),
        builder: (final context) => GetNumber(
          value: value,
          onDone: (final value) {
            Navigator.pop(context);
            onChanged(value);
          },
          min: min,
          max: max,
          title: title,
          actions: actions,
        ),
      ),
    );
  }
}
