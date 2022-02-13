import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/get_number.dart';
import '../../widgets/get_text.dart';
import '../../widgets/play_sound_semantics.dart';
import '../asset_store/select_asset.dart';

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
    final terrainAssets = widget.projectContext.world.terrainAssets;
    final assetReference = getAssetReferenceReference(
      assets: terrainAssets,
      id: sound.id,
    )!;
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
            ListTile(
              title: const Text('Milliseconds Between Steps'),
              subtitle: Text('${widget.walkingOptions.interval}'),
              onTap: () => pushWidget(
                context: context,
                builder: (context) => GetText(
                  onDone: (value) {
                    Navigator.pop(context);
                    widget.walkingOptions.interval = int.parse(value);
                    widget.projectContext.save();
                    setState(() {});
                  },
                  labelText: 'Interval',
                  text: widget.walkingOptions.interval.toString(),
                  title: 'Step Interval',
                  validator: (value) => validateInt(value: value),
                ),
              ),
            ),
            PlaySoundSemantics(
              child: Builder(
                builder: (context) => ListTile(
                  title: const Text('Sound'),
                  subtitle: Text(
                    assetString(assetReference),
                  ),
                  onTap: () {
                    PlaySoundSemantics.of(context)!.stop();
                    pushWidget(
                      context: context,
                      builder: (context) => SelectAsset(
                        projectContext: widget.projectContext,
                        assetStore: world.terrainAssetStore,
                        onDone: (value) {
                          Navigator.pop(context);
                          sound.id = value!.variableName;
                          widget.projectContext.save();
                          setState(() {});
                        },
                        currentId: sound.id,
                        title: 'Footstep Sound',
                      ),
                    );
                  },
                ),
              ),
              soundChannel: widget.projectContext.game.interfaceSounds,
              assetReference: widget.projectContext.getRelativeAssetReference(
                assetReference.reference,
              ),
              gain: sound.gain,
            ),
            ListTile(
              title: const Text('Gain'),
              subtitle: Text('${sound.gain}'),
              onTap: () => pushWidget(
                context: context,
                builder: (context) => GetNumber(
                  value: sound.gain,
                  onDone: (value) {
                    Navigator.pop(context);
                    sound.gain = value;
                    widget.projectContext.save();
                    setState(() {});
                  },
                  labelText: 'Gain',
                  min: 0.001,
                  title: 'Footstep Gain',
                ),
              ),
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
