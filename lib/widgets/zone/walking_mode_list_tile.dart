import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../util.dart';
import '../select_item.dart';

/// A widget for editing the given [walkingMode].
class WalkingModeListTile extends StatelessWidget {
  /// Create an instance.
  const WalkingModeListTile({
    required this.walkingMode,
    required this.onDone,
    this.title = 'Walking Mode',
    this.autofocus = false,
    super.key,
  });

  /// The walking mode to use.
  final WalkingMode walkingMode;

  /// The function to call when [walkingMode] is changed.
  final ValueChanged<WalkingMode> onDone;

  /// The title of the resulting [ListTile].
  final String title;

  /// Whether the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Build a widget.
  @override
  Widget build(final BuildContext context) => ListTile(
        autofocus: autofocus,
        title: Text(title),
        subtitle: Text(walkingMode.name),
        onTap: () => pushWidget(
          context: context,
          builder: (final context) => SelectItem<WalkingMode>(
            onDone: (final value) {
              Navigator.pop(context);
              onDone(value);
            },
            values: WalkingMode.values,
            getItemWidget: (final mode) => Text(mode.name),
            title: 'Select Walking Mode',
            value: walkingMode,
          ),
        ),
      );
}
