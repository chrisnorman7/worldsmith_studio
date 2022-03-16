import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/sound/fade_time_list_tile.dart';

/// A widget for editing a [returnToMainMenu].
class EditReturnToMainMenu extends StatefulWidget {
  /// Create an instance.
  const EditReturnToMainMenu({
    required this.projectContext,
    required this.returnToMainMenu,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The command to use.
  final ReturnToMainMenu returnToMainMenu;

  /// The function to be called when [returnToMainMenu] changes.
  final ValueChanged<ReturnToMainMenu?> onChanged;

  /// Create state for this widget.
  @override
  _EditReturnToMainMenuState createState() => _EditReturnToMainMenuState();
}

/// State for [EditReturnToMainMenu].
class _EditReturnToMainMenuState extends State<EditReturnToMainMenu> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final value = widget.returnToMainMenu;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onChanged(null);
              },
              child: const Icon(
                Icons.clear,
                semanticLabel: 'Clear Value',
              ),
            )
          ],
          title: const Text('Edit Return To Main Menu'),
        ),
        body: ListView(
          children: [
            CheckboxListTile(
              value: value.savePlayerPreferences,
              onChanged: (checked) {
                value.savePlayerPreferences = checked == true;
                save();
              },
              autofocus: true,
              title: Text(
                value.savePlayerPreferences
                    ? "Don't save player preferences"
                    : 'Save Player Preferences',
              ),
            ),
            FadeTimeListTile(
              value: value.fadeTime,
              onChanged: (fadeTime) {
                value.fadeTime = fadeTime;
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
