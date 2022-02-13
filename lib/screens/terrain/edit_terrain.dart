import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/get_text.dart';
import '../../widgets/play_sound_semantics.dart';
import 'edit_walking_options.dart';

/// A widget for editing the given [terrain].
class EditTerrain extends StatefulWidget {
  /// Create an instance.
  const EditTerrain({
    required this.projectContext,
    required this.terrain,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The terrain to edit.
  final Terrain terrain;

  /// Create state for this widget.
  @override
  _EditTerrainState createState() => _EditTerrainState();
}

/// State for [EditTerrain].
class _EditTerrainState extends State<EditTerrain> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final terrain = widget.terrain;
    final terrainAssets = widget.projectContext.world.terrainAssets;
    final fastWalkSound = terrain.fastWalk.sound;
    final slowWalkSound = terrain.slowWalk.sound;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: Text(terrain.name),
        ),
        body: ListView(
          children: [
            ListTile(
              autofocus: true,
              title: const Text('Name'),
              subtitle: Text(terrain.name),
              onTap: () => pushWidget(
                context: context,
                builder: (context) => GetText(
                  onDone: (value) {
                    Navigator.pop(context);
                    terrain.name = value;
                    widget.projectContext.save();
                    setState(() {});
                  },
                  labelText: 'Terrain Name',
                  text: terrain.name,
                  title: 'Rename Terrain',
                ),
              ),
            ),
            PlaySoundSemantics(
              child: ListTile(
                title: const Text('Slow Walk Settings'),
                onTap: () async {
                  await pushWidget(
                    context: context,
                    builder: (context) => EditWalkingOptions(
                      projectContext: widget.projectContext,
                      walkingOptions: terrain.slowWalk,
                      title: 'Slow Walk Settings',
                    ),
                  );
                  setState(() {});
                },
              ),
              soundChannel: widget.projectContext.game.interfaceSounds,
              assetReference: widget.projectContext.getRelativeAssetReference(
                getAssetReferenceReference(
                        assets: terrainAssets, id: slowWalkSound.id)!
                    .reference,
              ),
              gain: slowWalkSound.gain,
            ),
            PlaySoundSemantics(
              child: ListTile(
                title: const Text('Fast Walk Settings'),
                onTap: () async {
                  await pushWidget(
                    context: context,
                    builder: (context) => EditWalkingOptions(
                      projectContext: widget.projectContext,
                      walkingOptions: terrain.fastWalk,
                      title: 'Fast Walk Settings',
                    ),
                  );
                  setState(() {});
                },
              ),
              soundChannel: widget.projectContext.game.interfaceSounds,
              assetReference: widget.projectContext.getRelativeAssetReference(
                getAssetReferenceReference(
                  assets: terrainAssets,
                  id: fastWalkSound.id,
                )!
                    .reference,
              ),
              gain: fastWalkSound.gain,
            ),
          ],
        ),
      ),
    );
  }
}
