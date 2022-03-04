import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/custom_message/custom_message_list_tile.dart';
import '../box/coordinates_list_tile.dart';

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
  _EditLocationMarkerState createState() => _EditLocationMarkerState();
}

/// State for [EditLocationMarker].
class _EditLocationMarkerState extends State<EditLocationMarker> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) => Cancel(
        child: Scaffold(
          appBar: AppBar(
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

  /// Save the project context.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
