import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/custom_message/custom_message_list_tile.dart';
import '../../widgets/get_text.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/select_item.dart';
import '../../widgets/text_list_tile.dart';
import '../zone/select_zone.dart';
import 'call_command_list_tile.dart';
import 'edit_zone_teleport.dart';
import 'select_command_category.dart';
import 'select_world_command.dart';

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
  ListView getCommandListView({required BuildContext context}) {
    final walkingMode = widget.command.walkingMode;
    final customCommandName = widget.command.customCommandName;
    final callCommand = widget.command.callCommand;
    final zoneTeleport = widget.command.zoneTeleport;
    return ListView(
      children: [
        ListTile(
          autofocus: true,
          title: const Text('Command Name'),
          subtitle: Text(widget.command.name),
          onTap: Actions.handler<RenameIntent>(context, _renameIntent),
        ),
        CustomMessageListTile(
          projectContext: widget.projectContext,
          customMessage: widget.command.message,
          title: 'Message',
        ),
        callCommand == null
            ? ListTile(
                title: const Text('Call Another Command'),
                onTap: () => pushWidget(
                  context: context,
                  builder: (context) => SelectCommandCategory(
                    projectContext: widget.projectContext,
                    onDone: (category) {
                      if (category == null) {
                        Navigator.pop(context);
                      } else {
                        pushWidget(
                          context: context,
                          builder: (context) => SelectWorldCommand(
                            category: category,
                            onDone: (command) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              if (command != null) {
                                final callCommand = CallCommand(
                                  commandId: command.id,
                                );
                                widget.command.callCommand = callCommand;
                                save();
                              }
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
              )
            : CallCommandListTile(
                projectContext: widget.projectContext,
                callCommand: callCommand,
                onChanged: (value) {
                  widget.command.callCommand = value;
                  save();
                },
              ),
        ListTile(
          title: const Text('Teleport To Zone'),
          subtitle: Text(zoneTeleport == null
              ? 'Not set'
              : widget.projectContext.world
                  .getZone(
                    zoneTeleport.zoneId,
                  )
                  .name),
          onTap: () async {
            if (zoneTeleport == null) {
              await pushWidget(
                context: context,
                builder: (context) => SelectZone(
                  projectContext: widget.projectContext,
                  onDone: (zone) async {
                    Navigator.pop(context);
                    final teleport = ZoneTeleport(
                      zoneId: zone.id,
                      minCoordinates: Coordinates(0, 0),
                    );
                    widget.command.zoneTeleport = teleport;
                    save();
                    await pushWidget(
                      context: context,
                      builder: (context) => EditZoneTeleport(
                        projectContext: widget.projectContext,
                        zoneTeleport: teleport,
                        onChanged: (value) {
                          widget.command.zoneTeleport = value;
                          save();
                        },
                      ),
                    );
                  },
                ),
              );
            } else {
              await pushWidget(
                context: context,
                builder: (context) => EditZoneTeleport(
                  projectContext: widget.projectContext,
                  zoneTeleport: zoneTeleport,
                  onChanged: (value) {
                    widget.command.zoneTeleport = value;
                    save();
                  },
                ),
              );
            }
          },
        ),
        ListTile(
          title: const Text('Change Walking Mode'),
          subtitle: Text(walkingMode == null ? 'Not set' : walkingMode.name),
          onTap: () => pushWidget(
            context: context,
            builder: (context) => SelectItem<WalkingMode?>(
              getDescription: (value) => value == null ? 'Clear' : value.name,
              onDone: (value) {
                Navigator.pop(context);
                widget.command.walkingMode = value;
                save();
              },
              values: const [null, ...WalkingMode.values],
              title: 'Walking Mode',
              value: walkingMode,
            ),
          ),
        ),
        TextListTile(
          value: customCommandName ?? '',
          onChanged: (value) {
            widget.command.customCommandName = value.isEmpty ? null : value;
            save();
          },
          header: 'Custom Event Name',
          labelText: 'Event Name',
        ),
      ],
    );
  }
}