import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../project_context.dart';
import '../../util.dart';
import 'edit_sound.dart';

/// A list tile to display and edit a [Sound] instance.
class SoundListTile extends ListTile {
  /// Create an instance.
  SoundListTile({
    required BuildContext context,
    required ProjectContext projectContext,
    required Sound? value,
    required ValueChanged<Sound?> onDone,
    required AssetStore assetStore,
    required double defaultGain,
    bool nullable = false,
    String title = 'Sound',
    bool autofocus = false,
    Key? key,
  }) : super(
          autofocus: autofocus,
          key: key,
          title: Text(title),
          subtitle: Text(
            value == null
                ? 'Not set'
                : '${assetString(
                    getAssetReferenceReference(
                      assets: assetStore.assets,
                      id: value.id,
                    )!,
                  )} (${value.gain})',
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
        );
}
