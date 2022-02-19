import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/play_sound_semantics.dart';
import '../asset_store/select_asset.dart';
import 'edit_sound.dart';

/// A list tile to display and edit a [Sound] instance.
class SoundListTile extends StatelessWidget {
  /// Create an instance.
  const SoundListTile({
    required this.projectContext,
    required this.value,
    required this.onDone,
    required this.assetStore,
    required this.defaultGain,
    this.looping = false,
    this.nullable = false,
    this.title = 'Sound',
    this.autofocus = false,
    this.playSound = true,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The current sound.
  final Sound? value;

  /// The function to be called when a sound is selected.
  final ValueChanged<Sound?> onDone;

  /// The asset store to get assets from.
  final AssetStore assetStore;

  /// The default gain to use.
  final double defaultGain;

  /// Whether or not the previewed sound should loop or not.
  final bool looping;

  /// Whether or not the resulting sound can be `null`.
  final bool nullable;

  /// The title of the resulting `ListTile].
  final String title;

  /// The `autofocus` value for the resulting [ListTile].
  final bool autofocus;

  /// Whether or not the sound should play when the [ListTile] is focused.
  final bool playSound;

  @override
  Widget build(BuildContext context) {
    final listTile = ListTile(
      autofocus: autofocus,
      title: Text(title),
      subtitle: Text(
        value == null
            ? 'Not set'
            : '${assetString(
                getAssetReferenceReference(
                  assets: assetStore.assets,
                  id: value?.id,
                )!,
              )} (${value?.gain})',
      ),
      onTap: () async {
        PlaySoundSemantics.of(context)?.stop();
        if (assetStore.assets.isEmpty) {
          return showSnackBar(
            context: context,
            message: 'There are no valid assets.',
          );
        }
        final v = value;
        if (v == null) {
          pushWidget(
            context: context,
            builder: (context) => SelectAsset(
              projectContext: projectContext,
              assetStore: assetStore,
              onDone: (value) {
                Navigator.pop(context);
                final sound = Sound(
                  id: value!.variableName,
                  gain: projectContext.world.soundOptions.defaultGain,
                );
                onDone(sound);
                pushEditSoundWidget(context: context, sound: sound);
              },
            ),
          );
        } else {
          pushEditSoundWidget(context: context, sound: v);
        }
      },
    );
    if (playSound) {
      return PlaySoundSemantics(
        child: Builder(builder: (context) => listTile),
        soundChannel: projectContext.game.interfaceSounds,
        assetReference: value == null
            ? null
            : (getAssetReferenceReference(
                assets: assetStore.assets,
                id: value?.id,
              )!
                .reference),
        gain: value?.gain ?? projectContext.world.soundOptions.defaultGain,
        looping: looping,
      );
    }
    return listTile;
  }

  /// Push the [EditSound] widget.
  Future<void> pushEditSoundWidget({
    required BuildContext context,
    required Sound sound,
  }) async =>
      pushWidget(
        context: context,
        builder: (context) => EditSound(
          projectContext: projectContext,
          assetStore: assetStore,
          sound: sound,
          onChanged: onDone,
          nullable: nullable,
          title: title,
        ),
      );
}
