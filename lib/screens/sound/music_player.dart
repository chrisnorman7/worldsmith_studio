import 'dart:async';

import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

/// A class that holds musical information.
class MusicPlayer {
  /// Create an instance.
  MusicPlayer({
    required this.channel,
    required AssetReference assetReference,
    required double gain,
    required this.fadeBuilder,
  })  : _assetReference = assetReference,
        _gain = gain;

  /// The sound channel to play through.
  final SoundChannel channel;

  /// The asset reference to use.
  AssetReference _assetReference;

  /// The current asset reference.
  AssetReference get assetReference => _assetReference;

  /// Set the current [assetReference].
  set assetReference(AssetReference value) {
    final current = _assetReference;
    if (value.name != current.name ||
        value.type != current.type ||
        value.encryptionKey != current.encryptionKey) {
      _assetReference = value;
      _playSound?.destroy();
      play();
    }
  }

  /// The sound gain.
  double _gain;

  /// Get the current gain.
  double get gain => _gain;

  /// Set the current [gain].
  set gain(double value) {
    _gain = value;
    _playSound?.gain = value;
  }

  /// A function that should return a suitable fade value.
  final double? Function() fadeBuilder;

  /// The playing sound.
  PlaySound? _playSound;

  /// Start playing the music.
  void play() {
    _playSound = channel.playSound(
      _assetReference,
      gain: _gain,
      keepAlive: true,
      looping: true,
    );
  }

  /// Stop the music.
  void stop() {
    final fade = fadeBuilder();
    final playSound = _playSound;
    if (playSound != null) {
      if (fade == null) {
        playSound.destroy();
      } else {
        playSound.fade(length: fade, startGain: _gain);
        Timer(Duration(seconds: fade.floor() + 1), playSound.destroy);
      }
      _playSound = null;
    }
  }
}
