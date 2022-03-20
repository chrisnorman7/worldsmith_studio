import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../screens/world_command/edit_call_commands.dart';
import '../../util.dart';

/// A list tile that shows a list of [callCommands].
class CallCommandsListTile extends StatefulWidget {
  /// Create an instance.
  const CallCommandsListTile({
    required this.projectContext,
    required this.callCommands,
    this.title = 'Call Commands',
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The list of commands to work with.
  final List<CallCommand> callCommands;

  /// The title of the resulting [ListTile].
  final String title;

  /// Whether the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Create state for this widget.
  @override
  CallCommandsListTileState createState() => CallCommandsListTileState();
}

/// State for [CallCommandsListTile].
class CallCommandsListTileState extends State<CallCommandsListTile> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) => ListTile(
        autofocus: widget.autofocus,
        title: Text(widget.title),
        subtitle: Text('${widget.callCommands.length}'),
        onTap: () async {
          await pushWidget(
            context: context,
            builder: (context) {
              final callCommands = widget.callCommands;
              return EditCallCommands(
                projectContext: widget.projectContext,
                callCommands: callCommands,
              );
            },
          );
          setState(() {});
        },
      );
}
