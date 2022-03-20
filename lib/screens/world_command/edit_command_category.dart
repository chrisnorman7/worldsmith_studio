import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/get_text.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/searchable_list_view.dart';
import 'edit_world_command.dart';

const _renameIntent = RenameIntent();

/// A widget for viewing and editing its [category].
class EditCommandCategory extends StatefulWidget {
  /// Create an instance.
  const EditCommandCategory({
    required this.projectContext,
    required this.category,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The category to edit.
  final CommandCategory category;

  /// Create state for this widget.
  @override
  EditCommandCategoryState createState() => EditCommandCategoryState();
}

/// State for [EditCommandCategory].
class EditCommandCategoryState extends State<EditCommandCategory> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final renameAction = CallbackAction<RenameIntent>(
      onInvoke: (intent) => pushWidget(
        context: context,
        builder: (context) => GetText(
          onDone: (value) {
            Navigator.pop(context);
            widget.category.name = value;
            save();
          },
          labelText: 'Name',
          text: widget.category.name,
          title: 'Rename Category',
        ),
      ),
    );
    final commands = widget.category.commands;
    final Widget child;
    if (commands.isEmpty) {
      child = const CenterText(text: 'There are no commands in this category.');
    } else {
      final children = <SearchableListTile>[];
      for (var i = 0; i < commands.length; i++) {
        final command = commands[i];
        children.add(
          SearchableListTile(
            searchString: command.name,
            child: CallbackShortcuts(
              bindings: {CopyIntent.hotkey: () => setClipboardText(command.id)},
              child: ListTile(
                autofocus: i == 0,
                title: Text(command.name),
                onTap: () async {
                  await pushWidget(
                    context: context,
                    builder: (context) => EditWorldCommand(
                      projectContext: widget.projectContext,
                      category: widget.category,
                      command: command,
                    ),
                  );
                  save();
                },
              ),
            ),
          ),
        );
      }
      child = SearchableListView(
        children: children,
      );
    }
    return Shortcuts(
      shortcuts: {RenameIntent.hotkey: _renameIntent},
      child: Actions(
        actions: {RenameIntent: renameAction},
        child: Cancel(
          child: WithKeyboardShortcuts(
            keyboardShortcuts: const [
              KeyboardShortcut(
                description: 'Rename this category.',
                keyName: 'R',
                control: true,
              )
            ],
            child: Builder(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  actions: [
                    ElevatedButton(
                      onPressed: Actions.handler<RenameIntent>(
                        context,
                        _renameIntent,
                      ),
                      child: const Icon(
                        Icons.drive_file_rename_outline_rounded,
                        semanticLabel: 'Rename Category',
                      ),
                    )
                  ],
                  title: Text(widget.category.name),
                ),
                body: child,
                floatingActionButton: FloatingActionButton(
                  autofocus: commands.isEmpty,
                  onPressed: () async {
                    final command = WorldCommand(
                      id: newId(),
                      name: 'Untitled Command',
                    );
                    widget.category.commands.add(command);
                    widget.projectContext.save();
                    await pushWidget(
                      context: context,
                      builder: (context) => EditWorldCommand(
                        projectContext: widget.projectContext,
                        category: widget.category,
                        command: command,
                      ),
                    );
                    setState(() {});
                  },
                  tooltip: 'Add Command',
                  child: createIcon,
                ),
              ),
            ),
          ),
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
