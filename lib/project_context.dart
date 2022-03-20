import 'dart:io';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
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
    required this.sdl,
    required this.audioContext,
  });

  /// Load a project from the given [file].
  ProjectContext.fromFile({
    required this.file,
    required this.game,
    required this.sdl,
    required this.audioContext,
  }) : world = World.fromFilename(file.path);

  /// The filename that [world] has been loaded from.
  final File file;

  /// The directory where project files are stored.
  Directory get directory => file.parent;

  /// The world that has been loaded.
  final World world;

  /// The game to use for creating stuff.
  final Game game;

  /// The sdl instance to use.
  final Sdl sdl;

  /// The synthizer context to use.
  final Context audioContext;

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

  /// Delete the given [assetReferenceReference] from the given [assetStore].
  void deleteAssetReferenceReference(
      {required AssetStore assetStore,
      required AssetReferenceReference assetReferenceReference}) {
    assetStore.assets.remove(assetReferenceReference);
    save();
    final reference = assetReferenceReference.reference;
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
  void playActivateSound({double? gain}) {
    final activateSound = world.menuActivateSound;
    if (activateSound != null) {
      game.interfaceSounds.playSound(
        activateSound,
        gain: gain ??
            world.soundOptions.menuActivateSound?.gain ??
            world.soundOptions.defaultGain,
      );
    }
  }

  /// Get a play sound semantics widget which will play the [world]'s
  /// `menuMoveSound`.
  PlaySoundSemantics getMenuMoveSemantics({
    required Widget child,
    CustomSound? sound,
  }) {
    final defaultGain = sound?.gain ??
        world.soundOptions.menuMoveSound?.gain ??
        world.soundOptions.defaultGain;
    AssetReference? assetReference;
    if (sound != null) {
      assetReference = worldContext.getCustomSound(sound);
    } else {
      assetReference = world.menuMoveSound;
    }
    return PlaySoundSemantics(
      soundChannel: game.interfaceSounds,
      assetReference: assetReference,
      gain: world.pauseMenuOptions.music?.gain ?? defaultGain,
      child: child,
    );
  }

  WorldContext? _worldContext;

  /// Get a world context.
  WorldContext get worldContext {
    final value = _worldContext;
    if (value == null) {
      final context = WorldContext(
        game: game,
        world: world,
        sdl: sdl,
      );
      _worldContext = context;
      for (var i = 0; i < sdl.numJoysticks; i++) {
        sdl.openJoystick(i);
      }
      for (var i = 0; i < sdl.numHaptics; i++) {
        final haptic = sdl.openHaptic(i)..init();
        context.hapticDevices.add(haptic);
      }
      return context;
    }
    return value;
  }
}
