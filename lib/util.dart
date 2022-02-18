import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import 'constants.dart';

/// Push the result of the given [builder] onto the stack.
Future<void> pushWidget({
  required BuildContext context,
  required WidgetBuilder builder,
}) =>
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: builder,
      ),
    );

/// Generate a new ID.
String newId() => shortUuid.generate();

/// Returns a newly formed asset store.
AssetStore createAssetStore({required String name, required String comment}) =>
    AssetStore(
      filename: '$name.dart',
      destination: path.join(assetsPath, name),
      assets: [],
      comment: comment,
    );

/// Confirm something.
Future<void> confirm({
  required BuildContext context,
  String title = 'Confirm',
  String message = 'Are you sure?',
  VoidCallback? yesCallback,
  VoidCallback? noCallback,
  String yesLabel = 'Yes',
  String noLabel = 'No',
}) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            autofocus: true,
            onPressed: yesCallback ?? () => Navigator.pop(context),
            child: Text(yesLabel),
          ),
          ElevatedButton(
            onPressed: noCallback ?? () => Navigator.pop(context),
            child: Text(noLabel),
          )
        ],
      ),
    );

/// Show a snackbar, with an optional action.
void showSnackBar({
  required BuildContext context,
  required String message,
  String? actionLabel,
  VoidCallback? actionCallback,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: actionLabel != null && actionCallback != null
          ? SnackBarAction(
              label: actionLabel,
              onPressed: actionCallback,
            )
          : null,
    ),
  );
}

/// Make a printable string from the given [assetReferenceReference].
String assetString(AssetReferenceReference assetReferenceReference) =>
    '${assetReferenceReference.comment} '
    '(${assetReferenceReference.reference.type.name})';

/// Copy the given [text] to the [Clipboard].
void setClipboardText(String text) {
  final data = ClipboardData(text: text);
  Clipboard.setData(data);
}
