import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/center_text.dart';
import '../../widgets/get_text.dart';
import '../../widgets/searchable_list_view.dart';
import 'edit_conversation_category.dart';

/// A widget for displaying [ConversationCategory] instances.
class ProjectConversationCategories extends StatefulWidget {
  /// Create an instance.
  const ProjectConversationCategories({
    required this.projectContext,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  ProjectConversationCategoriesState createState() =>
      ProjectConversationCategoriesState();
}

/// State for [ProjectConversationCategories].
class ProjectConversationCategoriesState
    extends State<ProjectConversationCategories> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final categories = world.conversationCategories;
    if (categories.isEmpty) {
      return const CenterText(text: 'There are no conversation categories.');
    } else {
      final children = <SearchableListTile>[];
      for (var i = 0; i < categories.length; i++) {
        final category = categories[i];
        children.add(
          SearchableListTile(
            searchString: category.name,
            child: CallbackShortcuts(
              bindings: {
                RenameIntent.hotkey: () => pushWidget(
                      context: context,
                      builder: (final context) => GetText(
                        onDone: (final value) {
                          Navigator.pop(context);
                          category.name = value;
                          save();
                        },
                        labelText: 'Name',
                        text: category.name,
                        title: 'Rename Conversation Category',
                        validator: (final value) => validateNonEmptyValue(
                          value: value,
                        ),
                      ),
                    ),
                DeleteIntent.hotkey: () {
                  if (category.conversations.isEmpty) {
                    confirm(
                      context: context,
                      message: 'Are you sure you want to delete the '
                          '${category.name} category?',
                      title: 'Delete Conversation Category',
                      yesCallback: () {
                        Navigator.pop(context);
                        world.conversationCategories.removeWhere(
                          (final element) => element.id == category.id,
                        );
                        save();
                      },
                    );
                  } else {
                    showError(
                      context: context,
                      message: 'You can only delete empty categories.',
                    );
                  }
                }
              },
              child: ListTile(
                autofocus: i == 0,
                title: Text(category.name),
                onTap: () async {
                  await pushWidget(
                    context: context,
                    builder: (final context) => EditConversationCategory(
                      projectContext: widget.projectContext,
                      conversationCategory: category,
                    ),
                  );
                  setState(() {});
                },
              ),
            ),
          ),
        );
      }
      return SearchableListView(children: children);
    }
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
