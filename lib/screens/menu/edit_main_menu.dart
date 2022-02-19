import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/custom_message/custom_message_list_tile.dart';
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
            widget.projectContext.getMenuMoveSemantics(
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
                title: 'Main Menu Music',
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
              customMessage: options.newGameMessage,
              projectContext: widget.projectContext,
              title: 'Play New Game Menu Item',
              assetReference: world.menuMoveSound,
            ),
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: options.savedGameMessage,
              title: 'Play Saved Game Menu Item',
              assetReference: world.menuMoveSound,
            ),
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: options.creditsMessage,
              title: 'Show Credits Menu Item',
              assetReference: world.menuMoveSound,
            ),
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: options.exitMessage,
              title: 'Exit Game Menu Item',
              assetReference: world.menuMoveSound,
            ),
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: options.onExitMessage,
              title: 'Game Exiting',
              assetReference: world.menuMoveSound,
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
