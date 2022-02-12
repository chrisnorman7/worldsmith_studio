import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/center_text.dart';

/// A widget for displaying and editing [Zone] instances.
class ProjectZones extends StatefulWidget {
  /// Create an instance.
  const ProjectZones({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _ProjectZonesState createState() => _ProjectZonesState();
}

/// State for [ProjectZones].
class _ProjectZonesState extends State<ProjectZones> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    if (world.zones.isEmpty) {
      return const CenterText(text: 'There are no zones yet.');
    }
    return ListView.builder(
      itemBuilder: (context, index) {
        final zone = world.zones[index];
        return ListTile(
          autofocus: index == 0,
          title: Text(zone.name),
          subtitle: Text('Boxes: ${zone.boxes.length}'),
        );
      },
      itemCount: world.zones.length,
    );
  }
}
