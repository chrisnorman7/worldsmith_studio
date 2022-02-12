import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';

/// A widget for adding a new asset.
class AddAsset extends StatefulWidget {
  /// Create an instance.
  const AddAsset({
    required this.projectContext,
    required this.assetStore,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The asset store to import to.
  final AssetStore assetStore;

  /// Create state for this widget.
  @override
  _AddAssetState createState() => _AddAssetState();
}

/// State for [AddAsset].
class _AddAssetState extends State<AddAsset> {
  late final TextEditingController _pathController;
  late final TextEditingController _commentController;
  late final GlobalKey<FormState> _formKey;

  /// Create stuff.
  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>(debugLabel: 'Add Asset form');
    _pathController = TextEditingController();
    _commentController = TextEditingController();
  }

  /// Build a widget.
  @override
  Widget build(BuildContext context) => Cancel(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Add Asset'),
          ),
          body: Form(
            child: Column(
              children: [
                TextFormField(
                  autofocus: true,
                  controller: _pathController,
                  decoration: const InputDecoration(
                    labelText: 'Path',
                    hintText: 'Enter the path to a file or folder',
                  ),
                  onChanged: (value) =>
                      _commentController.text = path.basenameWithoutExtension(
                    value,
                  ),
                  validator: (value) => validatePath(value: value),
                ),
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: 'Comment',
                    hintText:
                        'Enter a human-readable description for this asset',
                  ),
                  validator: (value) => validateNonEmptyValue(value: value),
                )
              ],
            ),
            key: _formKey,
          ),
          floatingActionButton: FloatingActionButton(
            child: saveIcon,
            onPressed: () => submitForm(context),
          ),
        ),
      );

  /// Dispose of the controllers.
  @override
  void dispose() {
    super.dispose();
    _pathController.dispose();
    _commentController.dispose();
  }

  /// Submit the form.
  void submitForm(BuildContext context) {
    if (_formKey.currentState?.validate() == true) {
      final id = newId();
      final filename = _pathController.text;
      final comment = _commentController.text;
      final file = File(filename);
      final directory = Directory(filename);
      if (file.existsSync()) {
        widget.assetStore.importFile(
          source: file,
          variableName: id,
          comment: comment,
          relativeTo: widget.projectContext.directory,
        );
      } else if (directory.existsSync()) {
        widget.assetStore.importDirectory(
          source: directory,
          variableName: id,
          comment: comment,
          relativeTo: widget.projectContext.directory,
        );
      } else {
        throw StateError('Cannot handle $filename.');
      }
      widget.projectContext.save();
      Navigator.pop(context);
    }
  }
}
