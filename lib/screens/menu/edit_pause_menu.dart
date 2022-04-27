// ignore_for_file: prefer_final_parameters
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

/// A menu for editing pause men options.
class EditPauseMenu extends StatefulWidget {
  /// Create an instance.
  const EditPauseMenu({
    required this.projectContext,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  EditPauseMenuState createState() => EditPauseMenuState();
}

/// State for [EditPauseMenu].
class EditPauseMenuState extends State<EditPauseMenu> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final defaultGain = world.soundOptions.defaultGain;
    final options = world.pauseMenuOptions;
    final interfaceSoundsAssetStore = world.interfaceSoundsAssetStore;
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
              onChanged: (final value) {
                options.title = value;
                save();
              },
              header: 'Title',
              autofocus: true,
              title: 'Pause Menu Title',
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
              title: 'Pause Menu Music',
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
              projectContext: widget.projectContext,
              customMessage: CustomMessage(
                sound: options.zoneOverviewSound,
                text: options.zoneOverviewString,
              ),
              title: 'Zone Overview Label',
              assetReference: world.menuMoveSound,
              assetStore: interfaceSoundsAssetStore,
              onChanged: (value) {
                options
                  ..zoneOverviewSound = value.sound
                  ..zoneOverviewString = value.text;
                save();
              },
            ),
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: CustomMessage(
                sound: options.returnToGameSound,
                text: options.returnToGameString,
              ),
              title: 'Return To Game',
              assetReference: world.menuMoveSound,
              assetStore: interfaceSoundsAssetStore,
              onChanged: (value) {
                options
                  ..returnToGameSound = value.sound
                  ..returnToGameString = value.text;
                save();
              },
            ),
            CustomMessageListTile(
              projectContext: widget.projectContext,
              customMessage: CustomMessage(
                sound: options.returnToMainMenuSound,
                text: options.returnToMainMenuString,
              ),
              title: 'Return To Main Menu',
              assetReference: world.menuMoveSound,
              assetStore: interfaceSoundsAssetStore,
              onChanged: (value) {
                options
                  ..returnToMainMenuSound = value.sound
                  ..returnToMainMenuString = value.text;
                save();
              },
            ),
            FadeTimeListTile(
              value: options.returnToMainMenuFadeTime,
              onChanged: (final value) {
                options.returnToMainMenuFadeTime = value;
                save();
              },
              title: 'Return To Main Menu Fade Time',
            )
          ],
        ),
      ),
    );
  }

  /// Save the project context.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
