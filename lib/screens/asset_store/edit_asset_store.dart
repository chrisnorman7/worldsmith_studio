import 'dart:convert';
import 'dart:io';

import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
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
import 'import_directory.dart';

const _openProjectIntent = OpenProjectIntent();
const _importDirectoryIntent = ImportDirectoryIntent();

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
    final importDirectoryAction = CallbackAction<ImportDirectoryIntent>(
      onInvoke: (intent) async {
        await pushWidget(
          context: context,
          builder: (context) => ImportDirectory(
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
            actions: {
              OpenProjectIntent: addAssetAction,
              ImportDirectoryIntent: importDirectoryAction
            },
            child: Builder(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  actions: [
                    TextButton(
                      onPressed: Actions.handler<ImportDirectoryIntent>(
                        context,
                        _importDirectoryIntent,
                      ),
                      child: const Text('Import Directory'),
                    )
                  ],
                  title: Text('${widget.assetStore.comment}'),
                ),
                body: assets.isEmpty
                    ? const CenterText(
                        text: 'There are no assets in this store.')
                    : ListView.builder(
                        itemBuilder: (context, index) {
                          final assetReference = assets[index];
                          final relativeAssetReference =
                              assetReference.reference;
                          final String assetSize;
                          switch (assetReference.reference.type) {
                            case AssetType.file:
                              final file = File(
                                path.join(
                                  widget.projectContext.directory.path,
                                  assetReference.reference.name,
                                ),
                              );
                              assetSize = filesize(
                                file.statSync().size,
                              );
                              break;
                            case AssetType.collection:
                              final directory = Directory(
                                path.join(
                                  widget.projectContext.directory.path,
                                  relativeAssetReference.name,
                                ),
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
                          return Shortcuts(
                            child: Actions(
                              actions: {
                                DeleteIntent: CallbackAction<DeleteIntent>(
                                  onInvoke: (intent) {
                                    deleteAsset(
                                      assetReferenceReference: assetReference,
                                      context: context,
                                    );
                                    return null;
                                  },
                                ),
                                CopyAssetIntent:
                                    CallbackAction<CopyAssetIntent>(
                                  onInvoke: (intent) {
                                    final asset = assetReference.reference;
                                    final stringBuffer = StringBuffer()
                                      ..write('AssetReference(')
                                      ..write(jsonEncode(asset.name))
                                      ..write(', ${asset.type}, ')
                                      ..write('encryptionKey: ')
                                      ..write(jsonEncode(asset.encryptionKey))
                                      ..write(',)');
                                    setClipboardText(stringBuffer.toString());
                                    return null;
                                  },
                                )
                              },
                              child: PlaySoundSemantics(
                                child: Builder(
                                  builder: (context) => ListTile(
                                    autofocus: index == 0,
                                    title: Text(assetString(assetReference)),
                                    subtitle: Text(assetSize),
                                    onTap: () async {
                                      PlaySoundSemantics.of(context)!.stop();
                                      await pushWidget(
                                        context: context,
                                        builder: (context) =>
                                            EditAssetReference(
                                          projectContext: widget.projectContext,
                                          assetStore: widget.assetStore,
                                          assetReferenceReference:
                                              assetReference,
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
                              ),
                            ),
                            shortcuts: const {
                              DeleteIntent.hotkey: DeleteIntent(),
                              CopyAssetIntent.hotkey: CopyAssetIntent()
                            },
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
          shortcuts: const {
            OpenProjectIntent.hotkey: _openProjectIntent,
            ImportDirectoryIntent.hotkey: _importDirectoryIntent
          },
        ),
      ),
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Add a new asset',
          keyName: 'o',
          control: true,
        ),
        KeyboardShortcut(
          description: 'Import a directory as different assets',
          keyName: 'D',
          control: true,
        ),
        KeyboardShortcut(
          description: 'Delete the currently selected asset',
          keyName: 'Delete',
        ),
        KeyboardShortcut(
          description: 'Copy the dart of the current asset to the clipboard.',
          keyName: 'c',
          control: true,
        ),
      ],
    );
  }

  /// Delete the given [assetReferenceReference].
  void deleteAsset({
    required BuildContext context,
    required AssetReferenceReference assetReferenceReference,
  }) {
    final result = widget.canDelete(assetReferenceReference);
    if (result == null) {
      confirm(
        context: context,
        message: 'Are you sure you want to delete the '
            '${assetReferenceReference.comment} asset?',
        title: 'Delete Asset',
        yesCallback: () {
          Navigator.pop(context);
          widget.projectContext.deleteAssetReferenceReference(
            assetStore: widget.assetStore,
            assetReferenceReference: assetReferenceReference,
          );
          setState(() {});
        },
      );
    } else {
      showSnackBar(context: context, message: result);
    }
  }
}
