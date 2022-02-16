import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/text_list_tile.dart';
import '../sound/music_player.dart';

/// A widget for editing the credits menu.
class EditCreditsMenu extends StatefulWidget {
  /// Create an instance.
  const EditCreditsMenu({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _EditCreditsMenuState createState() => _EditCreditsMenuState();
}

/// State for [EditCreditsMenu].
class _EditCreditsMenuState extends State<EditCreditsMenu> {
  MusicPlayer? _musicPlayer;

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    var musicPlayer = _musicPlayer;
    final world = widget.projectContext.world;
    final options = world.creditsMenuOptions;
    final music = world.creditsMenuMusic;
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
          title: const Text('Credits Menu'),
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
