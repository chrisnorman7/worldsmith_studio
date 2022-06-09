import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/searchable_list_view.dart';
import 'edit_quest.dart';

/// A widget for viewing quests.
class EditQuests extends StatefulWidget {
  /// Create an instance.
  const EditQuests({
    required this.projectContext,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  EditQuestsState createState() => EditQuestsState();
}

/// State for [EditQuests].
class EditQuestsState extends State<EditQuests> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final quests = world.quests;
    final Widget child;
    if (quests.isEmpty) {
      child = const CenterText(text: 'There are no quests to show.');
    } else {
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
                  builder: (final context) => EditQuest(
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
      child = SearchableListView(children: children);
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quests'),
        ),
        body: child,
        floatingActionButton: FloatingActionButton(
          autofocus: world.quests.isEmpty,
          onPressed: () async {
            final quest = Quest(
              id: newId(),
              name: 'Untitled Quest',
              stages: [],
            );
            world.quests.add(quest);
            widget.projectContext.save();
            await pushWidget(
              context: context,
              builder: (final context) => EditQuest(
                projectContext: widget.projectContext,
                quest: quest,
              ),
            );
            setState(() {});
          },
          tooltip: 'Add Quest',
          child: createIcon,
        ),
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
