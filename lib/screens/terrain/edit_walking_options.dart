// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/number_list_tile.dart';
import '../../widgets/sound/sound_list_tile.dart';

/// A widget for editing the given [walkingOptions].
class EditWalkingOptions extends StatefulWidget {
  /// Create an instance.
  const EditWalkingOptions({
    required this.projectContext,
    required this.walkingOptions,
    this.title = 'Edit Walking Options',
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The options to configure.
  final WalkingOptions walkingOptions;

  /// The title of the resulting scaffold.
  final String title;

  /// Create state for this widget.
  @override
  EditWalkingOptionsState createState() => EditWalkingOptionsState();
}

/// State for [EditWalkingOptions].
class EditWalkingOptionsState extends State<EditWalkingOptions> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final sound = widget.walkingOptions.sound;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
              onPressed: () {
                widget.walkingOptions
                  ..distance = 0.1
                  ..interval = 1000
                  ..joystickValue = 0.1;
                widget.projectContext.save();
                setState(() {});
              },
              child: const Text('Restore Defaults'),
            )
          ],
          title: Text(widget.title),
        ),
        body: ListView(
          children: [
            NumberListTile(
              value: widget.walkingOptions.distance,
              onChanged: (final value) {
                widget.walkingOptions.distance = value;
                save();
              },
              autofocus: true,
              title: 'Step Length',
            ),
            NumberListTile(
              value: widget.walkingOptions.interval.toDouble(),
              onChanged: (final value) {
                widget.walkingOptions.interval = value.floor();
                save();
              },
              min: 0.0,
              title: 'Milliseconds Between Steps',
              subtitle: '${widget.walkingOptions.interval}',
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: sound,
              onDone: (final value) {
                widget.walkingOptions.sound = value;
                widget.projectContext.save();
                setState(() {});
              },
              assetStore: world.terrainAssetStore,
              defaultGain: world.soundOptions.defaultGain,
              nullable: true,
              title: 'Terrain Sound',
            ),
            NumberListTile(
              value: widget.walkingOptions.joystickValue,
              onChanged: (final value) {
                widget.walkingOptions.joystickValue = value;
                save();
              },
              max: 1.0,
              title: 'Minimum Joystick Value',
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
}
