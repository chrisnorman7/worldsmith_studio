import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../widgets/push_widget_list_tile.dart';
import '../conversation/project_conversation_categories.dart';
import '../npc/edit_npcs.dart';
import '../quest/edit_quests.dart';
import '../reverb/edit_reverbs.dart';
import '../scene/edit_scenes.dart';
import '../terrain/edit_terrains.dart';
import '../zone/edit_zones.dart';

/// A widget that shows the zone menu.
class BuildingMenu extends StatefulWidget {
  /// Create an instance.
  const BuildingMenu({
    required this.projectContext,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  BuildingMenuState createState() => BuildingMenuState();
}

/// State for [BuildingMenu].
class BuildingMenuState extends State<BuildingMenu> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    return ListView(
      children: [
        PushWidgetListTile(
          title: 'Terrains',
          builder: (final context) => EditTerrains(
            projectContext: widget.projectContext,
          ),
          subtitle: '${world.terrains.length}',
          autofocus: world.terrains.isEmpty,
        ),
        PushWidgetListTile(
          title: 'Zones',
          builder: (final context) => EditZones(
            projectContext: widget.projectContext,
          ),
          subtitle: '${world.zones.length}',
          autofocus: world.terrains.isNotEmpty,
        ),
        PushWidgetListTile(
          title: 'Scenes',
          builder: (final context) => EditScenes(
            projectContext: widget.projectContext,
          ),
          subtitle: '${world.scenes.length}',
        ),
        PushWidgetListTile(
          title: 'Conversations',
          builder: (final context) => ProjectConversationCategories(
            projectContext: widget.projectContext,
          ),
          subtitle: '${world.conversations.length}',
        ),
        PushWidgetListTile(
          title: "NPC's",
          builder: (final context) => EditNpcs(
            projectContext: widget.projectContext,
          ),
          subtitle: '${world.npcs.length}',
        ),
        PushWidgetListTile(
          title: 'Quests',
          builder: (final context) => EditQuests(
            projectContext: widget.projectContext,
          ),
          subtitle: '${world.quests.length}',
        ),
        PushWidgetListTile(
          title: 'Reverb Presets',
          builder: (final context) => EditReverbs(
            projectContext: widget.projectContext,
          ),
          subtitle: '${world.reverbs.length}',
        ),
      ],
    );
  }
}
