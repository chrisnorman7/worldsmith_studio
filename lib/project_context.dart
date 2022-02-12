import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/ziggurat.dart';

import 'constants.dart';

/// A class to hold information about the current project.
class ProjectContext {
  /// Create an instance.
  ProjectContext({
    required this.file,
    required this.world,
    required this.game,
  });

  /// Load a project from the given [file].
  ProjectContext.fromFile({required this.file, required this.game})
      : world = World.fromJson(jsonDecode(file.readAsStringSync()) as JsonType);

  /// The filename that [world] has been loaded from.
  final File file;

  /// The directory where project files are stored.
  Directory get directory => file.parent;

  /// The world that has been loaded.
  World world;

  /// The game to use for creating stuff.
  final Game game;

  /// Save the [world].
  void save() {
    final dirname = path.dirname(file.path);
    final json = world.toJson();
    final data = indentedJsonEncoder.convert(json);
    file.writeAsStringSync(data);
    for (final assetStore in [
      world.creditsAssetStore,
      world.equipmentAssetStore,
      world.interfaceSoundsAssetStore,
      world.musicAssetStore,
      world.terrainAssetStore,
    ]) {
      final directory = Directory(path.join(dirname, assetStore.destination));
      if (directory.existsSync() == false) {
        directory.createSync(recursive: true);
      }
    }
  }

  /// Convert the given [assetReference] to have a relative filename.
  AssetReference getRelativeAssetReference(AssetReference assetReference) =>
      AssetReference(
        path.join(directory.path, assetReference.name),
        assetReference.type,
        encryptionKey: assetReference.encryptionKey,
      );
}
