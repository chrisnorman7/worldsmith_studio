import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../select_item.dart';

/// A list tile for showing an [audioBus].
class AudioBusListTile extends StatelessWidget {
  /// Create an instance.
  const AudioBusListTile({
    required this.projectContext,
    required this.audioBus,
    required this.onChanged,
    this.title = 'Audio Bus',
    this.autofocus = false,
    super.key,
  });

  /// The project context to work with.
  final ProjectContext projectContext;

  /// The audio bus to use.
  final AudioBus? audioBus;

  /// The function to call when [audioBus] changes.
  final ValueChanged<AudioBus?> onChanged;

  /// The title of the resulting [ListTile].
  final String title;

  /// Whether the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final audioBusses = [null, ...projectContext.world.audioBusses]..sort(
        (final a, final b) {
          if (a == null) {
            return -1;
          } else if (b == null) {
            return 1;
          }
          return a.name.compareTo(b.name);
        },
      );
    return ListTile(
      autofocus: autofocus,
      title: Text(title),
      subtitle: Text(audioBus?.name ?? 'Interface Sounds'),
      onTap: () => pushWidget(
        context: context,
        builder: (final context) => SelectItem<AudioBus?>(
          onDone: onChanged,
          values: audioBusses,
          getItemWidget: (final value) => Text(
            value == null ? 'Interface Sounds' : value.name,
          ),
          title: 'Select Audio Bus',
          value: audioBus,
        ),
      ),
    );
  }
}
