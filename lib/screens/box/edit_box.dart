import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/custom_message/custom_message_list_tile.dart';
import '../../widgets/text_list_tile.dart';
import '../reverb/reverb_list_tile.dart';
import '../terrain/terrain_list_tile.dart';
import 'coordinates_list_tile.dart';

/// A widget for editing the given [box].
class EditBox extends StatefulWidget {
  /// Create an instance.
  const EditBox({
    required this.projectContext,
    required this.zone,
    required this.box,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The zone where [box] resides.
  final Zone zone;

  /// The box to edit.
  final Box box;

  /// Create state for this widget.
  @override
  _EditBoxState createState() => _EditBoxState();
}

/// State for [EditBox].
class _EditBoxState extends State<EditBox> {
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
                  save();
                },
                reverbPresets: widget.projectContext.world.reverbs,
                currentReverbId: widget.box.reverbId,
              ),
              CustomMessageListTile(
                projectContext: widget.projectContext,
                customMessage: widget.box.enterMessage,
                title: 'Enter Message',
              ),
              CustomMessageListTile(
                projectContext: widget.projectContext,
                customMessage: widget.box.leaveMessage,
                title: 'Leave Message',
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