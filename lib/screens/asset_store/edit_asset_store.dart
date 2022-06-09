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
import '../../widgets/searchable_list_view.dart';
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
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The asset store to edit.
  final AssetStore assetStore;

  /// The function to call before deleting an asset.
  final CanDelete<AssetReferenceReference> canDelete;

  /// Create state for this widget.
  @override
  EditAssetStoreState createState() => EditAssetStoreState();
}

/// State for [EditAssetStore].
class EditAssetStoreState extends State<EditAssetStore> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final addAssetAction = CallbackAction<OpenProjectIntent>(
      onInvoke: (final intent) async {
        await pushWidget(
          context: context,
          builder: (final context) => AddAsset(
            projectContext: widget.projectContext,
            assetStore: widget.assetStore,
          ),
        );
        setState(() {});
        return null;
      },
    );
    final importDirectoryAction = CallbackAction<ImportDirectoryIntent>(
      onInvoke: (final intent) async {
        await pushWidget(
          context: context,
          builder: (final context) => ImportDirectory(
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
        (final a, final b) => a.comment.toString().toLowerCase().compareTo(
              b.comment.toString().toLowerCase(),
            ),
      );
    final children = <SearchableListTile>[];
    for (var i = 0; i < assets.length; i++) {
      final assetReference = assets[i];
      final relativeAssetReference = assetReference.reference;
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
            for (final file in directory.listSync().whereType<File>())
              file.statSync().size
          ];
          assetSize = filesize(
            fileSizes.reduce(
              (final value, final element) => value + element,
            ),
          );
          break;
      }
      children.add(
        SearchableListTile(
          searchString: assetReference.comment ?? assetReference.reference.name,
          child: Shortcuts(
            shortcuts: {
              DeleteIntent.hotkey: const DeleteIntent(),
              CopyIntent.hotkey: const CopyIntent()
            },
            child: Actions(
              actions: {
                DeleteIntent: CallbackAction<DeleteIntent>(
                  onInvoke: (final intent) {
                    deleteAsset(
                      assetReferenceReference: assetReference,
                      context: context,
                    );
                    return null;
                  },
                ),
                CopyIntent: CallbackAction<CopyIntent>(
                  onInvoke: (final intent) {
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
                soundChannel: widget.projectContext.game.interfaceSounds,
                assetReference: relativeAssetReference,
                looping: true,
                child: Builder(
                  builder: (final context) => ListTile(
                    autofocus: i == 0,
                    title: Text(assetString(assetReference)),
                    subtitle: Text(assetSize),
                    onTap: () async {
                      PlaySoundSemantics.of(context)!.stop();
                      await pushWidget(
                        context: context,
                        builder: (final context) => EditAssetReference(
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
              ),
            ),
          ),
        ),
      );
    }
    return WithKeyboardShortcuts(
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
      child: Cancel(
        child: Shortcuts(
          shortcuts: {
            OpenProjectIntent.hotkey: _openProjectIntent,
            ImportDirectoryIntent.hotkey: _importDirectoryIntent
          },
          child: Actions(
            actions: {
              OpenProjectIntent: addAssetAction,
              ImportDirectoryIntent: importDirectoryAction
            },
            child: Builder(
              builder: (final context) => Scaffold(
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
                        text: 'There are no assets in this store.',
                      )
                    : SearchableListView(children: children),
                floatingActionButton: FloatingActionButton(
                  autofocus: assets.isEmpty,
                  onPressed: Actions.handler<OpenProjectIntent>(
                    context,
                    _openProjectIntent,
                  ),
                  tooltip: 'Add Asset',
                  child: const Icon(Icons.add_outlined),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Delete the given [assetReferenceReference].
  void deleteAsset({
    required final BuildContext context,
    required final AssetReferenceReference assetReferenceReference,
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
      showError(context: context, message: result);
    }
  }
}
