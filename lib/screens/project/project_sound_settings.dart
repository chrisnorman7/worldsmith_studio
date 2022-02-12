import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:ziggurat/sound.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/get_number.dart';

/// A widget for configuring sound-related settings.
class ProjectSoundSettings extends StatefulWidget {
  /// Create an instance.
  const ProjectSoundSettings({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _ProjectSoundSettingsState createState() => _ProjectSoundSettingsState();
}

/// State for [ProjectSoundSettings].
class _ProjectSoundSettingsState extends State<ProjectSoundSettings> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    return ListView(
      children: [
        ListTile(
          autofocus: true,
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
                    defaultGain = world.soundOptions.defaultGain += 0.1,
              ),
              DecreaseIntent: CallbackAction<DecreaseIntent>(
                onInvoke: (intent) => defaultGain = max(
                  0.1,
                  world.soundOptions.defaultGain - 0.1,
                ),
              )
            },
            child: ListTile(
              title: const Text('Default Gain'),
              subtitle: Text(world.soundOptions.defaultGain.toString()),
              onTap: () => pushWidget(
                context: context,
                builder: (context) => GetNumber(
                  value: world.soundOptions.defaultGain,
                  onDone: (value) {
                    Navigator.pop(context);
                    defaultGain = value;
                  },
                  min: 0.0,
                  title: 'Default Gain',
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

  /// Set default gain.
  set defaultGain(double value) {
    widget.projectContext.world.soundOptions.defaultGain = value;
    widget.projectContext.save();
    setState(() {});
  }
}
