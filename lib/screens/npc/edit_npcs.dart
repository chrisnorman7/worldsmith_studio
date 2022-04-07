import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/searchable_list_view.dart';

/// A widget for editing [Npc] instances.
class EditNpcs extends StatefulWidget {
  /// Create an instance.
  const EditNpcs({
    required this.projectContext,
    final Key? key,
  }) : super(key: key);

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
    final npcs = widget.projectContext.world.npcs;
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
            child: ListTile(
              autofocus: i == 0,
              title: Text(npc.name),
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
      ),
    );
  }
}
