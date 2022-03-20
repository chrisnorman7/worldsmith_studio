import 'package:flutter/material.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/select_item.dart';
import 'add_asset.dart';

/// A widget for selecting an asset reference.
class SelectAsset extends StatefulWidget {
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

  @override
  State<SelectAsset> createState() => _SelectAssetState();
}

class _SelectAssetState extends State<SelectAsset> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final assets = <AssetReferenceReference?>[];
    if (widget.nullable == true) {
      assets.add(null);
    }
    assets.addAll(widget.assetStore.assets);
    final id = widget.currentId;
    return WithKeyboardShortcuts(
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Add a new asset.',
          keyName: 'A',
          control: true,
        )
      ],
      child: CallbackShortcuts(
        bindings: {AddIntent.hotkey: () => addAsset(context)},
        child: SelectItem<AssetReferenceReference?>(
          onDone: widget.onDone,
          values: assets,
          getItemWidget: (value) {
            if (value == null) {
              return const Text('Clear');
            }
            return PlaySoundSemantics(
              soundChannel: widget.projectContext.game.interfaceSounds,
              assetReference: value.reference,
              gain: widget.projectContext.world.soundOptions.defaultGain,
              child: Text(value.comment ?? 'Untitled Asset'),
            );
          },
          title: widget.title,
          value: id == null
              ? null
              : widget.assetStore.assets.firstWhere(
                  (element) => element.variableName == id,
                ),
          actions: [
            ElevatedButton(
              onPressed: () => addAsset(context),
              child: const Icon(
                Icons.add,
                semanticLabel: 'Add Asset',
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Add a new asset.
  Future<void> addAsset(BuildContext context) async {
    await pushWidget(
      context: context,
      builder: (context) => AddAsset(
        projectContext: widget.projectContext,
        assetStore: widget.assetStore,
      ),
    );
    setState(() {});
  }
}
