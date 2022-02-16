import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/ziggurat.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/text_list_tile.dart';
import '../sound/fade_time_list_tile.dart';
import '../sound/music_player.dart';
import '../sound/sound_list_tile.dart';

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
    final defaultGain = world.soundOptions.defaultGain;
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
                title: 'Credits Menu Music',
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
            for (final credit in world.credits)
              getCreditListTile(context: context, credit: credit)
          ],
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {
          final credit = WorldCredit(
            id: newId(),
            title: 'Person: Responsibility',
          );
          world.credits.add(credit);
          save();
        }),
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

  /// Save the project context and set state.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Return  list tile suitable for editing the given [credit].
  Widget getCreditListTile({
    required BuildContext context,
    required WorldCredit credit,
  }) {
    final world = widget.projectContext.world;
    final defaultGain = world.soundOptions.defaultGain;
    final sound = credit.sound;
    final AssetReference? assetReference;
    if (sound == null) {
      assetReference = widget.projectContext.getRelativeAssetReference(
        getAssetReferenceReference(assets: world.creditsAssets, id: sound?.id)!
            .reference,
      );
    } else {
      assetReference = widget.projectContext.menuMoveSound;
    }
    final gain =
        sound?.gain ?? world.soundOptions.menuMoveSound?.gain ?? defaultGain;
    return PlaySoundSemantics(
      child: ListTile(
        title: Text(credit.title),
        subtitle: Text(credit.url ?? 'Not set'),
        onTap: () async {
          widget.projectContext.playActivateSound();
          setState(() {});
        },
      ),
      soundChannel: widget.projectContext.game.interfaceSounds,
      assetReference: assetReference,
      gain: gain,
    );
  }
}
