// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/play_sound_semantics.dart';
import '../zone/select_location_marker.dart';
import 'edit_npc_move.dart';

/// A widget for editing NPC moves for the given [zoneNpc].
class EditNpcMoves extends StatefulWidget {
  /// Create an instance.
  const EditNpcMoves({
    required this.projectContext,
    required this.zone,
    required this.zoneNpc,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The zone to work with.
  final Zone zone;

  /// The NPC to work with.
  final ZoneNpc zoneNpc;

  /// Create state for this widget.
  @override
  EditNpcMovesState createState() => EditNpcMovesState();
}

/// State for [EditNpcMoves].
class EditNpcMovesState extends State<EditNpcMoves> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final moves = widget.zoneNpc.moves;
    final worldContext = widget.projectContext.worldContext;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NPC Moves'),
        ),
        body: ListView.builder(
          itemBuilder: (final context, final index) {
            final move = moves[index];
            final marker = widget.zone.getLocationMarker(move.locationMarkerId);
            final name = marker.name;
            final sound = marker.sound;
            final assetReference = sound == null
                ? null
                : getAssetReferenceReference(
                    assets: worldContext.world.interfaceSoundsAssets,
                    id: sound.id,
                  ).reference;
            return PlaySoundSemantics(
              soundChannel: widget.projectContext.game.interfaceSounds,
              assetReference: assetReference,
              gain: sound?.gain ?? 0,
              child: ListTile(
                autofocus: index == 0,
                title: Text(name ?? 'Untitled Marker'),
                subtitle: Text(
                  '${move.minMoveInterval}-${move.maxMoveInterval} ms '
                  '(${move.stepSize} step size)',
                ),
                onTap: () async {
                  await pushWidget(
                    context: context,
                    builder: (final context) => EditNpcMove(
                      projectContext: widget.projectContext,
                      zone: widget.zone,
                      zoneNpc: widget.zoneNpc,
                      npcMove: move,
                    ),
                  );
                  setState(() {});
                },
              ),
            );
          },
          itemCount: widget.zoneNpc.moves.length,
        ),
        floatingActionButton: FloatingActionButton(
          autofocus: moves.isEmpty,
          child: createIcon,
          onPressed: () {
            final markers = widget.zone.locationMarkers;
            if (markers.isEmpty) {
              showError(
                context: context,
                message: 'There are no location markers for this zone.',
              );
            } else {
              pushWidget(
                context: context,
                builder: (final context) => SelectLocationMarker(
                  projectContext: widget.projectContext,
                  locationMarkers: markers,
                  onDone: (final value) async {
                    Navigator.pop(context);
                    final move = NpcMove(
                      id: newId(),
                      locationMarkerId: value.id,
                    );
                    widget.zoneNpc.moves.add(move);
                    widget.projectContext.save();
                    setState(() {});
                  },
                ),
              );
            }
          },
          tooltip: 'Add Move',
        ),
      ),
    );
  }
}
