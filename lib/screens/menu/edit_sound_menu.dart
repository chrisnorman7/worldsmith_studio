import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/music_widget.dart';
import '../../widgets/number_list_tile.dart';
import '../../widgets/sound/fade_time_list_tile.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing the sound options menu.
class EditSoundMenu extends StatefulWidget {
  /// Create an instance.
  const EditSoundMenu({
    required this.projectContext,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  EditSoundMenuState createState() => EditSoundMenuState();
}

/// State for [EditSoundMenu].
class EditSoundMenuState extends State<EditSoundMenu> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final options = world.soundMenuOptions;
    return Cancel(
      child: MusicWidget(
        title: options.title,
        soundChannel: widget.projectContext.game.musicSounds,
        getMusic: () => world.soundMenuMusic,
        getFadeTime: () => options.fadeTime,
        child: ListView(
          children: [
            TextListTile(
              value: options.title,
              onChanged: (final value) {
                options.title = value;
                save();
              },
              header: 'Title',
              autofocus: true,
              validator: (final value) => validateNonEmptyValue(value: value),
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: options.music,
              onDone: (final value) {
                options.music = value;
                save();
              },
              assetStore: world.musicAssetStore,
              defaultGain: world.soundOptions.defaultGain,
              nullable: true,
              playSound: false,
            ),
            FadeTimeListTile(
              value: options.fadeTime,
              onChanged: (final value) {
                options.fadeTime = value;
                save();
              },
            ),
            NumberListTile(
              value: options.gainAdjust,
              onChanged: (final value) {
                options.gainAdjust = value;
                save();
              },
              max: 1.0,
              min: 0.01,
              title: 'Gain Adjust',
            ),
            widget.projectContext.getMenuMoveSemantics(
              child: TextListTile(
                value: options.interfaceSoundsVolumeTitle,
                onChanged: (final value) {
                  options.interfaceSoundsVolumeTitle = value;
                  save();
                },
                header: 'Interface Sounds Volume Title',
                labelText: 'Title',
                validator: (final value) => validateNonEmptyValue(value: value),
              ),
            ),
            widget.projectContext.getMenuMoveSemantics(
              child: TextListTile(
                value: options.musicVolumeTitle,
                onChanged: (final value) {
                  options.musicVolumeTitle = value;
                  save();
                },
                header: 'Music Sounds Volume Title',
                labelText: 'Title',
                validator: (final value) => validateNonEmptyValue(value: value),
              ),
            ),
            widget.projectContext.getMenuMoveSemantics(
              child: TextListTile(
                value: options.ambianceSoundsVolumeTitle,
                onChanged: (final value) {
                  options.ambianceSoundsVolumeTitle = value;
                  save();
                },
                header: 'Ambiance Sounds Volume Title',
                labelText: 'Title',
                validator: (final value) => validateNonEmptyValue(value: value),
              ),
            ),
            widget.projectContext.getMenuMoveSemantics(
              child: TextListTile(
                value: options.outputTypeTitle,
                onChanged: (final value) {
                  options.outputTypeTitle = value;
                  save();
                },
                header: 'Output Type Title',
                labelText: 'Title',
                validator: (final value) => validateNonEmptyValue(value: value),
              ),
            ),
            TextListTile(
              value: options.headphonesPresetTitle,
              onChanged: (final value) {
                options.headphonesPresetTitle = value;
                save();
              },
              header: 'Headphones Preset Name',
              labelText: 'Name',
              validator: (final value) => validateNonEmptyValue(value: value),
            ),
            TextListTile(
              value: options.speakersPresetTitle,
              onChanged: (final value) {
                options.speakersPresetTitle = value;
                save();
              },
              header: 'Speakers Preset Name',
              labelText: 'Name',
              validator: (final value) => validateNonEmptyValue(value: value),
            ),
          ],
        ),
      ),
    );
  }

  /// Save the project context and set state.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
