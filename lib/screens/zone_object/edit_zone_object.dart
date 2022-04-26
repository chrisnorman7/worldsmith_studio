// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/box/coordinates_list_tile.dart';
import '../../widgets/cancel.dart';
import '../../widgets/command/call_command_list_tile.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing a [zoneObject].
class EditZoneObject extends StatefulWidget {
  /// Create an instance.
  const EditZoneObject({
    required this.projectContext,
    required this.zone,
    required this.zoneObject,
    required this.onDone,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The zone where [zoneObject] is located.
  final Zone zone;

  /// The zone object to edit.
  final ZoneObject zoneObject;

  /// The function to call when editing is complete.
  final VoidCallback onDone;

  /// Create state for this widget.
  @override
  EditZoneObjectState createState() => EditZoneObjectState();
}

/// State for [EditZoneObject].
class EditZoneObjectState extends State<EditZoneObject> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final coordinates = widget.zoneObject.initialCoordinates;
    final ambiance = widget.zoneObject.ambiance;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () => confirm(
                context: context,
                message: 'Are you sure you want to delete the '
                    '${widget.zoneObject.name} object?',
                title: 'Delete Object',
                yesCallback: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  widget.zone.objects.remove(widget.zoneObject);
                  save();
                  widget.onDone();
                },
              ),
              child: const Icon(
                Icons.delete_outline,
                semanticLabel: 'Delete Object',
              ),
            )
          ],
          title: const Text('Edit Zone Object'),
        ),
        body: ListView(
          children: [
            TextListTile(
              value: widget.zoneObject.name,
              onChanged: (final value) {
                widget.zoneObject.name = value;
                save();
              },
              header: 'Name',
              labelText: 'Name',
              title: 'Object Name',
              autofocus: true,
            ),
            CoordinatesListTile(
              projectContext: widget.projectContext,
              zone: widget.zone,
              value: coordinates,
              onChanged: save,
              title: 'Initial Coordinates',
              canChangeClamp: true,
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: ambiance,
              onDone: (final value) {
                widget.zoneObject.ambiance = value;
                save();
              },
              assetStore: world.ambianceAssetStore,
              defaultGain: world.soundOptions.defaultGain,
              looping: true,
              nullable: true,
              title: 'Ambiance',
            ),
            CallCommandListTile(
              projectContext: widget.projectContext,
              callCommand: widget.zoneObject.collideCommand,
              onChanged: (final value) {
                widget.zoneObject.collideCommand = value;
                save();
              },
              title: 'Collide Command',
            )
          ],
        ),
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    widget.onDone();
    setState(() {});
  }
}
