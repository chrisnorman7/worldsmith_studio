// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/sound/gain_list_tile.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../audio_busses/project_audio_busses.dart';
import '../sound/synthizer_settings.dart';

/// A widget for configuring sound-related settings.
class ProjectSoundSettings extends StatefulWidget {
  /// Create an instance.
  const ProjectSoundSettings({
    required this.projectContext,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  ProjectSoundSettingsState createState() => ProjectSoundSettingsState();
}

/// State for [ProjectSoundSettings].
class ProjectSoundSettingsState extends State<ProjectSoundSettings> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final soundOptions = world.soundOptions;
    return ListView(
      children: [
        GainListTile(
          autofocus: true,
          gain: soundOptions.defaultGain,
          onChange: (final value) {
            soundOptions.defaultGain = value;
            save();
          },
          title: 'Default Gain',
        ),
        SoundListTile(
          projectContext: widget.projectContext,
          value: soundOptions.menuMoveSound,
          onDone: (final value) {
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
          value: soundOptions.menuActivateSound,
          onDone: (final value) {
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
          value: soundOptions.menuSwitchSound,
          onDone: (final value) {
            soundOptions.menuSwitchSound = value;
            save();
          },
          assetStore: world.interfaceSoundsAssetStore,
          defaultGain: soundOptions.defaultGain,
          nullable: true,
          title: 'Switch Menu Sound',
        ),
        SoundListTile(
          projectContext: widget.projectContext,
          value: soundOptions.menuCancelSound,
          onDone: (final value) {
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
              builder: (final context) => SynthizerSettings(
                projectContext: widget.projectContext,
              ),
            );
            setState(() {});
          },
        ),
        ListTile(
          title: const Text('Audio Busses'),
          subtitle: Text('${world.audioBusses.length}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (context) => ProjectAudioBusses(
                projectContext: widget.projectContext,
              ),
            );
            setState(() {});
          },
        )
      ],
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Set default gain.
  set defaultGain(final double value) {
    widget.projectContext.world.soundOptions.defaultGain = value;
    widget.projectContext.save();
    setState(() {});
  }
}
