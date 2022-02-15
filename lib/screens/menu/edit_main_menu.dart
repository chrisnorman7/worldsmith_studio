import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/text_list_tile.dart';
import '../sound/fade_time_list_tile.dart';
import '../sound/music_player.dart';
import '../sound/sound_list_tile.dart';

/// Edit the main menu.
class EditMainMenu extends StatefulWidget {
  /// Create an instance.
  const EditMainMenu({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _EditMainMenuState createState() => _EditMainMenuState();
}

/// State for [EditMainMenu].
class _EditMainMenuState extends State<EditMainMenu> {
  MusicPlayer? _musicPlayer;

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    var musicPlayer = _musicPlayer;
    final world = widget.projectContext.world;
    final defaultGain = world.soundOptions.defaultGain;
    final options = world.mainMenuOptions;
    final music = world.mainMenuMusic;
    if (music == null) {
      _musicPlayer?.stop();
      _musicPlayer = null;
    } else {
      if (musicPlayer == null) {
        musicPlayer = MusicPlayer(
          channel: widget.projectContext.game.ambianceSounds,
          assetReference: widget.projectContext.getRelativeAssetReference(
            music.sound,
          ),
          gain: music.gain,
          fadeBuilder: () => options.fadeTime,
        )..play();
      } else {
        musicPlayer
          ..gain = music.gain
          ..assetReference = widget.projectContext.getRelativeAssetReference(
            music.sound,
          );
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
            getPlaySoundSemantics(
              child: TextListTile(
                value: options.title,
                onChanged: (value) {
                  options.title = value;
                  save();
                },
                header: 'Title',
                autofocus: true,
                title: 'Menu Title',
                validator: (value) => validateNonEmptyValue(value: value),
              ),
            ),
            getPlaySoundSemantics(
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
                title: 'Main Menu Music',
                playSound: false,
              ),
            ),
            getPlaySoundSemantics(
              child: FadeTimeListTile(
                value: options.fadeTime,
                onChanged: (value) {
                  options.fadeTime = value;
                  save();
                },
              ),
            ),
            getPlaySoundSemantics(
              child: TextListTile(
                value: options.newGameTitle,
                onChanged: (value) {
                  options.newGameTitle = value;
                  save();
                },
                header: 'New Game Title',
                validator: (value) => validateNonEmptyValue(value: value),
              ),
            ),
            getPlaySoundSemantics(
              child: TextListTile(
                value: options.savedGameTitle,
                onChanged: (value) {
                  options.savedGameTitle = value;
                  save();
                },
                header: 'Play Saved Game Title',
                validator: (value) => validateNonEmptyValue(value: value),
              ),
            ),
            getPlaySoundSemantics(
              child: TextListTile(
                value: options.creditsTitle,
                onChanged: (value) {
                  options.creditsTitle = value;
                  save();
                },
                header: 'Credits Title',
                validator: (value) => validateNonEmptyValue(value: value),
              ),
            ),
            getPlaySoundSemantics(
              child: TextListTile(
                value: options.exitTitle,
                onChanged: (value) {
                  options.exitTitle = value;
                  save();
                },
                header: 'Exit Title',
                validator: (value) => validateNonEmptyValue(value: value),
              ),
            ),
            getPlaySoundSemantics(
              child: TextListTile(
                value: options.exitMessage,
                onChanged: (value) {
                  options.exitMessage = value;
                  save();
                },
                header: 'Exit Message',
                validator: (value) => validateNonEmptyValue(value: value),
              ),
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

  /// Get a play sound semantics widget.
  PlaySoundSemantics getPlaySoundSemantics({required Widget child}) =>
      PlaySoundSemantics(
        child: child,
        soundChannel: widget.projectContext.game.interfaceSounds,
        assetReference: widget.projectContext.menuMoveSound,
        gain: widget.projectContext.world.soundOptions.menuMoveSound?.gain ??
            widget.projectContext.world.soundOptions.defaultGain,
      );
}
