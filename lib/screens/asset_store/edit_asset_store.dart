import 'dart:io';

import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:ziggurat/ziggurat.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/play_sound_semantics.dart';
import 'add_asset.dart';
import 'edit_asset_reference.dart';

const _openProjectIntent = OpenProjectIntent();

/// A Widget for editing an [AssetStore] instance.
class EditAssetStore extends StatefulWidget {
  /// Create an instance.
  const EditAssetStore({
    required this.projectContext,
    required this.assetStore,
    required this.canDelete,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The asset store to edit.
  final AssetStore assetStore;

  /// The function to call before deleting an asset.
  final CanDelete<AssetReferenceReference> canDelete;

  /// Create state for this widget.
  @override
  _EditAssetStoreState createState() => _EditAssetStoreState();
}

/// State for [EditAssetStore].
class _EditAssetStoreState extends State<EditAssetStore> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final addAssetAction = CallbackAction<OpenProjectIntent>(
      onInvoke: (intent) async {
        await pushWidget(
          context: context,
          builder: (context) => AddAsset(
            projectContext: widget.projectContext,
            assetStore: widget.assetStore,
          ),
        );
        setState(() {});
        return null;
      },
    );
    final assets = [for (final reference in widget.assetStore.assets) reference]
      ..sort(
        (a, b) => a.comment.toString().toLowerCase().compareTo(
              b.comment.toString().toLowerCase(),
            ),
      );
    return WithKeyboardShortcuts(
      child: Cancel(
        child: Shortcuts(
          child: Actions(
            actions: {OpenProjectIntent: addAssetAction},
            child: Builder(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: Text('${widget.assetStore.comment}'),
                ),
                body: assets.isEmpty
                    ? const CenterText(
                        text: 'There are no assets in this store.')
                    : ListView.builder(
                        itemBuilder: (context, index) {
                          final assetReference = assets[index];
                          final relativeAssetReference =
                              widget.projectContext.getRelativeAssetReference(
                            assetReference.reference,
                          );
                          final String assetSize;
                          switch (assetReference.reference.type) {
                            case AssetType.file:
                              assetSize = filesize(
                                relativeAssetReference
                                    .getFile(widget.projectContext.game.random)
                                    .statSync()
                                    .size,
                              );
                              break;
                            case AssetType.collection:
                              final directory = Directory(
                                relativeAssetReference.name,
                              );
                              final fileSizes = [
                                for (final file
                                    in directory.listSync().whereType<File>())
                                  file.statSync().size
                              ];
                              assetSize = filesize(
                                fileSizes.reduce(
                                  (value, element) => value + element,
                                ),
                              );
                              break;
                          }
                          return PlaySoundSemantics(
                            child: Builder(
                              builder: (context) => ListTile(
                                autofocus: index == 0,
                                title: Text(assetString(assetReference)),
                                subtitle: Text(assetSize),
                                onTap: () async {
                                  PlaySoundSemantics.of(context)!.stop();
                                  await pushWidget(
                                    context: context,
                                    builder: (context) => EditAssetReference(
                                      projectContext: widget.projectContext,
                                      assetStore: widget.assetStore,
                                      assetReferenceReference: assetReference,
                                      canDelete: widget.canDelete,
                                    ),
                                  );
                                  setState(() {});
                                },
                              ),
                            ),
                            soundChannel:
                                widget.projectContext.game.interfaceSounds,
                            assetReference: relativeAssetReference,
                            looping: true,
                          );
                        },
                        itemCount: assets.length,
                      ),
                floatingActionButton: FloatingActionButton(
                  autofocus: assets.isEmpty,
                  child: const Icon(Icons.add_outlined),
                  onPressed: Actions.handler<OpenProjectIntent>(
                    context,
                    _openProjectIntent,
                  ),
                  tooltip: 'Add Asset',
                ),
              ),
            ),
          ),
          shortcuts: const {OpenProjectIntent.hotkey: _openProjectIntent},
        ),
      ),
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Add a new asset',
          keyName: 'o',
          control: true,
        )
      ],
    );
  }
}
