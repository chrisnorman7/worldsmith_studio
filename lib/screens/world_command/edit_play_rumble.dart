import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

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
    Key? key,
  }) : super(key: key);

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
  Widget build(BuildContext context) {
    final leftFrequency = widget.playRumble.leftFrequency;
    final rightFrequency = widget.playRumble.rightFrequency;
    final duration = widget.playRumble.duration;
    return Cancel(
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
              onChanged: (value) {
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
              onChanged: (value) {
                widget.playRumble.leftFrequency = value.floor();
                save();
              },
              min: 0,
              max: 65535,
              title: 'Left Motor Strength',
            ),
            NumberListTile(
              value: rightFrequency.toDouble(),
              onChanged: (value) {
                widget.playRumble.rightFrequency = value.floor();
                save();
              },
              min: 0,
              max: 65535,
              title: 'Right Motor Strength',
            ),
            ListTile(
              title: const Text('Test Rumble'),
              subtitle: Text('${widget.projectContext.sdl.numJoysticks}'),
              onTap: playHaptic,
            )
          ],
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
  void playHaptic() {
    final game = widget.projectContext.game;
    final sdl = widget.projectContext.sdl;
    for (var i = 0; i < sdl.numJoysticks; i++) {
      var j = game.joysticks[i];
      if (j == null) {
        j = sdl.openJoystick(i);
        game.joysticks[i] = j;
      }
    }
    widget.projectContext.worldContext.handlePlayRumble(widget.playRumble);
  }
}
