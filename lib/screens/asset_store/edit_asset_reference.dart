import 'package:flutter/material.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing an asset reference.
class EditAssetReference extends StatefulWidget {
  /// Create an instance.
  const EditAssetReference({
    required this.projectContext,
    required this.assetStore,
    required this.assetReferenceReference,
    required this.canDelete,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The asset store to work with.
  final AssetStore assetStore;

  /// The asset reference to work with.
  final AssetReferenceReference assetReferenceReference;

  /// Determine whether or not [assetReferenceReference] can be deleted.
  final CanDelete<AssetReferenceReference> canDelete;

  /// Create state for this widget.
  @override
  EditAssetReferenceState createState() => EditAssetReferenceState();
}

/// State for [EditAssetReference].
class EditAssetReferenceState extends State<EditAssetReference> {
  AssetReferenceReference? _assetReferenceReference;

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    _assetReferenceReference ??= widget.assetReferenceReference;
    final reference = _assetReferenceReference!;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () {
                final result = widget.canDelete(widget.assetReferenceReference);
                if (result == null) {
                  confirm(
                    context: context,
                    message: 'Are you sure you want to delete this asset?',
                    title: 'Delete Asset',
                    yesCallback: () {
                      widget.projectContext.deleteAssetReferenceReference(
                        assetStore: widget.assetStore,
                        assetReferenceReference: reference,
                      );
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  );
                } else {
                  showError(context: context, message: result);
                }
              },
              child: deleteIcon,
            )
          ],
          title: Text('${reference.comment}'),
        ),
        body: ListView(
          children: [
            TextListTile(
              autofocus: true,
              header: 'Comment',
              value: reference.comment ?? 'Comment Me!',
              title: 'Comment',
              onChanged: (final value) {
                widget.assetStore.assets.remove(reference);
                final newReference = AssetReferenceReference(
                  variableName: reference.variableName,
                  reference: reference.reference,
                  comment: value,
                );
                widget.assetStore.assets.add(newReference);
                widget.projectContext.save();
                setState(() => _assetReferenceReference = newReference);
              },
              validator: (final value) => validateNonEmptyValue(value: value),
            ),
            ListTile(
              title: const Text('Filename'),
              subtitle: Text(widget.assetReferenceReference.reference.name),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Asset Type'),
              subtitle: Text(
                widget.assetReferenceReference.reference.type.name,
              ),
              onTap: () {},
            )
          ],
        ),
      ),
    );
  }
}
