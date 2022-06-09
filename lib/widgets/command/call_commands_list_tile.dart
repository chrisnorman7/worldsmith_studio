import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../screens/world_command/edit_call_commands.dart';
import '../push_widget_list_tile.dart';

/// A list tile that shows a list of [callCommands].
class CallCommandsListTile extends StatefulWidget {
  /// Create an instance.
  const CallCommandsListTile({
    required this.projectContext,
    required this.callCommands,
    this.title = 'Call Commands',
    this.autofocus = false,
    super.key,
  });

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
  Widget build(final BuildContext context) {
    final callCommands = widget.callCommands;
    return PushWidgetListTile(
      autofocus: widget.autofocus,
      title: widget.title,
      subtitle: '${callCommands.length}',
      builder: (final context) => EditCallCommands(
        projectContext: widget.projectContext,
        callCommands: callCommands,
      ),
    );
  }
}
