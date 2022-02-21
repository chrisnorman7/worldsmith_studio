import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../world_command_location.dart';
import 'edit_call_command.dart';

/// A widget for viewing and editing its [callCommand].
class CallCommandListTile extends StatefulWidget {
  /// Create an instance.
  const CallCommandListTile({
    required this.projectContext,
    required this.callCommand,
    required this.onChanged,
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The call command to use.
  final CallCommand callCommand;

  /// The function to call when editing is complete.
  final ValueChanged<CallCommand?> onChanged;

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
    final location = WorldCommandLocation.find(
      categories: widget.projectContext.world.commandCategories,
      commandId: callCommand.commandId,
    );
    final callAfter = callCommand.callAfter;
    return ListTile(
      title: const Text('Call Command'),
      subtitle: Text('${location.description} (Call after: '
          '$callAfter millisecond${callAfter == 1 ? "" : "s"})'),
      onTap: () async {
        await pushWidget(
          context: context,
          builder: (context) => EditCallCommand(
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
