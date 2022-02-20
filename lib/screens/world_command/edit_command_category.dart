import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/get_text.dart';

/// A widget for viewing and editing its [category].
class EditCommandCategory extends StatefulWidget {
  /// Create an instance.
  const EditCommandCategory({
    required this.projectContext,
    required this.category,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The category to edit.
  final CommandCategory category;

  /// Create state for this widget.
  @override
  _EditCommandCategoryState createState() => _EditCommandCategoryState();
}

/// State for [EditCommandCategory].
class _EditCommandCategoryState extends State<EditCommandCategory> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final commands = widget.category.commands;
    final Widget child;
    if (commands.isEmpty) {
      child = const CenterText(text: 'There are no commands in this category.');
    } else {
      child = GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
        itemBuilder: (context, index) {
          final command = commands[index];
          return GridTile(
            child: TextButton(
              onPressed: () {},
              child: Text(command.name),
            ),
          );
        },
        itemCount: commands.length,
      );
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () => pushWidget(
                context: context,
                builder: (context) => GetText(
                  onDone: (value) {
                    widget.category.name = value;
                    save();
                  },
                  labelText: 'Name',
                  text: widget.category.name,
                  title: 'Rename Category',
                ),
              ),
              child: const Icon(
                Icons.drive_file_rename_outline_rounded,
                semanticLabel: 'Rename Category',
              ),
            )
          ],
          title: Text(widget.category.name),
        ),
        body: child,
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
