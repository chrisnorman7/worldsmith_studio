import 'package:flutter/material.dart';

import '../number_list_tile.dart';

/// A widget for editing a gain value.
class GainListTile extends StatelessWidget {
  /// Create an instance.
  const GainListTile({
    required this.gain,
    required this.onChange,
    this.title = 'Gain',
    this.autofocus = false,
    this.actions = const [],
    super.key,
  });

  /// The initial gain value.
  final double gain;

  /// The function to be called with the new gain.
  final ValueChanged<double> onChange;

  /// The title of the list tile.
  final String title;

  /// Whether or not the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Actions for the resulting [NumberListTile].
  final List<Widget> actions;

  /// Build a widget.
  @override
  Widget build(final BuildContext context) => NumberListTile(
        autofocus: autofocus,
        actions: actions,
        title: title,
        subtitle: gain.toString(),
        onChanged: onChange,
        value: gain,
        min: 0.0,
        max: 5.0,
        modifier: 0.2,
      );
}
