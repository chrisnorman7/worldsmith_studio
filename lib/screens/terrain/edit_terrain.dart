import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/text_list_tile.dart';
import 'edit_walking_options.dart';

/// A widget for editing the given [terrain].
class EditTerrain extends StatefulWidget {
  /// Create an instance.
  const EditTerrain({
    required this.projectContext,
    required this.terrain,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The terrain to edit.
  final Terrain terrain;

  /// Create state for this widget.
  @override
  EditTerrainState createState() => EditTerrainState();
}

/// State for [EditTerrain].
class EditTerrainState extends State<EditTerrain> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final terrain = widget.terrain;
    final terrainAssets = widget.projectContext.world.terrainAssets;
    final fastWalkSound = terrain.fastWalk.sound;
    final slowWalkSound = terrain.slowWalk.sound;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () {
                final world = widget.projectContext.world;
                final id = widget.terrain.id;
                String? message;
                for (final zone in world.zones) {
                  if (zone.defaultTerrainId == id) {
                    message = 'You cannot delete the default terrain of the '
                        '${zone.name} zone.';
                  } else {
                    for (final box in zone.boxes) {
                      if (box.terrainId == id) {
                        message = 'You cannot delete the terrain for the '
                            '${box.name} box of the ${zone.name} zone.';
                      }
                    }
                  }
                }
                if (message != null) {
                  return showError(context: context, message: message);
                }
                confirm(
                  context: context,
                  message: 'Are you sure you want to delete the '
                      '${widget.terrain.name} terrain?',
                  title: 'Confirm Delete',
                  yesCallback: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    world.terrains.removeWhere(
                      (final element) => element.id == id,
                    );
                    widget.projectContext.save();
                  },
                );
              },
              child: deleteIcon,
            )
          ],
          title: Text(terrain.name),
        ),
        body: ListView(
          children: [
            TextListTile(
              value: terrain.name,
              onChanged: (final value) {
                terrain.name = value;
                widget.projectContext.save();
                setState(() {});
              },
              header: 'Name',
              autofocus: true,
              validator: (final value) => validateNonEmptyValue(value: value),
            ),
            PlaySoundSemantics(
              soundChannel: widget.projectContext.game.interfaceSounds,
              assetReference: slowWalkSound == null
                  ? null
                  : getAssetReferenceReference(
                      assets: terrainAssets,
                      id: slowWalkSound.id,
                    ).reference,
              gain: slowWalkSound?.gain ?? 0.0,
              child: ListTile(
                title: const Text('Slow Walk Settings'),
                onTap: () async {
                  await pushWidget(
                    context: context,
                    builder: (final context) => EditWalkingOptions(
                      projectContext: widget.projectContext,
                      walkingOptions: terrain.slowWalk,
                      title: 'Slow Walk Settings',
                    ),
                  );
                  setState(() {});
                },
              ),
            ),
            PlaySoundSemantics(
              soundChannel: widget.projectContext.game.interfaceSounds,
              assetReference: fastWalkSound == null
                  ? null
                  : getAssetReferenceReference(
                      assets: terrainAssets,
                      id: fastWalkSound.id,
                    ).reference,
              gain: fastWalkSound?.gain ?? 0.0,
              child: ListTile(
                title: const Text('Fast Walk Settings'),
                onTap: () async {
                  await pushWidget(
                    context: context,
                    builder: (final context) => EditWalkingOptions(
                      projectContext: widget.projectContext,
                      walkingOptions: terrain.fastWalk,
                      title: 'Fast Walk Settings',
                    ),
                  );
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
