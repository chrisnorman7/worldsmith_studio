import 'package:flutter/material.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import 'edit_asset_store.dart';

/// A list tile that shows an asset store.
class AssetStoreListTile extends ListTile {
  /// Create an instance.
  AssetStoreListTile({
    required BuildContext context,
    required ProjectContext projectContext,
    required AssetStore assetStore,
    required VoidCallback afterOnTap,
    required CanDelete<AssetReferenceReference> canDelete,
    bool autofocus = false,
    Key? key,
  }) : super(
          key: key,
          autofocus: autofocus,
          title: Text('${assetStore.comment}'),
          subtitle: Text('Assets: ${assetStore.assets.length}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (context) => EditAssetStore(
                projectContext: projectContext,
                assetStore: assetStore,
                canDelete: canDelete,
              ),
            );
            afterOnTap();
          },
        );
}
