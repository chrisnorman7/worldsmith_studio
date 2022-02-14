import 'dart:math';

import 'package:flutter/material.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/get_text.dart';

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
    return ListView(
      children: [
        ListTile(
          autofocus: true,
          title: const Text('World Name'),
          subtitle: Text(world.title),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (context) => GetText(
                onDone: (value) {
                  Navigator.pop(context);
                  world.title = value;
                  widget.projectContext.save();
                },
                labelText: 'World Name',
                text: world.title,
                title: 'Rename World',
                validator: (value) => validateNonEmptyValue(value: value),
              ),
            );
            setState(() {});
          },
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
            child: ListTile(
              title: const Text('Frames Per Second'),
              subtitle: Text(world.globalOptions.framesPerSecond.toString()),
              onTap: () => pushWidget(
                context: context,
                builder: (context) => GetText(
                  onDone: (value) {
                    Navigator.pop(context);
                    framesPerSecond = int.parse(value);
                  },
                  labelText: 'FPS',
                  text: world.globalOptions.framesPerSecond.toString(),
                  title: 'Frames Per Second',
                  validator: (value) => validateInt(value: value),
                ),
              ),
            ),
          ),
          shortcuts: const {
            IncreaseIntent.hotkey: IncreaseIntent(),
            DecreaseIntent.hotkey: DecreaseIntent()
          },
        )
      ],
    );
  }

  /// Set frames per second.
  set framesPerSecond(int value) {
    widget.projectContext.world.globalOptions.framesPerSecond = value;
    widget.projectContext.save();
    setState(() {});
  }
}
