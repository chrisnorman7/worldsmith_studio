/// Provides the various intent classes used throughout the program, along with
/// their assorted hotkeys.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

/// Build a project.
class BuildProjectIntent extends Intent {
  /// Create an instance.
  const BuildProjectIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(LogicalKeyboardKey.keyB, control: true);
}
