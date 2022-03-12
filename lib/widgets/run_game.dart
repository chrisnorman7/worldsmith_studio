import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:worldsmith/world_context.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../project_context.dart';
import '../project_sound_manager.dart';
import 'cancel.dart';
import 'center_text.dart';

/// A widget for running the given [projectContext].
class RunGame extends StatefulWidget {
  /// Create an instance.
  const RunGame({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _RunGameState createState() => _RunGameState();
}

/// State for [RunGame].
class _RunGameState extends State<RunGame> {
  late final List<SoundEvent> soundEvents;
  bool? done;

  /// Initialise the game.
  @override
  void initState() {
    super.initState();
    soundEvents = [];
  }

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final Widget child;
    if (done == null) {
      child = const CenterText(text: 'Starting game...');
      startGame();
    } else if (soundEvents.isEmpty) {
      child = const CenterText(text: 'No sound events yet.');
    } else {
      child = ListView.builder(
        itemBuilder: (context, index) {
          final event = soundEvents[index];
          return ListTile(
            autofocus: index == 0,
            title: Text('$event'),
            onTap: () {
              final data = ClipboardData(text: event.toString());
              Clipboard.setData(data);
            },
          );
        },
        itemCount: soundEvents.length,
      );
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: Text('${world.title} version ${world.globalOptions.version}'),
        ),
        body: child,
      ),
    );
  }

  /// Stop the game running.
  @override
  void dispose() {
    super.dispose();
    widget.projectContext.game.stop();
  }

  /// Start the game running.
  Future<void> startGame() async {
    final world = widget.projectContext.world;
    Sdl? sdl;
    BufferCache? bufferCache;
    try {
      final game = Game(
        world.title,
        // ignore: prefer_const_constructors
        triggerMap: TriggerMap([]),
      );
      final context = widget.projectContext.audioContext;
      bufferCache = BufferCache(
        synthizer: context.synthizer,
        maxSize: pow(1024, 3).floor(),
        random: game.random,
      );
      final soundManager = ProjectSoundManager(
        game: game,
        context: context,
        bufferCache: bufferCache,
        soundsDirectory: widget.projectContext.directory.path,
      );
      sdl = Sdl()..init();
      final worldContext = WorldContext(
        sdl: sdl,
        game: game,
        world: world,
      );
      setState(() => done = false);
      await worldContext.run(
        onSound: (event) {
          soundManager.handleEvent(event);
          setState(() {
            soundEvents.add(event);
          });
        },
      );
    } on Exception {
      rethrow;
    } finally {
      bufferCache?.destroy();
      // sdl?.quit();
      setState(() => done = true);
    }
  }
}
