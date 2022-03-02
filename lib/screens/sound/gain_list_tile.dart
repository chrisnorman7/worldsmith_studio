import 'dart:math';

import 'package:flutter/material.dart';

import '../../intents.dart';
import '../../util.dart';
import '../../widgets/get_number.dart';

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
  _GainListTileState createState() => _GainListTileState();
}

/// State for [GainListTile].
class _GainListTileState extends State<GainListTile> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) => Shortcuts(
        child: Actions(
          actions: {
            IncreaseIntent: CallbackAction<IncreaseIntent>(
              onInvoke: (intent) => widget.onChange(
                roundDouble(widget.gain + 0.1),
              ),
            ),
            DecreaseIntent: CallbackAction<DecreaseIntent>(
              onInvoke: (intent) => widget.onChange(
                max(
                  0.0,
                  roundDouble(widget.gain - 0.1),
                ),
              ),
            )
          },
          child: ListTile(
            autofocus: widget.autofocus,
            title: Text(widget.title),
            subtitle: Text(widget.gain.toString()),
            onTap: () => pushWidget(
              context: context,
              builder: (context) => GetNumber(
                value: widget.gain,
                onDone: (value) {
                  Navigator.pop(context);
                  widget.onChange(value);
                },
                min: 0.0,
                title: widget.title,
              ),
            ),
          ),
        ),
        shortcuts: const {
          IncreaseIntent.hotkey: IncreaseIntent(),
          DecreaseIntent.hotkey: DecreaseIntent()
        },
      );
}
