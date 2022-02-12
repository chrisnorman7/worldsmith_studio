import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:ziggurat/sound.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/get_text.dart';

/// A widget for customising the main settings for the given [projectContext].
class ProjectSettingsWidget extends StatefulWidget {
  /// Create an instance.
  const ProjectSettingsWidget({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _ProjectSettingsWidgetState createState() => _ProjectSettingsWidgetState();
}

/// State for [ProjectSettingsWidget].
class _ProjectSettingsWidgetState extends State<ProjectSettingsWidget> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    return ListView(
      children: [
        ListTile(
          autofocus: true,
          title: const Text('Rename World'),
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
        ListTile(
          title: const Text('Default Panning Strategy'),
          subtitle: Text(
            path.extension(world.soundOptions.defaultPannerStrategy.toString()),
          ),
          onTap: () {
            final soundOptions = world.soundOptions;
            var index = soundOptions.defaultPannerStrategy.index + 1;
            if (index >= DefaultPannerStrategy.values.length) {
              index = 0;
            }
            world.soundOptions.defaultPannerStrategy =
                DefaultPannerStrategy.values[index];
            widget.projectContext.save();
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
