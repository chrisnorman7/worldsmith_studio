// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/command/call_command_list_tile.dart';
import '../../widgets/number_list_tile.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/push_widget_list_tile.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/zone/walking_mode_list_tile.dart';
import '../zone/select_location_marker.dart';

const _intervalModifier = 100.0;

/// A widget for editing a [npcMove].
class EditNpcMove extends StatefulWidget {
  /// Create an instance.
  const EditNpcMove({
    required this.projectContext,
    required this.zone,
    required this.zoneNpc,
    required this.npcMove,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The zone to use.
  final Zone zone;

  /// The zone NPC to  work with.
  final ZoneNpc zoneNpc;

  /// The move to work with.
  final NpcMove npcMove;

  /// Create state for this widget.
  @override
  EditNpcMoveState createState() => EditNpcMoveState();
}

/// State for [EditNpcMove].
class EditNpcMoveState extends State<EditNpcMove> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final marker = widget.zone.getLocationMarker(
      widget.npcMove.locationMarkerId,
    );
    final sound = marker.message.sound;
    final assetReference = sound == null
        ? null
        : widget.projectContext.worldContext.getCustomSound(sound);
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () => confirm(
                context: context,
                message: 'Are you sure you want to delete this move?',
                title: 'Delete Move',
                yesCallback: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  widget.zoneNpc.moves.removeWhere(
                    (final element) => element.id == widget.npcMove.id,
                  );
                },
              ),
              child: const Icon(
                Icons.delete,
                semanticLabel: 'Delete Move',
              ),
            )
          ],
          title: const Text('Edit Move'),
        ),
        body: ListView(
          children: [
            PlaySoundSemantics(
              soundChannel: widget.projectContext.game.interfaceSounds,
              assetReference: assetReference,
              gain: sound?.gain ?? 0,
              child: PushWidgetListTile(
                title: 'Location Marker',
                builder: (final context) => SelectLocationMarker(
                  projectContext: widget.projectContext,
                  locationMarkers: widget.zone.locationMarkers,
                  onDone: (final value) {
                    widget.npcMove.locationMarkerId = value.id;
                    save();
                  },
                ),
                autofocus: true,
                subtitle: marker.message.text ?? 'Untitled Location Marker',
              ),
            ),
            NumberListTile(
              value: widget.npcMove.z,
              onChanged: (final value) {
                widget.npcMove.z = value;
                save();
              },
              title: 'Z Coordinate',
            ),
            NumberListTile(
              value: widget.npcMove.minMoveInterval.toDouble(),
              onChanged: (final value) {
                widget.npcMove.minMoveInterval = value.floor();
                save();
              },
              min: 10,
              max: widget.npcMove.maxMoveInterval.toDouble(),
              modifier: _intervalModifier,
              title: 'Minimum Move Interval',
              subtitle: '${widget.npcMove.minMoveInterval} milliseconds',
            ),
            NumberListTile(
              value: widget.npcMove.maxMoveInterval.toDouble(),
              onChanged: (final value) {
                widget.npcMove.maxMoveInterval = value.floor();
                save();
              },
              min: widget.npcMove.minMoveInterval.toDouble(),
              modifier: _intervalModifier,
              title: 'Max Move Interval',
              subtitle: '${widget.npcMove.maxMoveInterval} milliseconds',
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: widget.npcMove.moveSound,
              onDone: (final value) {
                widget.npcMove.moveSound = value;
                save();
              },
              assetStore: world.terrainAssetStore,
              defaultGain: world.soundOptions.defaultGain,
              nullable: true,
              soundChannel: widget.projectContext.game.interfaceSounds,
              title: 'Move Sound',
            ),
            WalkingModeListTile(
              walkingMode: widget.npcMove.walkingMode,
              onDone: (final value) {
                widget.npcMove.walkingMode = value;
                save();
              },
            ),
            NumberListTile(
              value: widget.npcMove.stepSize ?? 0.0,
              onChanged: (final value) {
                if (value == 0.0) {
                  widget.npcMove.stepSize = null;
                } else {
                  widget.npcMove.stepSize = value;
                }
                save();
              },
              modifier: 0.5,
              subtitle: widget.npcMove.stepSize == null
                  ? 'Default'
                  : '${widget.npcMove.stepSize}',
              title: 'Step Size',
            ),
            CallCommandListTile(
              projectContext: widget.projectContext,
              callCommand: widget.npcMove.startCommand,
              onChanged: (final value) {
                widget.npcMove.startCommand = value;
                save();
              },
              title: 'Start Command',
            ),
            CallCommandListTile(
              projectContext: widget.projectContext,
              callCommand: widget.npcMove.moveCommand,
              onChanged: (final value) {
                widget.npcMove.moveCommand = value;
                save();
              },
              title: 'MoveCommand',
            ),
            CallCommandListTile(
              projectContext: widget.projectContext,
              callCommand: widget.npcMove.endCommand,
              onChanged: (final value) {
                widget.npcMove.endCommand = value;
                save();
              },
              title: 'End Command',
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
