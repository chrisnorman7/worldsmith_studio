import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/searchable_list_view.dart';
import 'edit_call_command.dart';
import 'select_command_category.dart';
import 'select_world_command.dart';

/// A widget which allows adding and editing [callCommands].
class EditCallCommands extends StatefulWidget {
  /// Create an instance.
  const EditCallCommands({
    required this.projectContext,
    required this.callCommands,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The commands to edit.
  final List<CallCommand> callCommands;

  /// Create state for this widget.
  @override
  _EditCallCommandsState createState() => _EditCallCommandsState();
}

/// State for [EditCallCommands].
class _EditCallCommandsState extends State<EditCallCommands> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final callCommands = widget.callCommands;
    final Widget child;
    if (callCommands.isEmpty) {
      child = const CenterText(text: 'There are no commands to show.');
    } else {
      final children = <SearchableListTile>[];
      for (var i = 0; i < callCommands.length; i++) {
        final callCommand = callCommands[i];
        final command = world.getCommand(callCommand.commandId);
        children.add(
          SearchableListTile(
            searchString: command.name,
            child: ListTile(
              autofocus: i == 0,
              title: Text(command.name),
              subtitle: Text('${callCommand.conditions.length}'),
              onTap: () => pushWidget(
                context: context,
                builder: (context) => EditCallCommand(
                  projectContext: widget.projectContext,
                  callCommand: callCommand,
                  onChanged: (value) {
                    if (value == null) {
                      callCommands.removeAt(i);
                    }
                    save();
                  },
                ),
              ),
            ),
          ),
        );
      }
      child = SearchableListView(children: children);
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Call Commands'),
        ),
        body: child,
        floatingActionButton: FloatingActionButton(
          autofocus: callCommands.isEmpty,
          onPressed: () => pushWidget(
            context: context,
            builder: (context) => SelectCommandCategory(
              projectContext: widget.projectContext,
              onDone: (category) {
                if (category == null) {
                  return Navigator.pop(context);
                }
                pushWidget(
                  context: context,
                  builder: (context) => SelectWorldCommand(
                    projectContext: widget.projectContext,
                    category: category,
                    onDone: (command) async {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      if (command != null) {
                        final callCommand = CallCommand(commandId: command.id);
                        callCommands.add(callCommand);
                        widget.projectContext.save();
                        await pushWidget(
                          context: context,
                          builder: (context) => EditCallCommand(
                            projectContext: widget.projectContext,
                            callCommand: callCommand,
                            onChanged: (value) {
                              if (value == null) {
                                callCommands.removeLast();
                              }
                              widget.projectContext.save();
                            },
                          ),
                        );
                        setState(() {});
                      }
                    },
                  ),
                );
              },
            ),
          ),
          child: createIcon,
          tooltip: 'Add Command',
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