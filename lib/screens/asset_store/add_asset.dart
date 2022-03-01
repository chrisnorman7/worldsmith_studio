import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/keyboard_shortcuts_list.dart';

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
  Widget build(BuildContext context) {
    final importFileAction = CallbackAction<ImportFileIntent>(
      onInvoke: (intent) => importFile(context),
    );
    final importDirectoryAction = CallbackAction<ImportDirectoryIntent>(
      onInvoke: (intent) => importDirectory(context),
    );
    return WithKeyboardShortcuts(
      child: Shortcuts(
        child: Actions(
          actions: {
            ImportFileIntent: importFileAction,
            ImportDirectoryIntent: importDirectoryAction
          },
          child: Cancel(
            child: Scaffold(
              appBar: AppBar(
                actions: [
                  ElevatedButton(
                    onPressed: () => importDirectory(context),
                    child: const Icon(
                      Icons.file_open_outlined,
                      semanticLabel: 'Import Directory',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => importFile(context),
                    child: const Icon(
                      Icons.file_open,
                      semanticLabel: 'Import File',
                    ),
                  )
                ],
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
                      onChanged: (value) => _commentController.text =
                          path.basenameWithoutExtension(
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
          ),
        ),
        shortcuts: const {
          ImportFileIntent.hotkey: ImportFileIntent(),
          ImportDirectoryIntent.hotkey: ImportDirectoryIntent()
        },
      ),
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Import a single file.',
          keyName: 'F',
          control: true,
        ),
        KeyboardShortcut(
          description: 'Import a directory.',
          keyName: 'D',
          control: true,
        )
      ],
    );
  }

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

  /// Import a file.
  Future<void> importFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Choose File',
    );
    if (result == null) {
      return;
    }
    final filename = result.paths.single;
    final file = File(filename!);
    if (file.existsSync() == false) {
      return showSnackBar(
        context: context,
        message: 'The file $filename does not exist.',
      );
    }
    setState(() {
      _pathController.text = filename;
      _commentController.text = path.basenameWithoutExtension(filename);
    });
  }

  /// Import a directory.
  Future<void> importDirectory(BuildContext context) async {
    final directoryName = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Directory',
    );
    if (directoryName == null) {
      return;
    }
    if (Directory(directoryName).existsSync() == false) {
      return showSnackBar(
        context: context,
        message: 'The directory $directoryName does not exist.',
      );
    }
    setState(() {
      _pathController.text = directoryName;
      _commentController.text = path.basename(directoryName);
    });
  }
}
