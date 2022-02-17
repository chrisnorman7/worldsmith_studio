import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:worldsmith/functions.dart';
import 'package:worldsmith/world_context.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/ziggurat.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import 'constants.dart';
import 'widgets/play_sound_semantics.dart';

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

  /// Delete the given [assetReferenceReference] from the given [assetStore].
  void deleteAssetReferenceReference(
      {required AssetStore assetStore,
      required AssetReferenceReference assetReferenceReference}) {
    assetStore.assets.remove(assetReferenceReference);
    save();
    final reference = getRelativeAssetReference(
      assetReferenceReference.reference,
    );
    switch (reference.type) {
      case AssetType.file:
        final file = File(reference.name);
        if (file.existsSync() == true) {
          file.deleteSync(recursive: true);
        }
        break;
      case AssetType.collection:
        final directory = Directory(reference.name);
        if (directory.existsSync() == true) {
          directory.deleteSync(recursive: true);
        }
        break;
    }
  }

  /// Play the menu activate sound.
  void playActivateSound() {
    final activateSound = world.menuActivateSound;
    if (activateSound != null) {
      final sound = getRelativeAssetReference(
        activateSound,
      );
      game.interfaceSounds.playSound(
        sound,
        gain: world.soundOptions.menuActivateSound?.gain ??
            world.soundOptions.defaultGain,
      );
    }
  }

  /// Get the proper menu move sound.
  /// The value from the [world] will be passed through
  /// [getRelativeAssetReference].
  AssetReference? get menuMoveSound {
    final reference = world.menuMoveSound;
    if (reference != null) {
      return getRelativeAssetReference(reference);
    }
    return null;
  }

  /// Get a play sound semantics widget which will play the [menuMoveSound].
  PlaySoundSemantics getMenuMoveSemantics({required Widget child}) {
    final defaultGain = world.soundOptions.defaultGain;
    return PlaySoundSemantics(
      child: child,
      soundChannel: game.interfaceSounds,
      assetReference: menuMoveSound,
      gain: world.pauseMenuOptions.music?.gain ?? defaultGain,
    );
  }

  /// Get a world context.
  WorldContext get worldContext => WorldContext(game: game, world: world);
}
