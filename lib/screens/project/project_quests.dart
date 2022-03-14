import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/center_text.dart';
import '../../widgets/searchable_list_view.dart';
import '../quest/edit_quest.dart';

/// A widget for viewing quests.
class ProjectQuests extends StatefulWidget {
  /// Create an instance.
  const ProjectQuests({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _ProjectQuestsState createState() => _ProjectQuestsState();
}

/// State for [ProjectQuests].
class _ProjectQuestsState extends State<ProjectQuests> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final quests = world.quests;
    if (quests.isEmpty) {
      return const CenterText(text: 'There are no quests to show.');
    }
    final children = <SearchableListTile>[];
    for (var i = 0; i < world.quests.length; i++) {
      final quest = world.quests[i];
      children.add(
        SearchableListTile(
          searchString: quest.name,
          child: ListTile(
            autofocus: i == 0,
            title: Text(quest.name),
            onTap: () async {
              await pushWidget(
                context: context,
                builder: (context) => EditQuest(
                  projectContext: widget.projectContext,
                  quest: quest,
                ),
              );
              setState(() {});
            },
          ),
        ),
      );
    }
    return SearchableListView(children: children);
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
