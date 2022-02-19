import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';

/// A widget for selecting an asset store.
class SelectAssetStore extends StatefulWidget {
  /// Create an instance.
  const SelectAssetStore({
    required this.projectContext,
    required this.onDone,
    this.currentAssetStore,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The currently used asset store.
  final CustomSoundAssetStore? currentAssetStore;

  /// The function to call with the final asset store.
  final ValueChanged<CustomSoundAssetStore?> onDone;

  /// Create state for this widget.
  @override
  _SelectAssetStoreState createState() => _SelectAssetStoreState();
}

/// State for [SelectAssetStore].
class _SelectAssetStoreState extends State<SelectAssetStore> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final assetStores = {
      CustomSoundAssetStore.credits: world.creditsAssetStore,
      CustomSoundAssetStore.equipment: world.equipmentAssetStore,
      CustomSoundAssetStore.interface: world.interfaceSoundsAssetStore,
      CustomSoundAssetStore.music: world.musicAssetStore,
      CustomSoundAssetStore.terrain: world.terrainAssetStore
    };
    final entries = assetStores.entries.toList();
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Asset Store'),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            if (index == 0) {
              return ListTile(
                autofocus: widget.currentAssetStore == null,
                selected: widget.currentAssetStore == null,
                title: const Text('Clear'),
                onTap: () => widget.onDone(null),
              );
            }
            final entry = entries[index - 1];
            final member = entry.key;
            final store = entry.value;
            return ListTile(
              autofocus: (widget.currentAssetStore == null && index == 0) ||
                  member == widget.currentAssetStore,
              title: Text('${store.comment}'),
              subtitle: Text('Assets: ${store.assets.length}'),
              onTap: () => widget.onDone(member),
              selected: widget.currentAssetStore == member,
            );
          },
          itemCount: entries.length + 1,
        ),
      ),
    );
  }
}
