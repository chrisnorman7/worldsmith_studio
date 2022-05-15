// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/command/call_command_list_tile.dart';
import '../../widgets/sound/fade_time_list_tile.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/tabbed_scaffold.dart';
import '../../widgets/text_list_tile.dart';
import 'edit_custom_menu_item.dart';

/// A widget to edit the given custom [menu].
class EditCustomMenu extends StatefulWidget {
  /// Create an instance.
  const EditCustomMenu({
    required this.projectContext,
    required this.menu,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The custom menu to edit.
  final CustomMenu menu;

  /// Create state for this widget.
  @override
  EditCustomMenuState createState() => EditCustomMenuState();
}

/// State for [EditCustomMenu].
class EditCustomMenuState extends State<EditCustomMenu> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final actions = [
      ElevatedButton(
        onPressed: () {
          for (final category in world.commandCategories) {
            for (final command in category.commands) {
              if (command.customMenuId == widget.menu.id) {
                return showError(
                  context: context,
                  message: 'This menu is used by the ${command.name} command '
                      'from the ${category.name} category.',
                );
              }
            }
          }
          confirm(
            context: context,
            message: 'Are you sure you want to delete this menu?',
            title: 'Confirm Delete',
            yesCallback: () {
              Navigator.pop(context);
              Navigator.pop(context);
              world.menus.removeWhere(
                (final element) => element.id == widget.menu.id,
              );
              widget.projectContext.save();
            },
          );
        },
        child: const Icon(
          Icons.delete,
          semanticLabel: 'Delete Menu',
        ),
      )
    ];
    final items = widget.menu.items;
    return Cancel(
      child: TabbedScaffold(
        tabs: [
          TabbedScaffoldTab(
            title: 'Settings',
            icon: const Icon(Icons.settings),
            builder: (context) => ListView(
              children: [
                TextListTile(
                  value: widget.menu.title,
                  onChanged: (value) {
                    widget.menu.title = value;
                    save();
                  },
                  header: 'Title',
                  autofocus: true,
                ),
                SoundListTile(
                  projectContext: widget.projectContext,
                  value: widget.menu.music,
                  onDone: (value) {
                    widget.menu.music = value;
                    save();
                  },
                  assetStore: world.musicAssetStore,
                  defaultGain: world.soundOptions.defaultGain,
                  looping: true,
                  nullable: true,
                  title: 'Music',
                ),
                CheckboxListTile(
                  value: widget.menu.cancellable,
                  onChanged: (value) {
                    widget.menu.cancellable = value ?? false;
                    save();
                  },
                  title: const Text('Menu Can Be Cancelled'),
                  subtitle: Text(widget.menu.cancellable ? 'Yes' : 'No'),
                ),
                FadeTimeListTile(
                  value: widget.menu.fadeTime,
                  onChanged: (value) {
                    widget.menu.fadeTime = value;
                    save();
                  },
                ),
                CallCommandListTile(
                  projectContext: widget.projectContext,
                  callCommand: widget.menu.cancelCommand,
                  onChanged: (value) {
                    widget.menu.cancelCommand = value;
                    save();
                  },
                  title: 'Cancel Command',
                )
              ],
            ),
            actions: actions,
          ),
          TabbedScaffoldTab(
            title: 'Items',
            icon: const Icon(Icons.notes),
            builder: (context) => ListView.builder(
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  autofocus: index == 0,
                  title: Text(item.label ?? '<No Label>'),
                  onTap: () async {
                    await pushWidget(
                      context: context,
                      builder: (context) => EditCustomMenuItem(
                        projectContext: widget.projectContext,
                        customMenu: widget.menu,
                        customMenuItem: item,
                      ),
                    );
                    setState(() {});
                  },
                );
              },
              itemCount: items.length,
            ),
            actions: actions,
            floatingActionButton: FloatingActionButton(
              autofocus: items.isEmpty,
              onPressed: () async {
                final item = CustomMenuItem(
                  id: newId(),
                  label: 'Untitled Menu Item',
                );
                widget.menu.items.add(item);
                widget.projectContext.save();
                await pushWidget(
                  context: context,
                  builder: (context) => EditCustomMenuItem(
                    projectContext: widget.projectContext,
                    customMenu: widget.menu,
                    customMenuItem: item,
                  ),
                );
                setState(() {});
              },
              tooltip: 'New Menu Item',
              child: createIcon,
            ),
          )
        ],
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
