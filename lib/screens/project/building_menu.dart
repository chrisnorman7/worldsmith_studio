import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../npc/edit_npcs.dart';
import 'edit_zones.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Building'),
      ),
      body: ListView(
        children: [
          ListTile(
            autofocus: true,
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
          )
        ],
      ),
    );
  }
}
