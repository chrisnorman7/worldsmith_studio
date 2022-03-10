import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/get_text.dart';
import '../../widgets/searchable_list_view.dart';
import 'edit_conversation_category.dart';

/// A widget for displaying [ConversationCategory] instances.
class EditConversationCategories extends StatefulWidget {
  /// Create an instance.
  const EditConversationCategories({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _EditConversationCategoriesState createState() =>
      _EditConversationCategoriesState();
}

/// State for [EditConversationCategories].
class _EditConversationCategoriesState
    extends State<EditConversationCategories> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final categories = world.conversationCategories;
    final Widget child;
    if (categories.isEmpty) {
      child = const CenterText(text: 'There are no conversation categories.');
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
                      builder: (context) => GetText(
                        onDone: (value) {
                          Navigator.pop(context);
                          category.name = value;
                          save();
                        },
                        labelText: 'Name',
                        text: category.name,
                        title: 'Rename Conversation Category',
                        validator: (value) => validateNonEmptyValue(
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
                          (element) => element.id == category.id,
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
                    builder: (context) => EditConversationCategory(
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
      child = SearchableListView(children: children);
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Conversation Categories'),
        ),
        body: child,
        floatingActionButton: FloatingActionButton(
          autofocus: categories.isEmpty,
          child: createIcon,
          onPressed: () async {
            final category = ConversationCategory(
              id: newId(),
              name: 'Untitled Category',
              conversations: [],
            );
            world.conversationCategories.add(category);
            widget.projectContext.save();
            setState(() {});
          },
          tooltip: 'Add Conversation Category',
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
