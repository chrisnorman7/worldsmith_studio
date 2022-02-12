import 'package:flutter/material.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';

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

  /// Create state for this widget.
  @override
  _SelectAssetState createState() => _SelectAssetState();
}

/// State for [SelectAsset].
class _SelectAssetState extends State<SelectAsset> {
  PlaySound? _playSound;

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final assets = <AssetReferenceReference?>[];
    if (widget.nullable == true) {
      assets.add(null);
    }
    assets.addAll(widget.assetStore.assets);
    final selectedAsset = assets.firstWhere(
      (element) => element?.variableName == widget.currentId,
      orElse: () => assets.first,
    );
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            final asset = assets[index];
            if (asset == null) {
              return ListTile(
                title: const Text('Clear'),
                onTap: () {
                  _playSound?.destroy();
                  _playSound = null;
                  widget.onDone(null);
                },
              );
            }
            return Semantics(
              child: ListTile(
                autofocus: asset == selectedAsset,
                title: Text(assetString(asset)),
                selected: asset.variableName == widget.currentId,
                onTap: () {
                  _playSound?.destroy();
                  _playSound = null;
                  widget.onDone(asset);
                },
              ),
              onDidGainAccessibilityFocus: () {
                _playSound?.destroy();
                _playSound =
                    widget.projectContext.game.interfaceSounds.playSound(
                  widget.projectContext.getRelativeAssetReference(
                    asset.reference,
                  ),
                  keepAlive: true,
                );
              },
              onDidLoseAccessibilityFocus: () {
                _playSound?.destroy();
                _playSound = null;
              },
            );
          },
          itemCount: assets.length,
        ),
      ),
    );
  }

  /// Stop the playing sound.
  @override
  void dispose() {
    super.dispose();
    _playSound?.destroy();
    _playSound = null;
  }
}
