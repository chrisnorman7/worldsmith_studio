import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/get_number.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/number_list_tile.dart';
import '../box/coordinates_list_tile.dart';
import '../box/edit_coordinates.dart';
import '../zone/zone_list_tile.dart';

/// A widget for editing a [zoneTeleport].
class EditZoneTeleport extends StatefulWidget {
  /// Create an instance.
  const EditZoneTeleport({
    required this.projectContext,
    required this.zoneTeleport,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The zone teleport to edit.
  final ZoneTeleport zoneTeleport;

  /// The function to be called with the resulting value.
  final ValueChanged<ZoneTeleport?> onChanged;

  /// Create state for this widget.
  @override
  _EditZoneTeleportState createState() => _EditZoneTeleportState();
}

/// State for [EditZoneTeleport].
class _EditZoneTeleportState extends State<EditZoneTeleport> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final clearMaxCoordinatesActions = [
      ElevatedButton(
        onPressed: () {
          widget.zoneTeleport.maxCoordinates = null;
          save();
        },
        child: const Icon(
          Icons.clear_outlined,
          semanticLabel: 'Clear Maximum Coordinates',
        ),
      )
    ];
    final zoneId = widget.zoneTeleport.zoneId;
    final zone = widget.projectContext.world.getZone(zoneId);
    final minCoordinates = widget.zoneTeleport.minCoordinates;
    final maxCoordinates = widget.zoneTeleport.maxCoordinates;
    final heading = widget.zoneTeleport.heading;
    final directionName = widget.projectContext.worldContext.getDirectionName(
      heading,
    );
    final fadeTime = widget.zoneTeleport.fadeTime;
    return WithKeyboardShortcuts(
      child: Cancel(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onChanged(null);
                },
                child: const Icon(
                  Icons.clear_outlined,
                  semanticLabel: 'Clear Teleport',
                ),
              )
            ],
            title: const Text('Edit Zone Teleport'),
          ),
          body: ListView(
            children: [
              ZoneListTile(
                projectContext: widget.projectContext,
                onDone: (zone) {
                  widget.zoneTeleport.zoneId = zone.id;
                  minCoordinates.clamp = null;
                  if (maxCoordinates != null) {
                    maxCoordinates.clamp = null;
                  }
                  save();
                },
                title: 'Destination Zone',
                zoneId: zoneId,
                autofocus: true,
              ),
              CoordinatesListTile(
                projectContext: widget.projectContext,
                zone: zone,
                value: minCoordinates,
                onChanged: save,
                title: maxCoordinates == null
                    ? 'Target Coordinates'
                    : 'Minimum Coordinates',
                canChangeClamp: true,
              ),
              maxCoordinates == null
                  ? ListTile(
                      title: const Text('Maximum Coordinates'),
                      subtitle: const Text('Not set'),
                      onTap: () async {
                        final coordinates = Coordinates(0, 0);
                        widget.zoneTeleport.maxCoordinates = coordinates;
                        await pushWidget(
                          context: context,
                          builder: (context) => EditCoordinates(
                            projectContext: widget.projectContext,
                            zone: zone,
                            value: coordinates,
                            actions: clearMaxCoordinatesActions,
                            canChangeClamp: true,
                          ),
                        );
                        save();
                      },
                    )
                  : CoordinatesListTile(
                      projectContext: widget.projectContext,
                      zone: zone,
                      value: maxCoordinates,
                      onChanged: save,
                      actions: clearMaxCoordinatesActions,
                      title: 'Maximum Coordinates',
                      canChangeClamp: true,
                    ),
              ListTile(
                title: const Text('Heading'),
                subtitle: Text('$directionName ($heading)'),
                onTap: () => pushWidget(
                    context: context,
                    builder: (context) => GetNumber(
                          value: heading.toDouble(),
                          onDone: (value) {
                            Navigator.pop(context);
                            widget.zoneTeleport.heading = value.floor();
                            save();
                          },
                          min: 0.0,
                          max: 360.0,
                          title: 'Heading',
                        )),
              ),
              NumberListTile(
                value: fadeTime?.toDouble() ?? 0.0,
                onChanged: (value) {
                  Navigator.pop(context);
                  widget.zoneTeleport.fadeTime = value == 0 ? null : value;
                  save();
                },
                min: 0.0,
                title: 'Fade Time',
              ),
            ],
          ),
        ),
      ),
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Adjust coordinates.',
          keyName: 'Arrow keys',
          alt: true,
        )
      ],
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
