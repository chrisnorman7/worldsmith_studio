// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../custom_message.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/command/call_command_list_tile.dart';
import '../../widgets/custom_message/custom_message_list_tile.dart';

/// A widget to edit the given [customMenuItem].
class EditCustomMenuItem extends StatefulWidget {
  /// Create an instance.
  const EditCustomMenuItem({
    required this.projectContext,
    required this.customMenu,
    required this.customMenuItem,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The menu that the [customMenuItem] belongs to.
  final CustomMenu customMenu;

  /// The menu item to edit.
  final CustomMenuItem customMenuItem;

  /// Create state for this widget.
  @override
  EditCustomMenuItemState createState() => EditCustomMenuItemState();
}

/// State for [EditCustomMenuItem].
class EditCustomMenuItemState extends State<EditCustomMenuItem> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final message = CustomMessage(
      sound: widget.customMenuItem.sound,
      text: widget.customMenuItem.label,
    );
    final world = widget.projectContext.world;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () => confirm(
                context: context,
                message: 'Are you sure you want to delete this menu item?',
                yesCallback: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  widget.customMenu.items.removeWhere(
                    (element) => element.id == widget.customMenuItem.id,
                  );
                  widget.projectContext.save();
                },
              ),
              child: const Icon(
                Icons.delete,
                semanticLabel: 'Delete Menu Item',
              ),
            )
          ],
        ),
        body: ListView(
          children: [
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: message,
              assetStore: world.interfaceSoundsAssetStore,
              onChanged: (value) {
                widget.customMenuItem
                  ..sound = value.sound
                  ..label = value.text;
                save();
              },
              assetReference: world.menuMoveSound,
              title: 'Message',
              autofocus: true,
            ),
            CallCommandListTile(
              projectContext: widget.projectContext,
              callCommand: widget.customMenuItem.activateCommand,
              onChanged: (value) {
                widget.customMenuItem.activateCommand = value;
                save();
              },
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
