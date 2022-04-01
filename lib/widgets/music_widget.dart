import 'package:flutter/material.dart';
import 'package:ziggurat/sound.dart';

import '../music_player.dart';

/// A widget that plays music while it is mounted.
class MusicWidget extends StatefulWidget {
  /// Create an instance.
  const MusicWidget({
    required this.title,
    required this.child,
    required this.soundChannel,
    required this.getMusic,
    required this.getFadeTime,
    this.actions = const [],
    this.floatingActionButton,
    final Key? key,
  }) : super(key: key);

  /// The title of the resulting [Scaffold].
  final String title;

  /// The body of the [Scaffold].
  final Widget child;

  /// The channel to play music through.
  final SoundChannel soundChannel;

  /// A function to get the music for this widget.
  final Music? Function() getMusic;

  /// A function for getting the fade time for the music.
  final double? Function() getFadeTime;

  /// The actions for the [Scaffold]'s [AppBar].
  final List<Widget> actions;

  /// A floating action button for the [Scaffold].
  final FloatingActionButton? floatingActionButton;

  /// Create state for this widget.
  @override
  MusicWidgetState createState() => MusicWidgetState();
}

/// State for [MusicWidget].
class MusicWidgetState extends State<MusicWidget> {
  MusicPlayer? _musicPlayer;

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final music = widget.getMusic();
    final musicPlayer = _musicPlayer;
    if (music == null) {
      _musicPlayer?.stop();
      _musicPlayer = null;
    } else if (musicPlayer == null) {
      _musicPlayer = MusicPlayer(
        channel: widget.soundChannel,
        assetReference: music.sound,
        gain: music.gain,
        fadeBuilder: widget.getFadeTime,
      )..play();
    } else {
      musicPlayer
        ..gain = music.gain
        ..assetReference = music.sound;
    }
    return Scaffold(
      appBar: AppBar(
        actions: widget.actions,
        title: Text(widget.title),
      ),
      body: widget.child,
    );
  }

  /// Stop the sound playing.
  @override
  void dispose() {
    super.dispose();
    _musicPlayer?.stop();
    _musicPlayer = null;
  }
}
