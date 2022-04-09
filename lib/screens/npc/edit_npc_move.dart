import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/push_widget_list_tile.dart';
import '../../widgets/select_item.dart';

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
