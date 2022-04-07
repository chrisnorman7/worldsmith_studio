import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
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
        ListTile(
          autofocus: world.terrains.isEmpty,
          title: const Text('Terrains'),
          subtitle: Text('${world.terrains.length}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (final context) => EditTerrains(
                projectContext: widget.projectContext,
              ),
            );
            setState(() {});
          },
        ),
        ListTile(
          autofocus: world.terrains.isNotEmpty,
          title: const Text('Zones'),
          subtitle: Text('${world.zones.length}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (final context) => EditZones(
                projectContext: widget.projectContext,
              ),
            );
            setState(() {});
          },
        ),
        ListTile(
          title: const Text('Scenes'),
          subtitle: Text('${world.scenes.length}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (final context) =>
                  EditScenes(projectContext: widget.projectContext),
            );
            setState(() {});
          },
        ),
        ListTile(
          title: const Text('Conversations'),
          subtitle: Text('${world.conversations.length}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (final context) => ProjectConversationCategories(
                projectContext: widget.projectContext,
              ),
            );
            setState(() {});
          },
        ),
        ListTile(
          title: const Text("NPC's"),
          subtitle: Text('${world.npcs.length}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (final context) => EditNpcs(
                projectContext: widget.projectContext,
              ),
            );
            setState(() {});
          },
        ),
        ListTile(
          title: const Text('Quests'),
          subtitle: Text('${world.quests.length}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (final context) =>
                  EditQuests(projectContext: widget.projectContext),
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
              builder: (final context) => EditReverbs(
                projectContext: widget.projectContext,
              ),
            );
            setState(() {});
          },
        ),
      ],
    );
  }
}
