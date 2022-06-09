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
import '../../widgets/custom_sound/custom_sound_list_tile.dart';
import '../../widgets/get_text.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/quest/quest_list_tile.dart';
import '../../widgets/scene/show_scene_list_tile.dart';
import '../../widgets/select_item.dart';
import '../../widgets/text_list_tile.dart';
import '../custom_menu/edit_custom_menu.dart';
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
    super.key,
  });

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
  Widget build(final BuildContext context) {
    final renameAction = CallbackAction<RenameIntent>(
      onInvoke: (final intent) => pushWidget(
        context: context,
        builder: (final context) => GetText(
          onDone: (final value) {
            Navigator.pop(context);
            widget.command.name = value;
            save();
          },
          labelText: 'Name',
          text: widget.command.name,
          title: 'Rename Command',
          validator: (final value) => validateNonEmptyValue(value: value),
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
              builder: (final context) => Scaffold(
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
                      child: const Icon(
                        Icons.drive_file_rename_outline,
                        semanticLabel: 'Rename Command',
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
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Get the list view for the [Scaffold] to use.
  ListView getCommandListView({required final BuildContext context}) {
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
    final customMenuId = widget.command.customMenuId;
    final customMenu =
        customMenuId == null ? null : world.getMenu(customMenuId);
    return ListView(
      children: [
        ListTile(
          autofocus: true,
          title: const Text('Command Name'),
          subtitle: Text(widget.command.name),
          onTap: Actions.handler<RenameIntent>(context, _renameIntent),
        ),
        TextListTile(
          value: widget.command.text ?? '',
          onChanged: (final value) {
            widget.command.text = value;
            save();
          },
          header: 'Message',
        ),
        CustomSoundListTile(
          projectContext: widget.projectContext,
          value: widget.command.sound,
          onChanged: (final value) {
            widget.command.sound = value;
            save();
          },
        ),
        CallbackShortcuts(
          bindings: {
            EditIntent.hotkey: () async {
              if (zone != null) {
                await pushWidget(
                  context: context,
                  builder: (final context) => EditZone(
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
                  builder: (final context) => SelectZone(
                    projectContext: widget.projectContext,
                    onDone: (final zone) async {
                      Navigator.pop(context);
                      final teleport = ZoneTeleport(
                        zoneId: zone.id,
                        minCoordinates: Coordinates(0, 0),
                      );
                      widget.command.zoneTeleport = teleport;
                      await pushWidget(
                        context: context,
                        builder: (final context) => EditZoneTeleport(
                          projectContext: widget.projectContext,
                          zoneTeleport: teleport,
                          onChanged: (final value) {
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
                  builder: (final context) => EditZoneTeleport(
                    projectContext: widget.projectContext,
                    zoneTeleport: zoneTeleport,
                    onChanged: (final value) {
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
            builder: (final context) => SelectItem<WalkingMode?>(
              getItemWidget: (final value) => Text(
                value == null ? 'Clear' : value.name,
              ),
              onDone: (final value) {
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
          onDone: (final value) {
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
          onChanged: (final value) {
            widget.command.customCommandName = value.isEmpty ? null : value;
            save();
          },
          header: 'Custom Event Name',
          labelText: 'Event Name',
        ),
        StartConversationListTile(
          projectContext: widget.projectContext,
          startConversation: widget.command.startConversation,
          onChanged: (final value) {
            widget.command.startConversation = value;
            save();
          },
        ),
        ShowSceneListTile(
          projectContext: widget.projectContext,
          showScene: widget.command.showScene,
          onChanged: (final value) {
            widget.command.showScene = value;
            save();
          },
        ),
        ReturnToMainMenuListTile(
          projectContext: widget.projectContext,
          returnToMainMenu: returnToMainMenu,
          onChanged: (final value) {
            widget.command.returnToMainMenu = value;
            save();
          },
        ),
        PlayRumbleListTile(
          projectContext: widget.projectContext,
          playRumble: widget.command.playRumble,
          onChanged: (final value) {
            widget.command.playRumble = value;
            save();
          },
        ),
        TextListTile(
          value: widget.command.url ?? '',
          onChanged: (final value) {
            widget.command.url = value.isEmpty ? null : value;
            save();
          },
          header: 'Open URL',
        ),
        WithKeyboardShortcuts(
          keyboardShortcuts: const [
            KeyboardShortcut(
              description: 'Edit the selected menu.',
              keyName: 'E',
              control: true,
            )
          ],
          child: CallbackShortcuts(
            bindings: {
              EditIntent.hotkey: () async {
                if (customMenu != null) {
                  await pushWidget(
                    context: context,
                    builder: (final context) => EditCustomMenu(
                      projectContext: widget.projectContext,
                      menu: customMenu,
                    ),
                  );
                  setState(() {});
                }
              }
            },
            child: ListTile(
              title: const Text('Show Custom Menu'),
              subtitle: Text('${customMenu?.title}'),
              onTap: () => pushWidget(
                context: context,
                builder: (final context) => SelectItem<CustomMenu?>(
                  onDone: (final value) {
                    Navigator.pop(context);
                    widget.command.customMenuId = value?.id;
                    save();
                  },
                  values: [null, ...world.menus],
                  getItemWidget: (final value) {
                    final String label;
                    if (value == null) {
                      label = 'Clear';
                    } else {
                      label = value.title;
                    }
                    return Text(label);
                  },
                  title: 'Select Custom Menu',
                  value: customMenu,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  /// Delete the command.
  void deleteCommand(final BuildContext context) {
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
          (final element) => element.id == id,
        );
        Navigator.pop(context);
        Navigator.pop(context);
        widget.projectContext.save();
      },
    );
  }
}
