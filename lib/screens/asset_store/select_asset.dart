import 'package:flutter/material.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../project_context.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/select_item.dart';

/// A widget for selecting an asset reference.
class SelectAsset extends StatelessWidget {
  /// Create an instance.
  const SelectAsset({
    required this.projectContext,
    required this.assetStore,
    required this.onDone,
    this.currentId,
    this.nullable = false,
    this.title = 'Select Asset',
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The asset store to select an asset from.
  final AssetStore assetStore;

  /// The function to be called with the resulting asset.
  final ValueChanged<AssetReferenceReference?> onDone;

  /// The ID of the current asset reference.
  final String? currentId;

  /// Whether or not the asset can be null.
  final bool nullable;

  /// The title of the resulting scaffold.
  final String title;

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final assets = <AssetReferenceReference?>[];
    if (nullable == true) {
      assets.add(null);
    }
    assets.addAll(assetStore.assets);
    final id = currentId;
    return SelectItem<AssetReferenceReference?>(
      onDone: onDone,
      values: assets,
      getItemWidget: (value) {
        if (value == null) {
          return const Text('Clear');
        }
        return PlaySoundSemantics(
          child: Text(value.comment ?? 'Untitled Asset'),
          soundChannel: projectContext.game.interfaceSounds,
          assetReference: value.reference,
          gain: projectContext.world.soundOptions.defaultGain,
        );
      },
      title: title,
      value: id == null
          ? null
          : assetStore.assets.firstWhere(
              (element) => element.variableName == id,
            ),
    );
  }
}
