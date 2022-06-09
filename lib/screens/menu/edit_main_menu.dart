import 'package:flutter/material.dart';

import '../../custom_message.dart';
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
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  EditMainMenuState createState() => EditMainMenuState();
}

/// State for [EditMainMenu].
class EditMainMenuState extends State<EditMainMenu> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final defaultGain = world.soundOptions.defaultGain;
    final options = world.mainMenuOptions;
    final interfaceSoundsAssetStore = world.interfaceSoundsAssetStore;
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
              onChanged: (final value) {
                options.title = value;
                save();
              },
              header: 'Title',
              autofocus: true,
              title: 'Menu Title',
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
              defaultGain: defaultGain,
              nullable: true,
              title: 'Main Menu Music',
              playSound: false,
            ),
            FadeTimeListTile(
              value: options.fadeTime,
              onChanged: (final value) {
                options.fadeTime = value;
                save();
              },
            ),
            const Divider(),
            CustomMessageListTile(
              customMessage: CustomMessage(
                sound: options.newGameSound,
                text: options.newGameString,
              ),
              assetStore: interfaceSoundsAssetStore,
              onChanged: (final value) {
                options
                  ..newGameSound = value.sound
                  ..newGameString = value.text;
                save();
              },
              projectContext: widget.projectContext,
              title: 'Play New Game Menu Item',
              assetReference: world.menuMoveSound,
            ),
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: CustomMessage(
                sound: options.savedGameSound,
                text: options.savedGameString,
              ),
              title: 'Play Saved Game Menu Item',
              assetReference: world.menuMoveSound,
              assetStore: interfaceSoundsAssetStore,
              onChanged: (final value) {
                options
                  ..savedGameSound = value.sound
                  ..savedGameString = value.text;
                save();
              },
            ),
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: CustomMessage(
                sound: options.creditsSound,
                text: options.creditsString,
              ),
              title: 'Show Credits Menu Item',
              assetReference: world.menuMoveSound,
              assetStore: interfaceSoundsAssetStore,
              onChanged: (final value) {
                options
                  ..creditsSound = value.sound
                  ..creditsString = value.text;
                save();
              },
            ),
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: CustomMessage(
                sound: options.controlsMenuSound,
                text: options.controlsMenuString,
              ),
              assetStore: interfaceSoundsAssetStore,
              assetReference: world.menuMoveSound,
              onChanged: (final value) {
                options
                  ..controlsMenuSound = value.sound
                  ..controlsMenuString = value.text;
                save();
              },
              title: 'Show Game Controls Menu Item',
            ),
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: CustomMessage(
                sound: options.soundOptionsSound,
                text: options.soundOptionsString,
              ),
              assetStore: interfaceSoundsAssetStore,
              assetReference: world.menuMoveSound,
              onChanged: (final value) {
                options
                  ..soundOptionsSound = value.sound
                  ..soundOptionsString = value.text;
                save();
              },
              title: 'Sound Options Menu Item',
            ),
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: CustomMessage(
                sound: options.exitSound,
                text: options.exitString,
              ),
              title: 'Exit Game Menu Item',
              assetReference: world.menuMoveSound,
              assetStore: interfaceSoundsAssetStore,
              onChanged: (final value) {
                options
                  ..exitSound = value.sound
                  ..exitString = value.text;
                save();
              },
            ),
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: CustomMessage(
                sound: options.onExitSound,
                text: options.onExitString,
              ),
              title: 'Game Exiting Message',
              assetReference: world.menuMoveSound,
              assetStore: interfaceSoundsAssetStore,
              onChanged: (final value) {
                options
                  ..onExitSound = value.sound
                  ..onExitString = value.text;
                save();
              },
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
