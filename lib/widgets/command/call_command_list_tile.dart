import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../screens/world_command/edit_call_command.dart';
import '../../screens/world_command/select_command_category.dart';
import '../../screens/world_command/select_world_command.dart';
import '../../util.dart';
import '../../world_command_location.dart';
import '../push_widget_list_tile.dart';

/// A widget for viewing and editing its [callCommand].
class CallCommandListTile extends StatefulWidget {
  /// Create an instance.
  const CallCommandListTile({
    required this.projectContext,
    required this.callCommand,
    required this.onChanged,
    this.title = 'Call Command',
    this.autofocus = false,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The call command to use.
  final CallCommand? callCommand;

  /// The function to call when editing is complete.
  final ValueChanged<CallCommand?> onChanged;

  /// The title of the resulting [ListTile].
  final String title;

  /// Whether or not the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Create state for this widget.
  @override
  CallCommandListTileState createState() => CallCommandListTileState();
}

/// State for [CallCommandListTile].
class CallCommandListTileState extends State<CallCommandListTile> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final callCommand = widget.callCommand;
    final location = callCommand == null
        ? null
        : WorldCommandLocation.find(
            categories: widget.projectContext.world.commandCategories,
            commandId: callCommand.commandId,
          );
    final callAfter = callCommand?.callAfter;
    final String subtitle;
    if (location == null) {
      subtitle = 'Unset';
    } else {
      subtitle = '${location.description} (Call after: $callAfter millisecond'
          '${callAfter == 1 ? "" : "s"})';
    }
    return PushWidgetListTile(
      title: widget.title,
      subtitle: subtitle,
      builder: (final context) => callCommand == null
          ? SelectCommandCategory(
              projectContext: widget.projectContext,
              onDone: (final category) => pushWidget(
                context: context,
                builder: (final context) => SelectWorldCommand(
                  projectContext: widget.projectContext,
                  category: category!,
                  onDone: (final command) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    widget.onChanged(CallCommand(commandId: command!.id));
                  },
                ),
              ),
            )
          : EditCallCommand(
              projectContext: widget.projectContext,
              callCommand: callCommand,
              onChanged: widget.onChanged,
            ),
      autofocus: widget.autofocus,
    );
  }
}
