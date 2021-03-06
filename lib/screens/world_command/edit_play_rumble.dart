import 'dart:async';

import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/number_list_tile.dart';

/// A widget for editing a [playRumble].
class EditPlayRumble extends StatefulWidget {
  /// Create an instance.
  const EditPlayRumble({
    required this.projectContext,
    required this.playRumble,
    required this.onDone,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The play rumble to use.
  final PlayRumble playRumble;

  /// The function to call when [playRumble] changes.
  final ValueChanged<PlayRumble?> onDone;

  /// Create state for this widget.
  @override
  EditPlayRumbleState createState() => EditPlayRumbleState();
}

/// State for [EditPlayRumble].
class EditPlayRumbleState extends State<EditPlayRumble> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final leftFrequency = widget.playRumble.leftFrequency;
    final rightFrequency = widget.playRumble.rightFrequency;
    final duration = widget.playRumble.duration;
    final numberOfJoysticks = widget.projectContext.game.sdl.numJoysticks;
    return CallbackShortcuts(
      bindings: {PlayPauseIntent.hotkey: playRumble},
      child: Cancel(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDone(null);
                },
                child: const Icon(
                  Icons.clear,
                  semanticLabel: 'Clear Value',
                ),
              ),
            ],
            title: const Text('Edit Rumble'),
          ),
          body: ListView(
            children: [
              NumberListTile(
                value: duration.toDouble(),
                onChanged: (final value) {
                  widget.playRumble.duration = value.floor();
                  save();
                },
                min: 5.0,
                autofocus: true,
                title: 'Duration',
                subtitle: '$duration milliseconds',
              ),
              NumberListTile(
                value: leftFrequency.toDouble(),
                onChanged: (final value) {
                  widget.playRumble.leftFrequency = value.floor();
                  save();
                },
                min: 0,
                max: 65535,
                title: 'Left Motor Strength',
              ),
              NumberListTile(
                value: rightFrequency.toDouble(),
                onChanged: (final value) {
                  widget.playRumble.rightFrequency = value.floor();
                  save();
                },
                min: 0,
                max: 65535,
                title: 'Right Motor Strength',
              ),
              ListTile(
                title: const Text('Play Rumble'),
                subtitle: Text(
                  '$numberOfJoysticks joystick'
                  '${numberOfJoysticks == 1 ? "" : "s"}',
                ),
                onTap: playRumble,
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Play the rumble effect.
  void playRumble() {
    final game = widget.projectContext.game;
    final sdl = widget.projectContext.game.sdl;
    for (var i = 0; i < sdl.numJoysticks; i++) {
      var j = game.joysticks[i];
      if (j == null) {
        j = sdl.openJoystick(i);
        game.joysticks[i] = j;
      }
      j.rumble(
        duration: widget.playRumble.duration,
        lowFrequency: widget.playRumble.leftFrequency,
        highFrequency: widget.playRumble.rightFrequency,
      );
    }
    Timer(Duration(milliseconds: widget.playRumble.duration), stopRumble);
  }

  /// Stop the rumble effect.
  void stopRumble() {
    for (final joystick in widget.projectContext.game.joysticks.values) {
      joystick.rumble(duration: 1, highFrequency: 0, lowFrequency: 0);
    }
  }

  /// Stop rumbles.
  @override
  void dispose() {
    super.dispose();
    stopRumble();
  }
}
