import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/push_widget_list_tile.dart';
import '../../widgets/searchable_list_view.dart';
import 'edit_npc.dart';

/// A widget for editing [Npc] instances.
class EditNpcs extends StatefulWidget {
  /// Create an instance.
  const EditNpcs({
    required this.projectContext,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  EditNpcsState createState() => EditNpcsState();
}

/// State for [EditNpcs].
class EditNpcsState extends State<EditNpcs> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final npcs = world.npcs;
    final Widget child;
    if (npcs.isEmpty) {
      child = const CenterText(text: "There are no NPC's to show.");
    } else {
      final children = <SearchableListTile>[];
      for (var i = 0; i < npcs.length; i++) {
        final npc = npcs[i];
        children.add(
          SearchableListTile(
            searchString: npc.name,
            child: PushWidgetListTile(
              autofocus: i == 0,
              title: npc.name,
              builder: (final context) => EditNpc(
                projectContext: widget.projectContext,
                npc: npc,
              ),
            ),
          ),
        );
      }
      child = SearchableListView(children: children);
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("NPC's"),
        ),
        body: child,
        floatingActionButton: FloatingActionButton(
          autofocus: npcs.isEmpty,
          onPressed: () async {
            final npc = Npc(
              id: newId(),
              // ignore: prefer_const_constructors
              stats: Statistics(defaultStats: {}, currentStats: {}),
            );
            world.npcs.add(npc);
            widget.projectContext.save();
            await pushWidget(
              context: context,
              builder: (final context) => EditNpc(
                projectContext: widget.projectContext,
                npc: npc,
              ),
            );
            setState(() {});
          },
          tooltip: 'Add NPC',
          child: createIcon,
        ),
      ),
    );
  }
}
