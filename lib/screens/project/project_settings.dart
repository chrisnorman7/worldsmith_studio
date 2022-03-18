import 'dart:math';

import 'package:flutter/material.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../validators.dart';
import '../../widgets/command/world_command_list_tile.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for customising the main settings for the given [projectContext].
class ProjectSettings extends StatefulWidget {
  /// Create an instance.
  const ProjectSettings({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _ProjectSettingsState createState() => _ProjectSettingsState();
}

/// State for [ProjectSettings].
class _ProjectSettingsState extends State<ProjectSettings> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final options = world.globalOptions;
    return ListView(
      children: [
        TextListTile(
          value: world.title,
          onChanged: (value) {
            world.title = value;
            save();
          },
          header: 'Title',
          autofocus: true,
          validator: (value) => validateNonEmptyValue(value: value),
        ),
        TextListTile(
          value: options.version,
          onChanged: (value) {
            options.version = value;
            save();
          },
          header: 'Version',
          labelText: 'Version',
          validator: (value) => validateNonEmptyValue(value: value),
        ),
        WorldCommandListTile(
          projectContext: widget.projectContext,
          currentId: world.mainMenuOptions.startGameCommandId,
          onChanged: (value) {
            world.mainMenuOptions.startGameCommandId = value?.id;
            save();
          },
          title: 'Start Game Command',
          nullable: true,
        ),
        Shortcuts(
          child: Actions(
            actions: {
              IncreaseIntent: CallbackAction<IncreaseIntent>(
                onInvoke: (intent) =>
                    framesPerSecond = world.globalOptions.framesPerSecond * 2,
              ),
              DecreaseIntent: CallbackAction<DecreaseIntent>(
                onInvoke: (intent) => framesPerSecond = max(
                  15,
                  (world.globalOptions.framesPerSecond / 2).floor(),
                ),
              )
            },
            child: TextListTile(
              value: '${options.framesPerSecond}',
              onChanged: (value) {
                framesPerSecond = int.parse(value);
              },
              header: 'Frames Per Second',
              validator: (value) => validateInt(value: value),
            ),
          ),
          shortcuts: const {
            IncreaseIntent.hotkey: IncreaseIntent(),
            DecreaseIntent.hotkey: DecreaseIntent()
          },
        ),
        TextListTile(
          value: options.orgName,
          onChanged: (value) {
            options.orgName = value;
            save();
          },
          header: 'Organisation Name',
          labelText: 'Name',
          validator: (value) => validateNonEmptyValue(value: value),
        ),
        TextListTile(
          value: options.appName,
          onChanged: (value) {
            options.appName = value;
            save();
          },
          header: 'Application Name',
          labelText: 'Name',
          validator: (value) => validateNonEmptyValue(value: value),
        )
      ],
    );
  }

  /// Set frames per second.
  set framesPerSecond(int value) {
    widget.projectContext.world.globalOptions.framesPerSecond = value;
    save();
  }

  /// Save the project context.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
