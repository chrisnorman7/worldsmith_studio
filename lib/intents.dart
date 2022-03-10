/// Provides the various intent classes used throughout the program, along with
/// their assorted hotkeys.
import 'dart:io';

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
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.keyN,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}

/// The intent to open a project.
class OpenProjectIntent extends Intent {
  /// Create an instance.
  const OpenProjectIntent();

  /// The hotkey to use.
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.keyO,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}

/// Close the current project and return to the main menu.
class CloseProjectIntent extends Intent {
  /// Create an instance.
  const CloseProjectIntent();

  /// The hotkey to use.
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.keyW,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}

/// Play or pause something.
class PlayPauseIntent extends Intent {
  /// Create an instance.
  const PlayPauseIntent();

  /// The hotkey to use.
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.keyP,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
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
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.slash,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}

/// The intent to import a directory.
class ImportDirectoryIntent extends Intent {
  /// Create an instance.
  const ImportDirectoryIntent();

  /// The hotkey to use.
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.keyD,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}

/// An intent to import a single file.
class ImportFileIntent extends Intent {
  /// Create an instance.
  const ImportFileIntent();

  /// The hotkey to use.
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.keyF,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
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
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.keyC,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}

/// An intent to create a new box.
class CreateBoxIntent extends Intent {
  /// Create an instance.
  const CreateBoxIntent();

  /// The hotkey to use.
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.keyN,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}

/// An intent to go to the next box.
class NextBoxIntent extends Intent {
  /// Create an instance.
  const NextBoxIntent();

  /// The hotkey to use.
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.period,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}

/// An intent to go to the previous box.
class PreviousBoxIntent extends Intent {
  /// Create an instance.
  const PreviousBoxIntent();

  /// The hotkey to use.
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.comma,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}

/// An intent to create a new equipment position.
class CreateEquipmentPositionIntent extends Intent {
  /// Create an instance.
  const CreateEquipmentPositionIntent();

  /// The hotkey to use.
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.keyN,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}

/// An intent to move something up.
class MoveUpIntent extends Intent {
  /// Create an instance.
  const MoveUpIntent();

  /// The hotkey to use.
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.arrowUp,
    alt: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}

/// An intent to move something down.
class MoveDownIntent extends Intent {
  /// Create an instance.
  const MoveDownIntent();

  /// The hotkey to use.
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.arrowDown,
    alt: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}

/// The intent to rename something.
class RenameIntent extends Intent {
  /// Create an instance.
  const RenameIntent();

  /// The hotkey to use.
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.keyR,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}

/// The intent to create a zone object.
class CreateZoneObjectIntent extends Intent {
  /// Create an instance.
  const CreateZoneObjectIntent();

  /// The hotkey to use.
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.keyN,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}

/// The intent to add a new ambiance.
class AddAmbianceIntent extends Intent {
  /// Create an instance.
  const AddAmbianceIntent();

  /// The hotkey to use.
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.keyN,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}

/// An intent to open the manual.
class LaunchManualIntent extends Intent {
  /// Create an instance.
  const LaunchManualIntent();

  /// The hotkey to use.
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.slash,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
    shift: true,
  );
}

/// An intent to search for something.
class SearchIntent extends Intent {
  /// Create an instance.
  const SearchIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(LogicalKeyboardKey.slash);
}

/// An intent to edit conversation categories.
class EditConversationCategoriesIntent extends Intent {
  /// Create an instance.
  const EditConversationCategoriesIntent();

  /// The hotkey to use.
  static final hotkey = SingleActivator(
    LogicalKeyboardKey.keyC,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
    shift: true,
  );
}

/// An intent to create a new conversation branch.
class CreateConversationBranchIntent extends Intent {
  /// Create an instance.
  const CreateConversationBranchIntent();

  /// The hotkey to use.
  static SingleActivator hotkey = SingleActivator(
    LogicalKeyboardKey.keyN,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}

/// An intent to create a new conversation response.
class CreateConversationResponse extends Intent {
  /// Create an instance.
  const CreateConversationResponse();

  /// The hotkey to use.
  static SingleActivator hotkey = SingleActivator(
    LogicalKeyboardKey.keyN,
    control: Platform.isWindows,
    meta: Platform.isMacOS,
  );
}
