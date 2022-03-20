import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/box/coordinates_list_tile.dart';
import '../../widgets/cancel.dart';
import '../../widgets/command/call_command_list_tile.dart';
import '../../widgets/reverb/reverb_list_tile.dart';
import '../../widgets/terrain/terrain_list_tile.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing the given [box].
class EditBox extends StatefulWidget {
  /// Create an instance.
  const EditBox({
    required this.projectContext,
    required this.zone,
    required this.box,
    required this.onDone,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The zone where [box] resides.
  final Zone zone;

  /// The box to edit.
  final Box box;

  /// The function to be called when editing is complete.
  final VoidCallback onDone;

  /// Create state for this widget.
  @override
  EditBoxState createState() => EditBoxState();
}

/// State for [EditBox].
class EditBoxState extends State<EditBox> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) => Cancel(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Edit Box'),
          ),
          body: ListView(
            children: [
              TextListTile(
                value: widget.box.name,
                onChanged: (value) {
                  widget.box.name = value;
                  save();
                },
                header: 'Box Name',
                autofocus: true,
                labelText: 'Name',
              ),
              CoordinatesListTile(
                projectContext: widget.projectContext,
                zone: widget.zone,
                box: widget.box,
                value: widget.box.start,
                onChanged: save,
                title: 'Start Coordinates',
              ),
              CoordinatesListTile(
                projectContext: widget.projectContext,
                zone: widget.zone,
                box: widget.box,
                value: widget.box.end,
                onChanged: save,
                title: 'End Coordinates',
              ),
              TerrainListTile(
                projectContext: widget.projectContext,
                onDone: (value) {
                  Navigator.pop(context);
                  widget.box.terrainId = value.id;
                  save();
                },
                terrains: widget.projectContext.world.terrains,
                currentTerrainId: widget.box.terrainId,
              ),
              ReverbListTile(
                projectContext: widget.projectContext,
                onDone: (value) {
                  widget.box.reverbId = value?.id;
                  widget.onDone();
                  save();
                },
                reverbPresets: widget.projectContext.world.reverbs,
                currentReverbId: widget.box.reverbId,
                nullable: true,
              ),
              CallCommandListTile(
                projectContext: widget.projectContext,
                callCommand: widget.box.enterCommand,
                onChanged: (value) {
                  widget.box.enterCommand = value;
                  save();
                },
                title: 'Enter Command',
              ),
              CallCommandListTile(
                projectContext: widget.projectContext,
                callCommand: widget.box.leaveCommand,
                onChanged: (value) {
                  widget.box.leaveCommand = value;
                  save();
                },
                title: 'Leave Command',
              ),
              CheckboxListTile(
                value: widget.box.enclosed,
                onChanged: (value) {
                  widget.box.enclosed = value == true;
                  save();
                },
                title: const Text('Soundproof Box'),
              )
            ],
          ),
        ),
      );

  /// Save the project context, and call[setState].
  void save() {
    widget.projectContext.save();
    setState(() {});
    widget.onDone();
  }
}
