import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/center_text.dart';
import '../../widgets/searchable_list_view.dart';
import '../world_command/edit_command_category.dart';

/// A widget for showing the [CommandCategory] list.
class ProjectCommandCategories extends StatefulWidget {
  /// Create an instance.
  const ProjectCommandCategories({
    required this.projectContext,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  ProjectCommandCategoriesState createState() =>
      ProjectCommandCategoriesState();
}

/// State for [ProjectCommandCategories].
class ProjectCommandCategoriesState extends State<ProjectCommandCategories> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final categories = widget.projectContext.world.commandCategories;
    if (categories.isEmpty) {
      return const CenterText(text: 'There are no command categories to show.');
    }
    final children = <SearchableListTile>[];
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      children.add(
        SearchableListTile(
          searchString: category.name,
          child: ListTile(
            autofocus: i == 0,
            title: Text(category.name),
            onTap: () async {
              await pushWidget(
                context: context,
                builder: (final context) => EditCommandCategory(
                  projectContext: widget.projectContext,
                  category: category,
                ),
              );
              save();
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
