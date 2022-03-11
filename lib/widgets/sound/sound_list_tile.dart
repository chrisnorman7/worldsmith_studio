import 'dart:math';

import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../screens/asset_store/select_asset.dart';
import '../../screens/sound/edit_sound.dart';
import '../../util.dart';

/// A list tile to display and edit a [Sound] instance.
class SoundListTile extends StatefulWidget {
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
  State<SoundListTile> createState() => _SoundListTileState();
}

class _SoundListTileState extends State<SoundListTile> {
  PlaySound? _playSound;

  /// Get the asset reference reference for the [widget]'s sound.
  AssetReferenceReference? get assetReferenceReference {
    final sound = widget.value;
    return sound == null
        ? null
        : getAssetReferenceReference(
            assets: widget.assetStore.assets,
            id: sound.id,
          );
  }

  /// Build the widget.
  @override
  Widget build(BuildContext context) {
    final sound = widget.value;
    final String subtitle;
    if (sound == null) {
      subtitle = 'Not set';
    } else {
      final playSound = _playSound;
      if (playSound != null) {
        playSound.gain = sound.gain;
      }
      subtitle = '${assetString(
        assetReferenceReference!,
      )} (${sound.gain})';
    }
    return Semantics(
      child: Shortcuts(
        shortcuts: const {
          IncreaseIntent.hotkey: IncreaseIntent(),
          DecreaseIntent.hotkey: DecreaseIntent(),
        },
        child: Actions(
          actions: {
            DecreaseIntent: CallbackAction<DecreaseIntent>(
              onInvoke: (intent) {
                final sound = widget.value;
                if (sound == null) {
                  return null;
                }
                sound.gain = roundDouble(max(0.0, sound.gain - 0.1));
                setState(() {
                  widget.onDone(sound);
                });
                return null;
              },
            ),
            IncreaseIntent: CallbackAction<IncreaseIntent>(
              onInvoke: (intent) {
                final sound = widget.value;
                if (sound == null) {
                  return null;
                }
                sound.gain = roundDouble(sound.gain + 0.1);
                setState(() {
                  widget.onDone(sound);
                });
                return null;
              },
            )
          },
          child: ListTile(
            autofocus: widget.autofocus,
            title: Text(widget.title),
            subtitle: Text(subtitle),
            onTap: () async {
              if (widget.assetStore.assets.isEmpty) {
                return showError(
                  context: context,
                  message: 'There are no valid assets.',
                );
              }
              stop();
              final v = widget.value;
              if (v == null) {
                pushWidget(
                  context: context,
                  builder: (context) => SelectAsset(
                    projectContext: widget.projectContext,
                    assetStore: widget.assetStore,
                    onDone: (value) {
                      Navigator.pop(context);
                      final sound = Sound(
                        id: value!.variableName,
                        gain: widget
                            .projectContext.world.soundOptions.defaultGain,
                      );
                      widget.onDone(sound);
                      pushEditSoundWidget(context: context, sound: sound);
                    },
                  ),
                );
              } else {
                pushEditSoundWidget(context: context, sound: v);
              }
            },
          ),
        ),
      ),
      onDidGainAccessibilityFocus: play,
      onDidLoseAccessibilityFocus: stop,
    );
  }

  /// Push the [EditSound] widget.
  Future<void> pushEditSoundWidget({
    required BuildContext context,
    required Sound sound,
  }) async =>
      pushWidget(
        context: context,
        builder: (context) => EditSound(
          projectContext: widget.projectContext,
          assetStore: widget.assetStore,
          sound: sound,
          onChanged: widget.onDone,
          nullable: widget.nullable,
          title: widget.title,
        ),
      );

  /// Dispose of the playing sound.
  @override
  void dispose() {
    super.dispose();
    stop();
  }

  /// Start the playing sound.
  void play() {
    stop();
    _playSound = widget.projectContext.game.interfaceSounds.playSound(
      assetReferenceReference!.reference,
      gain: widget.value!.gain,
      keepAlive: true,
      looping: widget.looping,
    );
  }

  /// Stop the playing sound.
  void stop() {
    _playSound?.destroy();
    _playSound = null;
  }
}
