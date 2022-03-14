import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/command/world_command_list_tile.dart';
import '../../widgets/number_list_tile.dart';
import '../../world_command_location.dart';

/// A widget for editing its [callCommand].
class EditCallCommand extends StatefulWidget {
  /// Create an instance.
  const EditCallCommand({
    required this.projectContext,
    required this.callCommand,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The call command to edit.
  final CallCommand callCommand;

  /// The function to call when [callCommand] changes.
  final ValueChanged<CallCommand?> onChanged;

  /// Create state for this widget.
  @override
  _EditCallCommandState createState() => _EditCallCommandState();
}

/// State for [EditCallCommand].
class _EditCallCommandState extends State<EditCallCommand> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final location = WorldCommandLocation.find(
      categories: widget.projectContext.world.commandCategories,
      commandId: widget.callCommand.commandId,
    );
    final callAfter = widget.callCommand.callAfter;
    var callAfterString = '$callAfter';
    if (callAfter != null) {
      callAfterString += ' millisecond';
      if (callAfter != 1) {
        callAfterString += 's';
      }
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onChanged(null);
              },
              child: const Icon(
                Icons.clear_outlined,
                semanticLabel: 'Clear Command',
              ),
            )
          ],
          title: const Text('Call Command'),
        ),
        body: ListView(
          children: [
            WorldCommandListTile(
              projectContext: widget.projectContext,
              currentId: location.command.id,
              onChanged: (value) {
                widget.callCommand.commandId = value!.id;
                save();
              },
              title: 'Command',
              autofocus: true,
            ),
            NumberListTile(
              value: widget.callCommand.callAfter?.toDouble() ?? 0.0,
              onChanged: (value) {
                if (value <= 0) {
                  widget.callCommand.callAfter = null;
                } else {
                  widget.callCommand.callAfter = value.floor();
                }
                save();
              },
              min: 0,
              title: 'Call After',
              subtitle: callAfterString,
            )
          ],
        ),
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
