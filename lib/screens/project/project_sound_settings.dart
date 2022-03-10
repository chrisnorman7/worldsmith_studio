import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/sound/gain_list_tile.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../sound/synthizer_settings.dart';

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
        GainListTile(
          autofocus: true,
          gain: soundOptions.defaultGain,
          onChange: (value) {
            soundOptions.defaultGain = value;
            save();
          },
          title: 'Default Gain',
        ),
        SoundListTile(
          projectContext: widget.projectContext,
          value: menuMoveSound,
          onDone: (value) {
            soundOptions.menuMoveSound = value;
            save();
          },
          assetStore: world.interfaceSoundsAssetStore,
          defaultGain: soundOptions.defaultGain,
          nullable: true,
          title: 'Menu Move Sound',
        ),
        SoundListTile(
          projectContext: widget.projectContext,
          value: menuActivateSound,
          onDone: (value) {
            soundOptions.menuActivateSound = value;
            save();
          },
          assetStore: world.interfaceSoundsAssetStore,
          nullable: true,
          title: 'Menu Activate Sound',
          defaultGain: soundOptions.defaultGain,
        ),
        SoundListTile(
          projectContext: widget.projectContext,
          value: soundOptions.menuCancelSound,
          onDone: (value) {
            soundOptions.menuCancelSound = value;
            save();
          },
          assetStore: world.interfaceSoundsAssetStore,
          defaultGain: soundOptions.defaultGain,
          nullable: true,
          title: 'Menu Cancel Sound',
        ),
        ListTile(
          title: const Text('Synthizer Settings'),
          subtitle: const Text('(Requires restart)'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (context) => SynthizerSettings(
                projectContext: widget.projectContext,
              ),
            );
            setState(() {});
          },
        )
      ],
    );
  }

  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Set default gain.
  set defaultGain(double value) {
    widget.projectContext.world.soundOptions.defaultGain = value;
    widget.projectContext.save();
    setState(() {});
  }
}
