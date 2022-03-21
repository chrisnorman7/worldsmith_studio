import 'package:flutter/material.dart';

import '../number_list_tile.dart';

/// A widget for editing a gain value.
class GainListTile extends StatefulWidget {
  /// Create an instance.
  const GainListTile({
    required this.gain,
    required this.onChange,
    this.title = 'Gain',
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

  /// The initial gain value.
  final double gain;

  /// The function to be called with the new gain.
  final ValueChanged<double> onChange;

  /// The title of the list tile.
  final String title;

  /// Whether or not the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Create state for this widget.
  @override
  GainListTileState createState() => GainListTileState();
}

/// State for [GainListTile].
class GainListTileState extends State<GainListTile> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) => NumberListTile(
        autofocus: widget.autofocus,
        title: widget.title,
        subtitle: widget.gain.toString(),
        onChanged: widget.onChange,
        value: widget.gain,
        min: 0.0,
        max: 5.0,
        modifier: 0.2,
      );
}
