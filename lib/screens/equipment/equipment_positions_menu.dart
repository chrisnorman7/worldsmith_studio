import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import 'edit_equipment_position.dart';

const _createEquipmentPositionIntent = CreateEquipmentPositionIntent();
const _moveDownIntent = MoveDownIntent();
const _moveUpIntent = MoveUpIntent();

/// A menu for displaying and editing equipment positions.
class EquipmentPositionsMenu extends StatefulWidget {
  /// Create an instance.
  const EquipmentPositionsMenu({
    required this.projectContext,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  EquipmentPositionsMenuState createState() => EquipmentPositionsMenuState();
}

/// State for [EquipmentPositionsMenu].
class EquipmentPositionsMenuState extends State<EquipmentPositionsMenu> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final createEquipmentPositionAction =
        CallbackAction<CreateEquipmentPositionIntent>(
      onInvoke: (final intent) async {
        final position = EquipmentPosition(
          id: newId(),
          name: 'Untitled Equipment Position',
        );
        world.equipmentPositions.add(position);
        await pushWidget(
          context: context,
          builder: (final context) => EditEquipmentPosition(
            projectContext: widget.projectContext,
            equipmentPosition: position,
          ),
        );
        save();
        return null;
      },
    );
    return WithKeyboardShortcuts(
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Create a new equipment position.',
          keyName: 'N',
          control: true,
        ),
        KeyboardShortcut(
          description: 'Move equipment positions up or down.',
          keyName: 'Arrow Keys',
          alt: true,
        ),
        KeyboardShortcut(
          description: 'Delete the selected equipment position',
          keyName: 'Delete',
        )
      ],
      child: Shortcuts(
        shortcuts: {
          CreateEquipmentPositionIntent.hotkey: _createEquipmentPositionIntent
        },
        child: Actions(
          actions: {
            CreateEquipmentPositionIntent: createEquipmentPositionAction
          },
          child: Cancel(
            child: Builder(
              builder: (final context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Equipment Positions'),
                ),
                body: ListView.builder(
                  itemBuilder: (final context, final index) {
                    final position = world.equipmentPositions[index];
                    final shortcuts = <ShortcutActivator, Intent>{
                      DeleteIntent.hotkey: const DeleteIntent()
                    };
                    final actions = <Type, Action>{
                      DeleteIntent: CallbackAction<DeleteIntent>(
                        onInvoke: (final intent) => deleteEquipmentPosition(
                          context: context,
                          equipmentPosition: position,
                          world: world,
                          onDone: save,
                        ),
                      )
                    };
                    if (index <= (world.equipmentPositions.length - 1)) {
                      final moveDownAction = CallbackAction<MoveDownIntent>(
                        onInvoke: (final intent) {
                          world.equipmentPositions.removeAt(index);
                          final newIndex = index + 1;
                          if (newIndex ==
                              (world.equipmentPositions.length - 1)) {
                            world.equipmentPositions.add(position);
                          } else {
                            world.equipmentPositions.insert(newIndex, position);
                          }
                          save();
                          return null;
                        },
                      );
                      actions[MoveDownIntent] = moveDownAction;
                      shortcuts[MoveDownIntent.hotkey] = _moveDownIntent;
                    }
                    if (index > 0) {
                      final moveUpAction = CallbackAction<MoveUpIntent>(
                        onInvoke: (final intent) {
                          world.equipmentPositions.removeAt(index);
                          world.equipmentPositions.insert(index - 1, position);
                          save();
                          return null;
                        },
                      );
                      actions[MoveUpIntent] = moveUpAction;
                      shortcuts[MoveUpIntent.hotkey] = _moveUpIntent;
                    }
                    return Shortcuts(
                      shortcuts: shortcuts,
                      child: Actions(
                        actions: actions,
                        child: ListTile(
                          autofocus: index == 0,
                          title: Text(position.name),
                          onTap: () async {
                            await pushWidget(
                              context: context,
                              builder: (final context) => EditEquipmentPosition(
                                projectContext: widget.projectContext,
                                equipmentPosition: position,
                              ),
                            );
                            save();
                          },
                        ),
                      ),
                    );
                  },
                  itemCount: world.equipmentPositions.length,
                ),
                floatingActionButton: FloatingActionButton(
                  autofocus: world.equipmentPositions.isEmpty,
                  onPressed: Actions.handler<CreateEquipmentPositionIntent>(
                    context,
                    _createEquipmentPositionIntent,
                  ),
                  tooltip: 'Add Equipment Position',
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
