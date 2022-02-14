import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/play_sound_semantics.dart';
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
  @override
  Widget build(BuildContext context) => PlaySoundSemantics(
        child: Builder(
          builder: (context) => ListTile(
            autofocus: autofocus,
            key: key,
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
            isThreeLine: nullable,
            trailing: nullable
                ? IconButton(
                    onPressed: () => onDone(null),
                    icon: const Icon(Icons.clear_outlined),
                    tooltip: 'Clear',
                  )
                : null,
            onTap: () async {
              PlaySoundSemantics.of(context)!.stop();
              if (assetStore.assets.isEmpty) {
                return showSnackBar(
                  context: context,
                  message: 'There are no valid assets.',
                );
              }
              final sound = value ??
                  Sound(
                    id: assetStore.assets.first.variableName,
                    gain: defaultGain,
                  );
              await pushWidget(
                context: context,
                builder: (context) => EditSound(
                  projectContext: projectContext,
                  assetStore: assetStore,
                  sound: sound,
                  title: title,
                ),
              );
              onDone(sound);
            },
          ),
        ),
        soundChannel: projectContext.game.interfaceSounds,
        assetReference: value == null
            ? null
            : projectContext.getRelativeAssetReference(
                getAssetReferenceReference(
                  assets: assetStore.assets,
                  id: value?.id,
                )!
                    .reference,
              ),
        gain: value?.gain ?? projectContext.world.soundOptions.defaultGain,
        looping: looping,
      );
}
