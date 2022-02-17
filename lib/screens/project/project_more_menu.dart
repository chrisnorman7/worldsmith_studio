import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../directions/directions_list.dart';
import '../equipment/equipment_positions_menu.dart';

/// The "more" menu.
class ProjectMoreMenu extends StatefulWidget {
  /// Create an instance.
  const ProjectMoreMenu({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _ProjectMoreMenuState createState() => _ProjectMoreMenuState();
}

/// State for [ProjectMoreMenu].
class _ProjectMoreMenuState extends State<ProjectMoreMenu> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    return ListView(
      children: [
        ListTile(
          autofocus: true,
          title: const Text('Equipment Positions'),
          subtitle: Text('${world.equipmentPositions.length}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (context) =>
                  EquipmentPositionsMenu(projectContext: widget.projectContext),
            );
            setState(() {});
          },
        ),
        ListTile(
          title: const Text('Directions'),
          subtitle: Text('${world.directions.length}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (context) =>
                  DirectionsList(projectContext: widget.projectContext),
            );
            setState(() {});
          },
        ),
      ],
    );
  }
}