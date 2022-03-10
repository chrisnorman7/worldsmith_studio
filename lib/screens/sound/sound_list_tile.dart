import 'dart:math';

import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../intents.dart';
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
    final subtitle = value == null
        ? 'Not set'
        : '${assetString(
            getAssetReferenceReference(
              assets: assetStore.assets,
              id: value?.id,
            )!,
          )} (${value?.gain})';
    return Shortcuts(
      shortcuts: const {
        IncreaseIntent.hotkey: IncreaseIntent(),
        DecreaseIntent.hotkey: DecreaseIntent(),
      },
      child: Actions(
        actions: {
          DecreaseIntent: CallbackAction<DecreaseIntent>(
            onInvoke: (intent) {
              final sound = value;
              if (sound == null) {
                return null;
              }
              sound.gain = roundDouble(max(0.0, sound.gain - 0.1));
              onDone(sound);
              return null;
            },
          ),
          IncreaseIntent: CallbackAction<IncreaseIntent>(
            onInvoke: (intent) {
              final sound = value;
              if (sound == null) {
                return null;
              }
              sound.gain = roundDouble(sound.gain + 0.1);
              onDone(sound);
              return null;
            },
          )
        },
        child: playSound == true
            ? PlaySoundSemantics(
                child: Builder(
                  builder: (context) => getListTile(
                    context: context,
                    subtitle: subtitle,
                  ),
                ),
                soundChannel: projectContext.game.interfaceSounds,
                assetReference: value == null
                    ? null
                    : getAssetReferenceReference(
                        assets: assetStore.assets,
                        id: value?.id,
                      )!
                        .reference,
                gain: value?.gain ??
                    projectContext.world.soundOptions.defaultGain,
                looping: looping,
              )
            : getListTile(subtitle: subtitle, context: context),
      ),
    );
  }

  /// Get the resulting list tile.
  ListTile getListTile({
    required BuildContext context,
    required String subtitle,
  }) =>
      ListTile(
        autofocus: autofocus,
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () => listTileOnTap(context),
      );

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

  /// What happens when the [ListTile] is tapped.
  void listTileOnTap(BuildContext context) async {
    if (assetStore.assets.isEmpty) {
      return showSnackBar(
        context: context,
        message: 'There are no valid assets.',
      );
    }
    PlaySoundSemantics.of(context)?.stop();
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
  }
}
