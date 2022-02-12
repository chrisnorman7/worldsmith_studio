import 'package:flutter/material.dart';
import 'package:ziggurat/sound.dart';

import '../../project_context.dart';
import '../sound/gain_list_tile.dart';
import '../sound/sound_list_tile.dart';

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
    final soundOptions = world.soundOptions;
    final menuMoveSound = soundOptions.menuMoveSound;
    final menuActivateSound = soundOptions.menuActivateSound;
    return ListView(
      children: [
        ListTile(
          autofocus: true,
          title: const Text('Default Panning Strategy'),
          subtitle: Text(
            soundOptions.defaultPannerStrategy.name,
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
        GainListTile(
          gain: soundOptions.defaultGain,
          onChange: (value) {
            soundOptions.defaultGain = value;
            widget.projectContext.save();
            setState(() {});
          },
          title: 'Default Gain',
        ),
        SoundListTile(
          context: context,
          projectContext: widget.projectContext,
          value: menuMoveSound,
          onDone: (value) {
            soundOptions.menuMoveSound = value;
            widget.projectContext.save();
            setState(() {});
          },
          assetStore: world.interfaceSoundsAssetStore,
          defaultGain: soundOptions.defaultGain,
          nullable: true,
          title: 'Menu Move Sound',
        ),
        SoundListTile(
          context: context,
          projectContext: widget.projectContext,
          value: menuActivateSound,
          onDone: (value) {
            soundOptions.menuActivateSound = value;
            widget.projectContext.save();
            setState(() {});
          },
          assetStore: world.interfaceSoundsAssetStore,
          nullable: true,
          title: 'Menu Activate Sound',
          defaultGain: soundOptions.defaultGain,
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
