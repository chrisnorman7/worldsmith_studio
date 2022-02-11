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

/// The intent to rename a project.
class RenameProjectIntent extends Intent {
  /// Create an instance.
  const RenameProjectIntent();

  /// The hotkey.
  static const hotkey = SingleActivator(LogicalKeyboardKey.keyR, control: true);
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

/// The open recent project intent.
class OpenRecentProjectIntent extends Intent {
  /// Create an instance.
  const OpenRecentProjectIntent();

  /// The hotkey to use.
  static const hotkey =
      SingleActivator(LogicalKeyboardKey.keyO, control: true, shift: true);
}

/// Close the current project and return to the main menu.
class CloseProjectIntent extends Intent {
  /// Create an instance.
  const CloseProjectIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(LogicalKeyboardKey.keyW, control: true);
}

/// Go up the directory tree.
class UpDirectoryTreeIntent extends Intent {
  /// Create an instance.
  const UpDirectoryTreeIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(LogicalKeyboardKey.backspace);
}

/// Move to the first tab.
class FirstTabIntent extends Intent {
  /// Create an instance.
  const FirstTabIntent();

  /// The hotkey to use.
  static const hotkey =
      SingleActivator(LogicalKeyboardKey.digit1, control: true);
}

/// Move to the second tab.
class SecondTabIntent extends Intent {
  /// Create an instance.
  const SecondTabIntent();

  /// The hotkey to use.
  static const hotkey =
      SingleActivator(LogicalKeyboardKey.digit2, control: true);
}

/// Move to the third tab.
class ThirdTabIntent extends Intent {
  /// Create an instance.
  const ThirdTabIntent();

  /// The hotkey to use.
  static const hotkey =
      SingleActivator(LogicalKeyboardKey.digit3, control: true);
}

/// Move to the fourth tab.
class FourthTabIntent extends Intent {
  /// Create an instance.
  const FourthTabIntent();

  /// The hotkey to use.
  static const hotkey =
      SingleActivator(LogicalKeyboardKey.digit4, control: true);
}

/// Move to the fifth tab.
class FifthTabIntent extends Intent {
  /// Create an instance.
  const FifthTabIntent();

  /// The hotkey to use.
  static const hotkey =
      SingleActivator(LogicalKeyboardKey.digit5, control: true);
}

/// Move to the sixth tab.
class SixthTabIntent extends Intent {
  /// Create an instance.
  const SixthTabIntent();

  /// The hotkey to use.
  static const hotkey =
      SingleActivator(LogicalKeyboardKey.digit6, control: true);
}

/// Move to the seventh tab.
class SeventhTabIntent extends Intent {
  /// Create an instance.
  const SeventhTabIntent();

  /// The hotkey to use.
  static const hotkey =
      SingleActivator(LogicalKeyboardKey.digit7, control: true);
}

/// Move to the eighth tab.
class EighthTabIntent extends Intent {
  /// Create an instance.
  const EighthTabIntent();

  /// The hotkey to use.
  static const hotkey =
      SingleActivator(LogicalKeyboardKey.digit8, control: true);
}

/// Move to the ninth tab.
class NinthTabIntent extends Intent {
  /// Create an instance.
  const NinthTabIntent();

  /// The hotkey to use.
  static const hotkey =
      SingleActivator(LogicalKeyboardKey.digit9, control: true);
}

/// Move to the tenth tab.
class TenthTabIntent extends Intent {
  /// Create an instance.
  const TenthTabIntent();

  /// The hotkey to use.
  static const hotkey =
      SingleActivator(LogicalKeyboardKey.digit0, control: true);
}

/// The intent to rename a level stub reference.
class RenameLevelStubReferenceIntent extends Intent {
  /// Create an instance.
  const RenameLevelStubReferenceIntent();

  /// The hotkey to use.
  static const hotkey = SingleActivator(LogicalKeyboardKey.keyR, control: true);
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
