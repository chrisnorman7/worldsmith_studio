import 'package:flutter/material.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/get_text.dart';

/// A widget for editing an asset reference.
class EditAssetReference extends StatefulWidget {
  /// Create an instance.
  const EditAssetReference({
    required this.projectContext,
    required this.assetStore,
    required this.assetReferenceReference,
    required this.canDelete,
    Key? key,
  }) : super(key: key);

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
  _EditAssetReferenceState createState() => _EditAssetReferenceState();
}

/// State for [EditAssetReference].
class _EditAssetReferenceState extends State<EditAssetReference> {
  AssetReferenceReference? _assetReferenceReference;

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    var reference = _assetReferenceReference;
    if (reference == null) {
      reference = widget.assetReferenceReference;
      _assetReferenceReference = reference;
    }
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
                          assetReferenceReference: reference!,
                        );
                        Navigator.pop(context);
                        Navigator.pop(context);
                      });
                } else {
                  showSnackBar(context: context, message: result);
                }
              },
              child: deleteIcon,
            )
          ],
          title: Text('${reference.comment}'),
        ),
        body: ListView(
          children: [
            ListTile(
              autofocus: true,
              title: const Text('Comment'),
              subtitle: Text('${reference.comment}'),
              onTap: () => pushWidget(
                context: context,
                builder: (context) => GetText(
                  onDone: (value) {
                    Navigator.pop(context);
                    widget.assetStore.assets.remove(reference!);
                    final newReference = AssetReferenceReference(
                      variableName: reference.variableName,
                      reference: reference.reference,
                      comment: value,
                    );
                    widget.assetStore.assets.add(newReference);
                    widget.projectContext.save();
                    setState(() => _assetReferenceReference = newReference);
                  },
                  labelText: 'Comment',
                  text: reference?.comment ?? '',
                  title: 'Asset Comment',
                  validator: (value) => validateNonEmptyValue(value: value),
                ),
              ),
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