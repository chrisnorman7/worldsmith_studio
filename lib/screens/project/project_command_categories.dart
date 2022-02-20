import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/center_text.dart';

/// A widget for showing the [CommandCategory] list.
class ProjectCommandCategories extends StatefulWidget {
  /// Create an instance.
  const ProjectCommandCategories({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _ProjectCommandCategoriesState createState() =>
      _ProjectCommandCategoriesState();
}

/// State for [ProjectCommandCategories].
class _ProjectCommandCategoriesState extends State<ProjectCommandCategories> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final categories = widget.projectContext.world.commandCategories;
    if (categories.isEmpty) {
      return const CenterText(text: 'There are no command categories to show.');
    }
    return GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
      itemBuilder: (context, index) {
        final category = categories[index];
        return GridTile(
          child: TextButton(
            onPressed: () {},
            child: Text(category.name),
          ),
        );
      },
      itemCount: categories.length,
    );
  }
}
