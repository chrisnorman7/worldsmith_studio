import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../world_command_location.dart';
import 'edit_call_command.dart';
import 'select_command_category.dart';
import 'select_world_command.dart';

/// A widget for viewing and editing its [callCommand].
class CallCommandListTile extends StatefulWidget {
  /// Create an instance.
  const CallCommandListTile({
    required this.projectContext,
    required this.callCommand,
    required this.onChanged,
    this.title = 'Call Command',
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

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
  _CallCommandListTileState createState() => _CallCommandListTileState();
}

/// State for [CallCommandListTile].
class _CallCommandListTileState extends State<CallCommandListTile> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final callCommand = widget.callCommand;
    final location = callCommand == null
        ? null
        : WorldCommandLocation.find(
            categories: widget.projectContext.world.commandCategories,
            commandId: callCommand.commandId,
          );
    final callAfter = callCommand?.callAfter;
    return ListTile(
      title: Text(widget.title),
      subtitle: Text(
        location == null
            ? 'Unset'
            : '${location.description} (Call after: '
                '$callAfter millisecond${callAfter == 1 ? "" : "s"})',
      ),
      onTap: () async {
        await pushWidget(
          context: context,
          builder: (context) => callCommand == null
              ? SelectCommandCategory(
                  projectContext: widget.projectContext,
                  onDone: (category) => pushWidget(
                    context: context,
                    builder: (context) => SelectWorldCommand(
                      category: category!,
                      onDone: (command) {
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
        );
        setState(() {});
      },
      autofocus: widget.autofocus,
    );
  }
}
