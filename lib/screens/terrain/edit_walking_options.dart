import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/get_number.dart';
import '../../widgets/text_list_tile.dart';
import '../sound/sound_list_tile.dart';

/// A widget for editing the given [walkingOptions].
class EditWalkingOptions extends StatefulWidget {
  /// Create an instance.
  const EditWalkingOptions({
    required this.projectContext,
    required this.walkingOptions,
    this.title = 'Edit Walking Options',
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The options to configure.
  final WalkingOptions walkingOptions;

  /// The title of the resulting scaffold.
  final String title;

  /// Create state for this widget.
  @override
  _EditWalkingOptionsState createState() => _EditWalkingOptionsState();
}

/// State for [EditWalkingOptions].
class _EditWalkingOptionsState extends State<EditWalkingOptions> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
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
            ListTile(
              autofocus: true,
              title: const Text('Step Length'),
              subtitle: Text('${widget.walkingOptions.distance}'),
              onTap: () => pushWidget(
                context: context,
                builder: (context) => GetNumber(
                  value: widget.walkingOptions.distance,
                  onDone: (value) {
                    Navigator.pop(context);
                    widget.walkingOptions.distance = value;
                    widget.projectContext.save();
                    setState(() {});
                  },
                  labelText: 'Distance',
                  min: 0.001,
                  title: 'Step Length',
                ),
              ),
            ),
            TextListTile(
              value: widget.walkingOptions.interval.toString(),
              onChanged: (value) {
                widget.walkingOptions.interval = int.parse(value);
                widget.projectContext.save();
                setState(() {});
              },
              header: 'Milliseconds Between Steps',
              validator: (value) => validateInt(value: value),
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: sound,
              onDone: (value) {
                widget.projectContext.save();
                setState(() {});
              },
              assetStore: world.terrainAssetStore,
              defaultGain: world.soundOptions.defaultGain,
              title: 'Terrain Sound',
            ),
            ListTile(
              title: const Text('Minimum Joystick Value'),
              subtitle: Text('${widget.walkingOptions.joystickValue}'),
              onTap: () => pushWidget(
                context: context,
                builder: (context) => GetNumber(
                  value: widget.walkingOptions.joystickValue,
                  onDone: (value) {
                    Navigator.pop(context);
                    widget.walkingOptions.joystickValue = value;
                    widget.projectContext.save();
                    setState(() {});
                  },
                  labelText: 'Joystick Value',
                  min: 0.001,
                  max: 0.99,
                  title: 'Minimum Joystick Value',
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
