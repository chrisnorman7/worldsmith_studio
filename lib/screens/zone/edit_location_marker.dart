// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/box/coordinates_list_tile.dart';
import '../../widgets/cancel.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing a location marker.
class EditLocationMarker extends StatefulWidget {
  /// Create an instance.
  const EditLocationMarker({
    required this.projectContext,
    required this.zone,
    required this.locationMarker,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The zone that [locationMarker] belongs to.
  final Zone zone;

  /// The location marker to edit.
  final LocationMarker locationMarker;

  /// Create state for this widget.
  @override
  EditLocationMarkerState createState() => EditLocationMarkerState();
}

/// State for [EditLocationMarker].
class EditLocationMarkerState extends State<EditLocationMarker> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () => deleteLocationMarker(context),
              child: const Icon(
                Icons.delete_outline,
                semanticLabel: 'Delete Location Marker',
              ),
            )
          ],
          title: const Text('Edit Location Marker'),
        ),
        body: ListView(
          children: [
            TextListTile(
              value: widget.locationMarker.name ?? '',
              onChanged: (value) {
                widget.locationMarker.name = value.isEmpty ? null : value;
                save();
              },
              header: 'Name',
              autofocus: true,
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: widget.locationMarker.sound,
              onDone: (value) {
                widget.locationMarker.sound = value;
                save();
              },
              assetStore: world.interfaceSoundsAssetStore,
              defaultGain: world.soundOptions.defaultGain,
              nullable: true,
            ),
            CoordinatesListTile(
              projectContext: widget.projectContext,
              zone: widget.zone,
              value: widget.locationMarker.coordinates,
              onChanged: save,
              canChangeClamp: true,
            )
          ],
        ),
      ),
    );
  }

  /// Delete the location marker.
  void deleteLocationMarker(final BuildContext context) {
    confirm(
      context: context,
      message: 'Are you sure you want to delete this location marker?',
      title: 'Delete Location Marker',
      yesCallback: () {
        Navigator.pop(context);
        Navigator.pop(context);
        widget.zone.locationMarkers.removeWhere(
          (final element) => element.id == widget.locationMarker.id,
        );
      },
    );
  }

  /// Save the project context.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
