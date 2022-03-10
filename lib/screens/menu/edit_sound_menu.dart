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
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _EditSoundMenuState createState() => _EditSoundMenuState();
}

/// State for [EditSoundMenu].
class _EditSoundMenuState extends State<EditSoundMenu> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final options = world.soundMenuOptions;
    return Cancel(
      child: MusicWidget(
        title: options.title,
        child: ListView(
          children: [
            TextListTile(
              value: options.title,
              onChanged: (value) {
                options.title = value;
                save();
              },
              header: 'Title',
              autofocus: true,
              validator: (value) => validateNonEmptyValue(value: value),
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: options.music,
              onDone: (value) {
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
              onChanged: (value) {
                options.fadeTime = value;
                save();
              },
            ),
            NumberListTile(
              value: options.gainAdjust,
              onChanged: (value) {
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
                onChanged: (value) {
                  options.interfaceSoundsVolumeTitle = value;
                  save();
                },
                header: 'Interface Sounds Volume Title',
                labelText: 'Title',
                validator: (value) => validateNonEmptyValue(value: value),
              ),
            ),
            widget.projectContext.getMenuMoveSemantics(
              child: TextListTile(
                value: options.musicVolumeTitle,
                onChanged: (value) {
                  options.musicVolumeTitle = value;
                  save();
                },
                header: 'Music Sounds Volume Title',
                labelText: 'Title',
                validator: (value) => validateNonEmptyValue(value: value),
              ),
            ),
            widget.projectContext.getMenuMoveSemantics(
              child: TextListTile(
                value: options.ambianceSoundsVolumeTitle,
                onChanged: (value) {
                  options.ambianceSoundsVolumeTitle = value;
                  save();
                },
                header: 'Ambiance Sounds Volume Title',
                labelText: 'Title',
                validator: (value) => validateNonEmptyValue(value: value),
              ),
            ),
            widget.projectContext.getMenuMoveSemantics(
              child: TextListTile(
                value: options.outputTypeTitle,
                onChanged: (value) {
                  options.outputTypeTitle = value;
                  save();
                },
                header: 'Output Type Title',
                labelText: 'Title',
                validator: (value) => validateNonEmptyValue(value: value),
              ),
            ),
            TextListTile(
              value: options.headphonesPresetTitle,
              onChanged: (value) {
                options.headphonesPresetTitle = value;
                save();
              },
              header: 'Headphones Preset Name',
              labelText: 'Name',
              validator: (value) => validateNonEmptyValue(value: value),
            ),
            TextListTile(
              value: options.speakersPresetTitle,
              onChanged: (value) {
                options.speakersPresetTitle = value;
                save();
              },
              header: 'Speakers Preset Name',
              labelText: 'Name',
              validator: (value) => validateNonEmptyValue(value: value),
            ),
          ],
        ),
        soundChannel: widget.projectContext.game.musicSounds,
        getMusic: () => world.soundMenuMusic,
        getFadeTime: () => options.fadeTime,
      ),
    );
  }

  /// Save the project context and set state.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
