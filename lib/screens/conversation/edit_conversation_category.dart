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

/// A widget for editing the given [conversationCategory].
class EditConversationCategory extends StatefulWidget {
  /// Create an instance.
  const EditConversationCategory({
    required this.projectContext,
    required this.conversationCategory,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The conversation category to edit.
  final ConversationCategory conversationCategory;

  /// Create state for this widget.
  @override
  _EditConversationCategoryState createState() =>
      _EditConversationCategoryState();
}

/// State for [EditConversationCategory].
class _EditConversationCategoryState extends State<EditConversationCategory> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final Widget child;
    final conversations = widget.conversationCategory.conversations;
    if (conversations.isEmpty) {
      child = const CenterText(text: 'There are no conversations to show.');
    } else {
      final children = <SearchableListTile>[];
      for (var i = 0; i < conversations.length; i++) {
        final conversation = conversations[i];
        children.add(
          SearchableListTile(
            searchString: conversation.name,
            child: CallbackShortcuts(
                bindings: {
                  RenameIntent.hotkey: () => pushWidget(
                        context: context,
                        builder: (context) => GetText(
                          onDone: (value) {
                            conversation.name = value;
                            Navigator.pop(context);
                            save();
                          },
                          labelText: 'Name',
                          text: conversation.name,
                          title: 'Rename Conversation',
                          validator: (value) =>
                              validateNonEmptyValue(value: value),
                        ),
                      )
                },
                child: ListTile(
                  autofocus: i == 0,
                  title: Text(conversation.name),
                  onTap: () {},
                )),
          ),
        );
      }
      child = SearchableListView(children: children);
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
                    widget.conversationCategory.name = value;
                    widget.projectContext.save();
                    Navigator.pop(context);
                  },
                  labelText: 'Name',
                  text: widget.conversationCategory.name,
                  title: 'Rename Conversation Category',
                  validator: (value) => validateNonEmptyValue(value: value),
                ),
              ),
              child: const Icon(
                Icons.drive_file_rename_outline,
                semanticLabel: 'Rename Category',
              ),
            )
          ],
          title: const Text('Edit Conversation Category'),
        ),
        body: child,
        floatingActionButton: FloatingActionButton(
          autofocus: conversations.isEmpty,
          child: createIcon,
          onPressed: () async {
            final branch = ConversationBranch(
              id: newId(),
              message: CustomMessage(text: 'I need changing.'),
              responseIds: [],
            );
            final conversation = Conversation(
              id: newId(),
              name: 'Untitled Conversation',
              branches: [branch],
              initialBranchId: branch.id,
              responses: [],
            );
            conversations.add(conversation);
            widget.projectContext.save();
            setState(() {});
          },
          tooltip: 'Add Conversation',
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
