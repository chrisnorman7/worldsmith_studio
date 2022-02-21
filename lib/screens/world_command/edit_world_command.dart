import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/get_text.dart';
import '../../widgets/keyboard_shortcuts_list.dart';

const _renameIntent = RenameIntent();

/// A widget for editing the given [command] in the given [category].
class EditWorldCommand extends StatefulWidget {
  /// Create an instance.
  const EditWorldCommand({
    required this.projectContext,
    required this.category,
    required this.command,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The command category which owns [command].
  final CommandCategory category;

  /// The command to work on.
  final WorldCommand command;

  /// Create state for this widget.
  @override
  _EditWorldCommandState createState() => _EditWorldCommandState();
}

/// State for [EditWorldCommand].
class _EditWorldCommandState extends State<EditWorldCommand> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final renameAction = CallbackAction<RenameIntent>(
      onInvoke: (intent) => pushWidget(
        context: context,
        builder: (context) => GetText(
          onDone: (value) {
            Navigator.pop(context);
            widget.command.name = value;
            save();
          },
          labelText: 'Name',
          text: widget.command.name,
          title: 'Rename Command',
          validator: (value) => validateNonEmptyValue(value: value),
        ),
      ),
    );
    return WithKeyboardShortcuts(
      child: Shortcuts(
        child: Actions(
          actions: {RenameIntent: renameAction},
          child: Cancel(
            child: Builder(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  actions: [
                    ElevatedButton(
                      child: const Icon(Icons.drive_file_rename_outline,
                          semanticLabel: 'Rename Command'),
                      onPressed: Actions.handler<RenameIntent>(
                        context,
                        _renameIntent,
                      ),
                    )
                  ],
                  title: const Text('Edit Command'),
                ),
                body: getCommandListView(context: context),
              ),
            ),
          ),
        ),
        shortcuts: const {RenameIntent.hotkey: _renameIntent},
      ),
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Rename the command.',
          keyName: 'R',
          control: true,
        )
      ],
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Get the list view for the [Scaffold] to use.
  ListView getCommandListView({required BuildContext context}) => ListView(
        children: [
          ListTile(
            autofocus: true,
            title: const Text('Command Name'),
            subtitle: Text(widget.command.name),
            onTap: Actions.handler<RenameIntent>(context, _renameIntent),
          )
        ],
      );
}
