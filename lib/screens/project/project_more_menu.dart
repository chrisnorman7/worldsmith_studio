import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../command_triggers_list_view.dart';
import '../directions/directions_list.dart';
import '../equipment/equipment_positions_menu.dart';
import 'project_reverbs.dart';
import 'project_scenes.dart';

/// The "more" menu.
class ProjectMoreMenu extends StatefulWidget {
  /// Create an instance.
  const ProjectMoreMenu({
    required this.projectContext,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  ProjectMoreMenuState createState() => ProjectMoreMenuState();
}

/// State for [ProjectMoreMenu].
class ProjectMoreMenuState extends State<ProjectMoreMenu> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    return ListView(
      children: [
        ListTile(
          autofocus: true,
          title: const Text('Scenes'),
          subtitle: Text('${world.scenes.length}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (final context) =>
                  ProjectScenes(projectContext: widget.projectContext),
            );
            setState(() {});
          },
        ),
        ListTile(
          title: const Text('Equipment Positions'),
          subtitle: Text('${world.equipmentPositions.length}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (final context) =>
                  EquipmentPositionsMenu(projectContext: widget.projectContext),
            );
            setState(() {});
          },
        ),
        ListTile(
          title: const Text('Reverb Presets'),
          subtitle: Text('${world.reverbs.length}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (final context) => ProjectReverbs(
                projectContext: widget.projectContext,
              ),
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
              builder: (final context) =>
                  DirectionsList(projectContext: widget.projectContext),
            );
            setState(() {});
          },
        ),
        ListTile(
          title: const Text('Default Command Triggers'),
          onTap: () => pushWidget(
            context: context,
            builder: (final context) => const CommandTriggersListView(),
          ),
        )
      ],
    );
  }
}
