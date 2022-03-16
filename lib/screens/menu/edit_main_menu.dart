import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/custom_message/custom_message_list_tile.dart';
import '../../widgets/music_widget.dart';
import '../../widgets/sound/fade_time_list_tile.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/text_list_tile.dart';

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
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final defaultGain = world.soundOptions.defaultGain;
    final options = world.mainMenuOptions;
    return Cancel(
      child: MusicWidget(
        getFadeTime: () => options.fadeTime,
        getMusic: () => world.mainMenuMusic,
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
              title: 'Menu Title',
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
              title: 'Main Menu Music',
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

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
