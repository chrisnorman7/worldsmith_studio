// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:ziggurat/sound.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/music_widget.dart';
import '../../widgets/sound/fade_time_list_tile.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/text_list_tile.dart';

/// A widget to edit the controls menu.
class EditControlsMenu extends StatefulWidget {
  /// Create an instance.
  const EditControlsMenu({
    required this.projectContext,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  EditControlsMenuState createState() => EditControlsMenuState();
}

/// State for [EditControlsMenu].
class EditControlsMenuState extends State<EditControlsMenu> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final options = world.controlsMenuOptions;
    final defaultGain = world.soundOptions.defaultGain;
    return Cancel(
      child: MusicWidget(
        title: options.title,
        soundChannel: widget.projectContext.game.interfaceSounds,
        getMusic: () {
          final music = options.music;
          if (music != null) {
            return Music(
              sound: getAssetReferenceReference(
                assets: world.musicAssets,
                id: music.id,
              ).reference,
              gain: music.gain,
            );
          }
          return null;
        },
        getFadeTime: () => options.ambianceFadeTime,
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
              looping: true,
              title: 'Controls Menu Music',
            ),
            FadeTimeListTile(
              value: options.ambianceFadeTime,
              onChanged: (value) {
                options.ambianceFadeTime = value;
                save();
              },
              title: 'Ambiance Fade Time',
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: options.itemSound,
              onDone: (value) {
                options.itemSound = value;
                save();
              },
              assetStore: world.interfaceSoundsAssetStore,
              nullable: true,
              defaultGain: defaultGain,
              title: 'Item Sound',
            ),
            TextListTile(
              value: options.subMenuTitle,
              onChanged: (value) {
                options.subMenuTitle = value;
                save();
              },
              header: 'Submenu Title',
              labelText: 'Title',
            ),
            TextListTile(
              value: options.gameControllerButtonPrefix,
              onChanged: (value) {
                options.gameControllerButtonPrefix = value;
                save();
              },
              header: 'Game Controller Button Prefix',
              labelText: 'Prefix',
            ),
            TextListTile(
              value: options.emptyGameControllerButtonMessage,
              onChanged: (value) {
                options.emptyGameControllerButtonMessage = value;
                save();
              },
              header: 'No Game Controller Message',
              labelText: 'Message',
            ),
            TextListTile(
              value: options.keyboardControlPrefix,
              onChanged: (value) {
                options.keyboardControlPrefix = value;
                save();
              },
              header: 'Keyboard Control Prefix',
              labelText: 'Prefix',
            ),
            TextListTile(
              value: options.emptyKeyboardControlMessage,
              onChanged: (value) {
                options.emptyKeyboardControlMessage = value;
                save();
              },
              header: 'No Keyboard Control Message',
              labelText: 'Message',
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
