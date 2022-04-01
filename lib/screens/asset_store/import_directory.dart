import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:ziggurat/ziggurat.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/play_sound_semantics.dart';

/// A widget for importing an entire directory of assets into the given
/// [assetStore].
class ImportDirectory extends StatefulWidget {
  /// Create an instance.
  const ImportDirectory({
    required this.projectContext,
    required this.assetStore,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The asset store to import into.
  final AssetStore assetStore;

  /// Create state for this widget.
  @override
  ImportDirectoryState createState() => ImportDirectoryState();
}

/// State for [ImportDirectory].
class ImportDirectoryState extends State<ImportDirectory> {
  Directory? _directory;
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _controller;

  /// The assets to be imported.
  late final List<FileSystemEntity> entities;

  /// Initialise form stuff.
  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _controller = TextEditingController();
    entities = [];
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final directory = _directory;
    final String title;
    final Widget child;
    final FloatingActionButton floatingActionButton;
    if (directory == null) {
      title = 'Select Directory';
      child = Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              autofocus: true,
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Directory Name',
              ),
              validator: (final value) {
                if (value == null || value.isEmpty) {
                  return 'You must enter a path.';
                }
                final directory = Directory(value);
                if (directory.existsSync() == false) {
                  return 'Directory does not exist.';
                }
                if (directory.listSync().isEmpty) {
                  return 'There are no assets that can be imported.';
                }
                return null;
              },
              onFieldSubmitted: (final value) => submitForm,
            )
          ],
        ),
      );
      floatingActionButton = FloatingActionButton(
        onPressed: submitForm,
        tooltip: 'Next',
        child: const Icon(Icons.navigate_next_outlined),
      );
    } else {
      title = 'Confirm Assets';
      if (entities.isEmpty) {
        child = const CenterText(text: 'There are no assets to import.');
        floatingActionButton = FloatingActionButton(
          autofocus: true,
          onPressed: () => Navigator.pop(context),
          tooltip: 'Close',
          child: const Icon(Icons.close_outlined),
        );
      } else {
        child = ListView.builder(
          itemBuilder: (final context, final index) {
            final entity = entities[index];
            final title = path.basename(entity.path);
            final String subtitle;
            if (widget.assetStore.assets
                .where((final element) => element.comment == title)
                .isNotEmpty) {
              subtitle = 'Duplicate';
            } else if (entity is File) {
              subtitle = 'File';
            } else if (entity is Directory) {
              subtitle = 'Directory';
            } else {
              subtitle = '!! UNKNOWN !!';
            }
            return PlaySoundSemantics(
              soundChannel: widget.projectContext.game.interfaceSounds,
              assetReference: AssetReference(
                entity.path,
                entity is File ? AssetType.file : AssetType.collection,
              ),
              gain: widget.projectContext.world.soundOptions.defaultGain,
              child: ListTile(
                autofocus: index == 0,
                title: Text(title),
                subtitle: Text('($subtitle)'),
                onTap: () => setState(
                  () => entities.removeWhere(
                    (final element) => element.path == entity.path,
                  ),
                ),
              ),
            );
          },
          itemCount: entities.length,
        );
        floatingActionButton = FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
            for (final entity in entities) {
              final id = newId();
              final comment = path.basename(entity.path);
              if (widget.assetStore.assets
                  .where(
                    (final element) => element.comment == comment,
                  )
                  .isNotEmpty) {
                continue;
              }
              if (entity is File) {
                widget.assetStore.importFile(
                  source: entity,
                  variableName: id,
                  comment: comment,
                  relativeTo: widget.projectContext.directory,
                );
              } else if (entity is Directory) {
                widget.assetStore.importDirectory(
                  source: entity,
                  variableName: id,
                  comment: comment,
                  relativeTo: widget.projectContext.directory,
                );
              }
            }
            widget.projectContext.save();
          },
          tooltip: 'Done',
          child: const Icon(Icons.done_outline),
        );
      }
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: child,
        floatingActionButton: floatingActionButton,
      ),
    );
  }

  /// Submit the form.
  void submitForm() {
    if (_formKey.currentState?.validate() ?? true) {
      setState(() {
        final directory = Directory(_controller.text);
        for (final entity in directory.listSync()) {
          if (entity is File || entity is Directory) {
            entities.add(entity);
          }
        }
        _directory = directory;
      });
    }
  }

  /// Dispose of the controller.
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
