import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/number_list_tile.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/push_widget_list_tile.dart';
import '../../widgets/select_item.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/zone/walking_mode_list_tile.dart';

const _intervalModifier = 100.0;

/// A widget for editing a [npcMove].
class EditNpcMove extends StatefulWidget {
  /// Create an instance.
  const EditNpcMove({
    required this.projectContext,
    required this.zone,
    required this.zoneNpc,
    required this.npcMove,
    final Key? key,
  }) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
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
              builder: (final context) => SelectItem<LocationMarker>(
                onDone: (final value) {
                  widget.npcMove.locationMarkerId = value.id;
                  save();
                },
                values: widget.zone.locationMarkers,
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
          )
        ],
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
