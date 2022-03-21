import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/command/call_commands_list_tile.dart';
import '../../widgets/command/play_rumble_list_tile.dart';
import '../../widgets/command/return_to_main_menu_list_tile.dart';
import '../../widgets/conversation/start_conversation_list_tile.dart';
import '../../widgets/custom_message/custom_message_list_tile.dart';
import '../../widgets/get_text.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/quest/quest_list_tile.dart';
import '../../widgets/scene/show_scene_list_tile.dart';
import '../../widgets/select_item.dart';
import '../../widgets/text_list_tile.dart';
import '../zone/edit_zone.dart';
import '../zone/select_zone.dart';
import 'edit_zone_teleport.dart';

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
  EditWorldCommandState createState() => EditWorldCommandState();
}

/// State for [EditWorldCommand].
class EditWorldCommandState extends State<EditWorldCommand> {
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
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Rename the command.',
          keyName: 'R',
          control: true,
        )
      ],
      child: Shortcuts(
        shortcuts: {RenameIntent.hotkey: _renameIntent},
        child: Actions(
          actions: {RenameIntent: renameAction},
          child: Cancel(
            child: Builder(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  actions: [
                    ElevatedButton(
                      onPressed: () => deleteCommand(context),
                      child: const Icon(
                        Icons.delete_outline,
                        semanticLabel: 'Delete Command',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: Actions.handler<RenameIntent>(
                        context,
                        _renameIntent,
                      ),
                      child: const Icon(Icons.drive_file_rename_outline,
                          semanticLabel: 'Rename Command'),
                    )
                  ],
                  title: const Text('Edit Command'),
                ),
                body: getCommandListView(context: context),
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

  /// Get the list view for the [Scaffold] to use.
  ListView getCommandListView({required BuildContext context}) {
    final world = widget.projectContext.world;
    final setQuestStage = widget.command.setQuestStage;
    final questId = setQuestStage?.questId;
    final quest = questId == null ? null : world.getQuest(questId);
    final stageId = setQuestStage?.stageId;
    final stage =
        quest == null || stageId == null ? null : quest.getStage(stageId);
    final walkingMode = widget.command.walkingMode;
    final customCommandName = widget.command.customCommandName;
    final zoneTeleport = widget.command.zoneTeleport;
    final zone =
        zoneTeleport == null ? null : world.getZone(zoneTeleport.zoneId);
    final returnToMainMenu = widget.command.returnToMainMenu;
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
        CallbackShortcuts(
          bindings: {
            EditIntent.hotkey: () async {
              if (zone != null) {
                await pushWidget(
                  context: context,
                  builder: (context) => EditZone(
                    projectContext: widget.projectContext,
                    zone: zone,
                  ),
                );
                setState(() {});
              }
            }
          },
          child: ListTile(
            title: const Text('Set Current Zone'),
            subtitle: Text(zone == null ? 'Not set' : zone.name),
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
                      save();
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
                setState(() {});
              }
            },
          ),
        ),
        ListTile(
          title: const Text('Change Walking Mode'),
          subtitle: Text(walkingMode == null ? 'Not set' : walkingMode.name),
          onTap: () => pushWidget(
            context: context,
            builder: (context) => SelectItem<WalkingMode?>(
              getItemWidget: (value) => Text(
                value == null ? 'Clear' : value.name,
              ),
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
        QuestListTile(
          projectContext: widget.projectContext,
          quest: quest,
          stage: stage,
          onDone: (value) {
            if (value == null) {
              widget.command.setQuestStage = null;
            } else {
              widget.command.setQuestStage = SetQuestStage(
                questId: value.quest.id,
                stageId: value.stage?.id,
              );
            }
            save();
          },
          title: 'Set Quest Stage',
        ),
        CallCommandsListTile(
          projectContext: widget.projectContext,
          callCommands: widget.command.callCommands,
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
        StartConversationListTile(
          projectContext: widget.projectContext,
          startConversation: widget.command.startConversation,
          onChanged: (value) {
            widget.command.startConversation = value;
            save();
          },
        ),
        ShowSceneListTile(
          projectContext: widget.projectContext,
          showScene: widget.command.showScene,
          onChanged: (value) {
            widget.command.showScene = value;
            save();
          },
        ),
        ReturnToMainMenuListTile(
          projectContext: widget.projectContext,
          returnToMainMenu: returnToMainMenu,
          onChanged: (value) {
            widget.command.returnToMainMenu = value;
            save();
          },
        ),
        PlayRumbleListTile(
          projectContext: widget.projectContext,
          playRumble: widget.command.playRumble,
          onChanged: (value) {
            widget.command.playRumble = value;
            save();
          },
        ),
        TextListTile(
          value: widget.command.url ?? '',
          onChanged: (value) {
            widget.command.url = value.isEmpty ? null : value;
            save();
          },
          header: 'Open URL',
        )
      ],
    );
  }

  /// Delete the command.
  void deleteCommand(BuildContext context) {
    final id = widget.command.id;
    final world = widget.projectContext.world;
    if (world.mainMenuOptions.startGameCommandId == id) {
      return showError(
        context: context,
        message: 'You cannot delete the start game command.',
      );
    }
    for (final commandCategory in world.commandCategories) {
      for (final command in commandCategory.commands) {
        for (final callCommand in command.callCommands) {
          if (callCommand.commandId == id ||
              command.showScene?.callCommand?.commandId == id) {
            return showError(
              context: context,
              message: 'You cannot delete a command which is called by the '
                  '${command.name} command from the ${commandCategory.name} '
                  'category.',
            );
          }
        }
      }
    }
    for (final zone in world.zones) {
      if (zone.edgeCommand?.commandId == id) {
        return showError(
          context: context,
          message:
              'You cannot delete the edge command of the ${zone.name} zone.',
        );
      }
      for (final box in zone.boxes) {
        if (box.enterCommand?.commandId == id ||
            box.leaveCommand?.commandId == id ||
            box.walkCommand?.commandId == id) {
          return showError(
            context: context,
            message: 'This command is used by the ${box.name} box of the '
                '${zone.name} zone.',
          );
        }
      }
      for (final object in zone.objects) {
        if (object.collideCommand?.commandId == id) {
          return showError(
            context: context,
            message: 'This command is being used by the ${object.name} '
                'object of the ${zone.name} zone.',
          );
        }
      }
    }
    for (final conversationCategory in world.conversationCategories) {
      for (final conversation in conversationCategory.conversations) {
        for (final response in conversation.responses) {
          if (response.command?.commandId == id) {
            return showError(
              context: context,
              message: 'The command is being used by the ${conversation.name} '
                  'conversation of the ${conversationCategory.name} category.',
            );
          }
        }
      }
    }
    confirm(
        context: context,
        message: 'Are you sure you want to delete the ${widget.command.name} '
            'command from the ${widget.category.name} category?',
        title: 'Delete Command',
        yesCallback: () {
          widget.category.commands.removeWhere(
            (element) => element.id == id,
          );
          Navigator.pop(context);
          Navigator.pop(context);
          widget.projectContext.save();
        });
  }
}
