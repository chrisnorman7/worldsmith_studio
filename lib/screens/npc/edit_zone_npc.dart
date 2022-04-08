import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/box/coordinates_list_tile.dart';
import '../../widgets/cancel.dart';

/// A widget for editing the given [zoneNpc].
class EditZoneNpc extends StatefulWidget {
  /// Create an instance.
  const EditZoneNpc({
    required this.projectContext,
    required this.zone,
    required this.zoneNpc,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The zone that [zoneNpc] is attached to.
  final Zone zone;

  /// The zone NPC to edit.
  final ZoneNpc zoneNpc;

  /// Create state for this widget.
  @override
  EditZoneNpcState createState() => EditZoneNpcState();
}

/// State for [EditZoneNpc].
class EditZoneNpcState extends State<EditZoneNpc> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) => Cancel(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Edit ZoneNPC'),
          ),
          body: ListView(
            children: [
              CoordinatesListTile(
                projectContext: widget.projectContext,
                zone: widget.zone,
                value: widget.zoneNpc.initialCoordinates,
                onChanged: save,
                autofocus: true,
                canChangeClamp: true,
                title: 'Initial Coordinates',
              )
            ],
          ),
        ),
      );

  /// Save the project context, and call[setState].
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
