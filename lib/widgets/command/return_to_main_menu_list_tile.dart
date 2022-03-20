import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../screens/world_command/edit_return_to_main_menu.dart';
import '../../util.dart';

/// A list tile that shows a [returnToMainMenu] command.
class ReturnToMainMenuListTile extends StatefulWidget {
  /// Create an instance.
  const ReturnToMainMenuListTile({
    required this.projectContext,
    required this.returnToMainMenu,
    required this.onChanged,
    this.title = 'Return To Main Menu',
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The command to use.
  final ReturnToMainMenu? returnToMainMenu;

  /// The function to call whenever [returnToMainMenu] changes.
  final ValueChanged<ReturnToMainMenu?> onChanged;

  /// The title of the resulting [ListTile].
  final String title;

  /// Whether the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Create state for this widget.
  @override
  ReturnToMainMenuListTileState createState() =>
      ReturnToMainMenuListTileState();
}

/// State for [ReturnToMainMenuListTile].
class ReturnToMainMenuListTileState extends State<ReturnToMainMenuListTile> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final value = widget.returnToMainMenu;
    return ListTile(
      autofocus: widget.autofocus,
      title: Text(widget.title),
      subtitle: Text(
        value == null
            ? 'Not set'
            : 'Fade: ${value.fadeTime} ms, save player preferences: '
                '${value.savePlayerPreferences ? "yes" : "no"}',
      ),
      onTap: () async {
        final ReturnToMainMenu returnToMainMenu;
        if (value == null) {
          returnToMainMenu = ReturnToMainMenu();
          widget.onChanged(returnToMainMenu);
        } else {
          returnToMainMenu = value;
        }
        await pushWidget(
          context: context,
          builder: (context) => EditReturnToMainMenu(
            projectContext: widget.projectContext,
            returnToMainMenu: returnToMainMenu,
            onChanged: widget.onChanged,
          ),
        );
        setState(() {});
      },
    );
  }
}
