import 'package:flutter/material.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../screens/asset_store/edit_asset_store.dart';
import '../push_widget_list_tile.dart';
import '../searchable_list_view.dart';

/// A list tile that shows an asset store.
class AssetStoreListTile extends SearchableListTile {
  /// Create an instance.
  AssetStoreListTile({
    required this.projectContext,
    required this.assetStore,
    required this.afterOnTap,
    required this.canDelete,
    this.autofocus = false,
  }) : super(
          child: Builder(
            builder: (final context) => PushWidgetListTile(
              autofocus: autofocus,
              title: '${assetStore.comment}',
              subtitle: 'Assets: ${assetStore.assets.length}',
              builder: (final context) => EditAssetStore(
                projectContext: projectContext,
                assetStore: assetStore,
                canDelete: canDelete,
              ),
              onSetState: afterOnTap,
            ),
          ),
          searchString: assetStore.comment!,
        );

  /// The project context to use.
  final ProjectContext projectContext;

  /// The asset store to show.
  final AssetStore assetStore;

  /// A function to be called after the [assetStore] has been edited.
  final VoidCallback afterOnTap;

  /// Whether or not an asset reference can be deleted.
  final CanDelete<AssetReferenceReference> canDelete;

  /// Whether or not the resulting [ListTile] should be autofocused.
  final bool autofocus;
}
