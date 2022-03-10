import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/custom_message/custom_message_list_tile.dart';
import '../../widgets/music_widget.dart';
import '../../widgets/sound/fade_time_list_tile.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/text_list_tile.dart';

/// A menu for editing pause men options.
class EditPauseMenu extends StatefulWidget {
  /// Create an instance.
  const EditPauseMenu({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _EditPauseMenuState createState() => _EditPauseMenuState();
}

/// State for [EditPauseMenu].
class _EditPauseMenuState extends State<EditPauseMenu> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final defaultGain = world.soundOptions.defaultGain;
    final options = world.pauseMenuOptions;
    return Cancel(
      child: MusicWidget(
        getFadeTime: () => options.fadeTime,
        getMusic: () => world.pauseMenuMusic,
        soundChannel: widget.projectContext.game.musicSounds,
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
              title: 'Pause Menu Title',
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
              defaultGain: defaultGain,
              nullable: true,
              title: 'Pause Menu Music',
              playSound: false,
            ),
            FadeTimeListTile(
              value: options.fadeTime,
              onChanged: (value) {
                options.fadeTime = value;
                save();
              },
            ),
            const Divider(),
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: options.zoneOverviewMessage,
              title: 'Zone Overview Label',
              assetReference: world.menuMoveSound,
            ),
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: options.returnToGameMessage,
              title: 'Return To Game',
              assetReference: world.menuMoveSound,
            )
          ],
        ),
      ),
    );
  }

  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
