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
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  ProjectSettingsState createState() => ProjectSettingsState();
}

/// State for [ProjectSettings].
class ProjectSettingsState extends State<ProjectSettings> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final options = world.globalOptions;
    return ListView(
      children: [
        TextListTile(
          value: world.title,
          onChanged: (final value) {
            world.title = value;
            save();
          },
          header: 'Title',
          autofocus: true,
          validator: (final value) => validateNonEmptyValue(value: value),
        ),
        TextListTile(
          value: options.version,
          onChanged: (final value) {
            options.version = value;
            save();
          },
          header: 'Version',
          labelText: 'Version',
          validator: (final value) => validateNonEmptyValue(value: value),
        ),
        WorldCommandListTile(
          projectContext: widget.projectContext,
          currentId: world.mainMenuOptions.startGameCommandId,
          onChanged: (final value) {
            world.mainMenuOptions.startGameCommandId = value?.id;
            save();
          },
          title: 'Start Game Command',
          nullable: true,
        ),
        Shortcuts(
          shortcuts: const {
            IncreaseIntent.hotkey: IncreaseIntent(),
            DecreaseIntent.hotkey: DecreaseIntent()
          },
          child: Actions(
            actions: {
              IncreaseIntent: CallbackAction<IncreaseIntent>(
                onInvoke: (final intent) =>
                    framesPerSecond = world.globalOptions.framesPerSecond * 2,
              ),
              DecreaseIntent: CallbackAction<DecreaseIntent>(
                onInvoke: (final intent) => framesPerSecond = max(
                  15,
                  (world.globalOptions.framesPerSecond / 2).floor(),
                ),
              )
            },
            child: TextListTile(
              value: '${options.framesPerSecond}',
              onChanged: (final value) {
                framesPerSecond = int.parse(value);
              },
              header: 'Frames Per Second',
              validator: (final value) => validateInt(value: value),
            ),
          ),
        ),
        TextListTile(
          value: options.orgName,
          onChanged: (final value) {
            options.orgName = value;
            save();
          },
          header: 'Organisation Name',
          labelText: 'Name',
          validator: (final value) => validateNonEmptyValue(value: value),
        ),
        TextListTile(
          value: options.appName,
          onChanged: (final value) {
            options.appName = value;
            save();
          },
          header: 'Application Name',
          labelText: 'Name',
          validator: (final value) => validateNonEmptyValue(value: value),
        )
      ],
    );
  }

  /// Set frames per second.
  set framesPerSecond(final int value) {
    widget.projectContext.world.globalOptions.framesPerSecond = value;
    save();
  }

  /// Save the project context.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
