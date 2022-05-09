// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/command/call_command_list_tile.dart';
import '../../widgets/number_list_tile.dart';

/// A widget for editing the given [worldCommandTrigger].
class EditWorldCommandTrigger extends StatefulWidget {
  /// Create an instance.
  const EditWorldCommandTrigger({
    required this.projectContext,
    required this.worldCommandTrigger,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The command trigger to edit.
  final WorldCommandTrigger worldCommandTrigger;

  /// Create state for this widget.
  @override
  EditWorldCommandTriggerState createState() => EditWorldCommandTriggerState();
}

/// State for [EditWorldCommandTrigger].
class EditWorldCommandTriggerState extends State<EditWorldCommandTrigger> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final worldCommandTrigger = widget.worldCommandTrigger;
    final interval = worldCommandTrigger.interval;
    final zone = worldCommandTrigger.zone;
    final mainMenu = worldCommandTrigger.mainMenu;
    final pauseMenu = worldCommandTrigger.pauseMenu;
    final lookAroundMenu = worldCommandTrigger.lookAroundMenu;
    final zoneOverview = worldCommandTrigger.zoneOverview;
    final soundOptionsMenu = worldCommandTrigger.soundOptionsMenu;
    final scenes = worldCommandTrigger.scenes;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Command'),
        ),
        body: ListView(
          children: [
            CallCommandListTile(
              projectContext: widget.projectContext,
              callCommand: worldCommandTrigger.startCommand,
              onChanged: (value) {
                worldCommandTrigger.startCommand = value;
                save();
              },
              autofocus: true,
              title: 'Start Command',
            ),
            CallCommandListTile(
              projectContext: widget.projectContext,
              callCommand: worldCommandTrigger.stopCommand,
              onChanged: (value) {
                widget.worldCommandTrigger.stopCommand = value;
                save();
              },
              title: 'Stop Command',
            ),
            NumberListTile(
              value: interval?.toDouble() ?? 0.0,
              onChanged: (value) {
                if (value == 0) {
                  worldCommandTrigger.interval = null;
                } else {
                  worldCommandTrigger.interval = value.floor();
                }
                save();
              },
              min: 0,
              modifier: 10,
              subtitle: interval == null
                  ? 'Will not repeat'
                  : 'Every ${interval / 1000} seconds',
              title: 'Command Interval',
            ),
            CheckboxListTile(
              value: zone,
              onChanged: (value) {
                worldCommandTrigger.zone = value ?? false;
                save();
              },
              title: Text('${zone ? "Disallow" : "Allow"} Command In Zones'),
            ),
            CheckboxListTile(
              value: mainMenu,
              onChanged: (value) {
                worldCommandTrigger.mainMenu = value ?? false;
                save();
              },
              title: Text(
                '${mainMenu ? "Disallow" : "Allow"} Command In Main Menu',
              ),
            ),
            CheckboxListTile(
              value: pauseMenu,
              onChanged: (value) {
                worldCommandTrigger.pauseMenu = value ?? false;
                save();
              },
              title: Text(
                '${pauseMenu ? "Disallow" : "Allow"} Command In Pause Menu',
              ),
            ),
            CheckboxListTile(
              value: lookAroundMenu,
              onChanged: (value) {
                worldCommandTrigger.lookAroundMenu = value ?? false;
                save();
              },
              title: Text(
                '${lookAroundMenu ? "Disallow" : "Allow"} Command In '
                'Look Around Menu',
              ),
            ),
            CheckboxListTile(
              value: zoneOverview,
              onChanged: (value) {
                worldCommandTrigger.zoneOverview = value ?? false;
                save();
              },
              title: Text(
                '${zoneOverview ? "Disallow" : "Allow"} Command In '
                'Zone Overview',
              ),
            ),
            CheckboxListTile(
              value: soundOptionsMenu,
              onChanged: (value) {
                worldCommandTrigger.soundOptionsMenu = value ?? false;
                save();
              },
              title: Text(
                '${soundOptionsMenu ? "Disallow" : "Allow"} Command In '
                'Sound Options Menu',
              ),
            ),
            CheckboxListTile(
              value: scenes,
              onChanged: (value) {
                worldCommandTrigger.scenes = value ?? false;
                save();
              },
              title: Text('${scenes ? "Disallow" : "Allow"} Command In Scenes'),
            ),
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
