import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/box/coordinates_list_tile.dart';
import '../../widgets/cancel.dart';
import '../../widgets/custom_message/custom_message_list_tile.dart';

/// A widget for editing a location marker.
class EditLocationMarker extends StatefulWidget {
  /// Create an instance.
  const EditLocationMarker({
    required this.projectContext,
    required this.zone,
    required this.locationMarker,
    Key? key,
  }) : super(key: key);

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
  Widget build(BuildContext context) => Cancel(
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
              CustomMessageListTile(
                projectContext: widget.projectContext,
                customMessage: widget.locationMarker.message,
                title: 'Message',
                autofocus: true,
                validator: (value) => validateNonEmptyValue(value: value),
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

  /// Delete the location marker.
  void deleteLocationMarker(BuildContext context) {
    final world = widget.projectContext.world;
    for (final category in world.commandCategories) {
      for (final command in category.commands) {
        if (command.localTeleport?.locationMarkerId ==
            widget.locationMarker.id) {
          return showError(
            context: context,
            message: 'You cannot delete the location marker used by the '
                '${command.name} command of the ${category.name} category.',
          );
        }
      }
    }
    confirm(
        context: context,
        message: 'Are you sure you want to delete this location marker?',
        title: 'Delete Location Marker',
        yesCallback: () {
          Navigator.pop(context);
          Navigator.pop(context);
          widget.zone.locationMarkers.removeWhere(
            (element) => element.id == widget.locationMarker.id,
          );
        });
  }

  /// Save the project context.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
