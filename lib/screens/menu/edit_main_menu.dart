import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/get_text.dart';
import '../../widgets/play_sound_semantics.dart';
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
    var moveSound = world.menuMoveSound;
    if (moveSound != null) {
      moveSound = widget.projectContext.getRelativeAssetReference(moveSound);
    }
    final moveSoundGain = world.soundOptions.menuMoveSound?.gain ?? defaultGain;
    final channel = widget.projectContext.game.interfaceSounds;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: Text(options.title),
        ),
        body: ListView(
          children: [
            PlaySoundSemantics(
              child: ListTile(
                autofocus: true,
                title: const Text('Title'),
                subtitle: Text(options.title),
                onTap: () {
                  widget.projectContext.playActivateSound();
                  pushWidget(
                    context: context,
                    builder: (context) => GetText(
                      onDone: (value) {
                        options.title = value;
                        save(context: context);
                      },
                      labelText: 'Title',
                      text: options.title,
                      title: 'Main Menu Title',
                      validator: (value) => validateNonEmptyValue(value: value),
                    ),
                  );
                },
              ),
              soundChannel: channel,
              assetReference: moveSound,
              gain: moveSoundGain,
            ),
            PlaySoundSemantics(
              child: SoundListTile(
                projectContext: widget.projectContext,
                value: options.music,
                onDone: (value) {
                  options.music = value;
                  save(context: context, pop: false);
                },
                assetStore: world.musicAssetStore,
                defaultGain: defaultGain,
                nullable: true,
                title: 'Main Menu Music',
                playSound: false,
              ),
              soundChannel: channel,
              assetReference: moveSound,
              gain: moveSoundGain,
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

  void save({required BuildContext context, bool pop = true}) {
    if (pop) {
      Navigator.pop(context);
    }
    widget.projectContext.save();
    setState(() {});
  }
}
