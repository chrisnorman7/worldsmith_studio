import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../asset_store/edit_asset_store.dart';

/// A widget for showing asset stores.
class ProjectAssetStores extends StatefulWidget {
  /// Create an instance.
  const ProjectAssetStores({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _ProjectAssetStoresState createState() => _ProjectAssetStoresState();
}

/// State for [ProjectAssetStores].
class _ProjectAssetStoresState extends State<ProjectAssetStores> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final assetStores = [
      world.equipmentAssetStore,
      world.musicAssetStore,
      world.terrainAssetStore,
      world.interfaceSoundsAssetStore,
      world.creditsAssetStore
    ];
    return ListView.builder(
      itemBuilder: (context, index) {
        final assetStore = assetStores[index];
        return ListTile(
          autofocus: index == 0,
          title: Text('${assetStore.comment}'),
          subtitle: Text('Assets: ${assetStore.assets.length}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (context) => EditAssetStore(
                projectContext: widget.projectContext,
                assetStore: assetStore,
                canDelete: (reference) => 'You cannot currently delete assets.',
              ),
            );
            setState(() {});
          },
        );
      },
      itemCount: assetStores.length,
    );
  }
}
