import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../screens/world_command/edit_play_rumble.dart';
import '../../util.dart';

/// A list view to display a [playRumble].
class PlayRumbleListTile extends StatefulWidget {
  /// Create an instance.
  const PlayRumbleListTile({
    required this.projectContext,
    required this.playRumble,
    required this.onChanged,
    this.title = 'Play Rumble',
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The play rumble to use.
  final PlayRumble? playRumble;

  /// The function call when [playRumble] changes.
  final ValueChanged<PlayRumble?> onChanged;

  /// The title for the resulting [ListTile].
  final String title;

  /// Whether or not the resulting [ListTile] should be autofocused.
  final bool autofocus;

  @override
  State<PlayRumbleListTile> createState() => PlayRumbleListTileState();
}

/// State for [PlayRumbleListTile].
class PlayRumbleListTileState extends State<PlayRumbleListTile> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final value = widget.playRumble;
    return ListTile(
      autofocus: widget.autofocus,
      title: Text(widget.title),
      subtitle: Text(
        value == null
            ? 'Not set'
            : '${value.leftFrequency} : ${value.rightFrequency} for '
                '${value.duration} milliseconds',
      ),
      onTap: () async {
        PlayRumble? rumble = value;
        if (rumble == null) {
          rumble = PlayRumble();
          widget.onChanged(rumble);
        }
        await pushWidget(
          context: context,
          builder: (context) => EditPlayRumble(
            projectContext: widget.projectContext,
            playRumble: rumble!,
            onDone: widget.onChanged,
          ),
        );
        setState(() {});
      },
    );
  }
}
