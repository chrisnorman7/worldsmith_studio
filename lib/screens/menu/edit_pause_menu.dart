import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/custom_message/custom_message_list_tile.dart';
import '../../widgets/text_list_tile.dart';
import '../sound/fade_time_list_tile.dart';
import '../sound/music_player.dart';
import '../sound/sound_list_tile.dart';

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
  MusicPlayer? _musicPlayer;

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    var musicPlayer = _musicPlayer;
    final world = widget.projectContext.world;
    final defaultGain = world.soundOptions.defaultGain;
    final options = world.pauseMenuOptions;
    final music = world.pauseMenuMusic;
    if (music == null) {
      _musicPlayer?.stop();
      _musicPlayer = null;
    } else {
      if (musicPlayer == null) {
        musicPlayer = MusicPlayer(
          channel: widget.projectContext.game.ambianceSounds,
          assetReference: music.sound,
          gain: music.gain,
          fadeBuilder: () => options.fadeTime,
        )..play();
      } else {
        musicPlayer
          ..gain = music.gain
          ..assetReference = music.sound;
      }
      _musicPlayer = musicPlayer;
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: Text(options.title),
        ),
        body: ListView(
          children: [
            widget.projectContext.getMenuMoveSemantics(
              child: TextListTile(
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
            ),
            widget.projectContext.getMenuMoveSemantics(
              child: SoundListTile(
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
            ),
            widget.projectContext.getMenuMoveSemantics(
              child: FadeTimeListTile(
                value: options.fadeTime,
                onChanged: (value) {
                  options.fadeTime = value;
                  save();
                },
              ),
            ),
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: options.zoneOverviewMessage,
              title: 'Zone Overview Label',
            ),
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: options.returnToGameMessage,
              title: 'Return To Game',
            )
          ],
        ),
      ),
    );
  }

  /// Stop the sound playing.
  @override
  void dispose() {
    super.dispose();
    _musicPlayer?.stop();
    _musicPlayer = null;
  }

  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
