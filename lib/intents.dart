/// Provides the various intent classes used throughout the program, along with
/// their assorted hotkeys.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Move directions.
enum MoveDirections {
  /// 0 degrees.
  north,

  /// 90 degrees.
  east,

  /// 180 degrees.
  south,

  /// 270 degrees.
  west,
}

/// Cancel something.
class CancelIntent extends Intent {
  /// Create an instance.
  const CancelIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(LogicalKeyboardKey.escape);
}

/// The intent to create a new project.
class CreateProjectIntent extends Intent {
  /// Create an instance.
  const CreateProjectIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(LogicalKeyboardKey.keyN, control: true);
}

/// The intent to open a project.
class OpenProjectIntent extends Intent {
  /// Create an instance.
  const OpenProjectIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(LogicalKeyboardKey.keyO, control: true);
}

/// Close the current project and return to the main menu.
class CloseProjectIntent extends Intent {
  /// Create an instance.
  const CloseProjectIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(LogicalKeyboardKey.keyW, control: true);
}

/// Play or pause something.
class PlayPauseIntent extends Intent {
  /// Create an instance.
  const PlayPauseIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(LogicalKeyboardKey.keyP, control: true);
}

/// Increase something.
class IncreaseIntent extends Intent {
  /// Create an instance.
  const IncreaseIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(LogicalKeyboardKey.equal);
}

/// Decrease something.
class DecreaseIntent extends Intent {
  /// Create an instance.
  const DecreaseIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(LogicalKeyboardKey.minus);
}

/// An intent to move within a zone.
class MoveIntent extends Intent {
  /// Create an instance.
  const MoveIntent(this.direction);

  /// The direction to move in.
  final MoveDirections direction;
}

/// An intent to get help.
class HelpIntent extends Intent {
  /// Create an instance.
  const HelpIntent();

  /// The hotkey to use.
  static const hotkey =
      SingleActivator(LogicalKeyboardKey.slash, control: true);
}

/// The intent to import a directory.
class ImportDirectoryIntent extends Intent {
  /// Create an instance.
  const ImportDirectoryIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(LogicalKeyboardKey.keyI, control: true);
}

/// An intent to delete something.
class DeleteIntent extends Intent {
  /// Create an instance.
  const DeleteIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(LogicalKeyboardKey.delete);
}

/// An intent to copy the given assetReference to the clipboard.
class CopyAssetIntent extends Intent {
  /// Create an instance.
  const CopyAssetIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(LogicalKeyboardKey.keyC, control: true);
}

/// An intent to create a new box.
class CreateBoxIntent extends Intent {
  /// Create an instance.
  const CreateBoxIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(LogicalKeyboardKey.keyN, control: true);
}

/// An intent to go to the next box.
class NextBoxIntent extends Intent {
  /// Create an instance.
  const NextBoxIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(
    LogicalKeyboardKey.period,
    control: true,
  );
}

/// An intent to go to the previous box.
class PreviousBoxIntent extends Intent {
  /// Create an instance.
  const PreviousBoxIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(
    LogicalKeyboardKey.comma,
    control: true,
  );
}
