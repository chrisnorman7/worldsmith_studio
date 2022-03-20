import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import 'constants.dart';
import 'src/json/git_tag.dart';

/// Round the given [value] to the given number of decimal [places].
///
/// This code copied and modified from[here](https://www.bezkoder.com/dart-round-double/#:~:text=Dart%20round%20double%20to%20N%20decimal%20places,-We%20have%202&text=%E2%80%93%20Multiply%20the%20number%20by%2010,12.3412%20*%2010%5E2%20%3D%201234.12).
double roundDouble(double value, {int places = 2}) {
  final mod = pow(10.0, places);
  return (value * mod).round().toDouble() / mod;
}

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
void showError({
  required BuildContext context,
  required String message,
  String title = 'Error',
}) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            autofocus: true,
            child: const Text('OK'),
          )
        ],
        title: Text(title),
        content: Text(message),
      ),
    );

/// Make a printable string from the given [assetReferenceReference].
String assetString(AssetReferenceReference assetReferenceReference) =>
    '${assetReferenceReference.comment} '
    '(${assetReferenceReference.reference.type.name})';

/// Copy the given [text] to the [Clipboard].
void setClipboardText(String text) {
  final data = ClipboardData(text: text);
  Clipboard.setData(data);
}

/// Delete the given [equipmentPosition].
void deleteEquipmentPosition({
  required BuildContext context,
  required EquipmentPosition equipmentPosition,
  required World world,
  required VoidCallback onDone,
}) =>
    confirm(
      context: context,
      message: 'Are you sure you want to delete the ${equipmentPosition.name} '
          'equipment position?',
      title: 'Delete Equipment Position',
      yesCallback: () {
        Navigator.pop(context);
        world.equipmentPositions.removeWhere(
          (element) => element.id == equipmentPosition.id,
        );
        onDone();
      },
    );

/// Launch the manual.
void launchManual() => launch(manualUrl);

/// Report an issue.
void launchReportIssue() {
  final uri = Uri(
    host: 'github.com',
    pathSegments: ['chrisnorman7', 'worldsmith_studio', 'issues', 'new'],
    queryParameters: <String, String>{
      'body': '\n\n\nDart Version: ${Platform.version}\n'
          'Application Version: $appName $appVersion\n'
          'Operating System: ${Platform.operatingSystemVersion}.\n'
          'Locale Name: ${Platform.localeName}\n'
          'Working Directory: ${Directory.current.path}'
    },
    scheme: 'https',
  );
  launch(uri.toString());
}

/// Get the latest tag from GitHub.
Future<GitTag> getLatestTag() async {
  const url =
      'https://api.github.com/repos/chrisnorman7/worldsmith_studio/tags';
  final dio = Dio();
  final response = await dio.get<List<dynamic>>(url);
  final data = response.data;
  if (data == null || data.isEmpty) {
    throw StateError('No tags found.');
  }
  final datum = data.first as Map<String, dynamic>;
  final tag = GitTag.fromJson(datum);
  return tag;
}
