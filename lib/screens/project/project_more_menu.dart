// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../widgets/push_widget_list_tile.dart';
import '../command_triggers/custom_command_triggers.dart';
import '../command_triggers/default_command_triggers_list_view.dart';
import '../directions/directions_list.dart';
import '../equipment/equipment_positions_menu.dart';
import '../stats/edit_world_stats.dart';

/// The "more" menu.
class ProjectMoreMenu extends StatefulWidget {
  /// Create an instance.
  const ProjectMoreMenu({
    required this.projectContext,
    super.key,
  });

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
        PushWidgetListTile(
          autofocus: true,
          title: 'Equipment Positions',
          subtitle: '${world.equipmentPositions.length}',
          builder: (final context) => EquipmentPositionsMenu(
            projectContext: widget.projectContext,
          ),
        ),
        PushWidgetListTile(
          title: 'Stats',
          subtitle: '${world.stats.length}',
          builder: (final context) => EditWorldStats(
            projectContext: widget.projectContext,
          ),
        ),
        PushWidgetListTile(
          title: 'Directions',
          subtitle: '${world.directions.length}',
          builder: (final context) => DirectionsList(
            projectContext: widget.projectContext,
          ),
        ),
        PushWidgetListTile(
          title: 'Default Command Triggers',
          subtitle: '${world.defaultCommandTriggers.length}',
          builder: (final context) => DefaultCommandTriggersListView(
            projectContext: widget.projectContext,
          ),
        ),
        PushWidgetListTile(
          title: 'Custom Command Triggers',
          builder: (context) => CustomCommandTriggers(
            projectContext: widget.projectContext,
          ),
          subtitle: '${world.customCommandTriggers.length}',
        )
      ],
    );
  }
}
