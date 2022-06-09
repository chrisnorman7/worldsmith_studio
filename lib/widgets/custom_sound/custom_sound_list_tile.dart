import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../screens/asset_store/select_asset.dart';
import '../../screens/asset_store/select_asset_store.dart';
import '../../screens/sound/edit_custom_sound.dart';
import '../../util.dart';
import '../play_sound_semantics.dart';

/// A widget for displaying a [CustomSound].
class CustomSoundListTile extends StatelessWidget {
  /// Create an instance.
  const CustomSoundListTile({
    required this.projectContext,
    required this.value,
    required this.onChanged,
    this.title = 'Sound',
    this.autofocus = false,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The sound to view and edit.
  final CustomSound? value;

  /// The function to call when editing [value].
  final ValueChanged<CustomSound?> onChanged;

  /// The title for the resulting [ListTile].
  final String title;

  /// Whether the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final worldContext = projectContext.worldContext;
    final sound = value;
    final assetStore =
        sound == null ? null : worldContext.getAssetStore(sound.assetStore);
    final assetReferenceReference = sound != null && assetStore != null
        ? assetStore.assets.firstWhere(
            (final element) => element.variableName == sound.id,
          )
        : null;
    final audioBusId = sound?.audioBusId;
    final audioBus = audioBusId == null
        ? null
        : projectContext.world.getAudioBus(audioBusId);
    final audioBusName = audioBus == null ? '' : ' (${audioBus.name})';
    return PlaySoundSemantics(
      soundChannel: audioBus == null
          ? projectContext.game.interfaceSounds
          : worldContext.getAudioBus(audioBus),
      assetReference: assetReferenceReference?.reference,
      gain: sound?.gain ?? 0.0,
      child: Builder(
        builder: (final context) => ListTile(
          autofocus: autofocus,
          title: Text(title),
          subtitle: Text(
            sound == null
                ? 'Not set'
                : '${assetStore?.comment}/${assetReferenceReference?.comment}$audioBusName',
          ),
          onTap: () {
            PlaySoundSemantics.of(context)?.stop();
            if (sound == null) {
              pushWidget(
                context: context,
                builder: (final context) => SelectAssetStore(
                  projectContext: projectContext,
                  onDone: (final store) {
                    if (store == null) {
                      Navigator.pop(context);
                    } else {
                      pushWidget(
                        context: context,
                        builder: (final context) => SelectAsset(
                          projectContext: projectContext,
                          assetStore: worldContext.getAssetStore(store),
                          onDone: (final asset) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            if (asset != null) {
                              final customSound = CustomSound(
                                assetStore: store,
                                id: asset.variableName,
                              );
                              onChanged(customSound);
                            }
                          },
                        ),
                      );
                    }
                  },
                ),
              );
            } else {
              pushWidget(
                context: context,
                builder: (final context) => EditCustomSound(
                  projectContext: projectContext,
                  value: sound,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
