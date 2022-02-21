import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../box/coordinates_list_tile.dart';
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
    final zoneId = widget.zoneTeleport.zoneId;
    final zone = widget.projectContext.world.getZone(zoneId);
    final minCoordinates = widget.zoneTeleport.minCoordinates;
    final maxCoordinates = widget.zoneTeleport.maxCoordinates;
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
                title: 'Minimum Coordinates',
              ),
              maxCoordinates == null
                  ? ListTile(
                      title: const Text('Maximum Coordinates'),
                      subtitle: const Text('Not set'),
                      onTap: () {
                        widget.zoneTeleport.maxCoordinates = Coordinates(0, 0);
                        save();
                      },
                    )
                  : CoordinatesListTile(
                      projectContext: widget.projectContext,
                      zone: zone,
                      value: maxCoordinates,
                      onChanged: save,
                      actions: [
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
                      ],
                      title: 'Maximum Coordinates',
                    )
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
