import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/conversation/conversation_response_list_tile.dart';
import '../../widgets/conversation/edit_conversation_branch_list_tile.dart';
import '../../widgets/conversation/select_conversation_branch_list_tile.dart';
import '../../widgets/searchable_list_view.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/tabbed_scaffold.dart';
import '../../widgets/text_list_tile.dart';
import 'edit_conversation_branch.dart';
import 'edit_conversation_response.dart';

/// A widget for editing a [conversation] in the given [category].
class EditConversation extends StatefulWidget {
  /// Create an instance.
  const EditConversation({
    required this.projectContext,
    required this.category,
    required this.conversation,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The category where [conversation] is.
  final ConversationCategory category;

  /// The conversation to edit.
  final Conversation conversation;

  /// Create state for this widget.
  @override
  _EditConversationState createState() => _EditConversationState();
}

/// State for [EditConversation].
class _EditConversationState extends State<EditConversation> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final initialBranch =
        widget.conversation.getBranch(widget.conversation.initialBranchId);
    return Cancel(
      child: TabbedScaffold(
        tabs: [
          TabbedScaffoldTab(
            title: 'Conversation Settings',
            icon: const Icon(Icons.settings_outlined),
            builder: (context) => ListView(
              children: [
                TextListTile(
                  value: widget.conversation.name,
                  onChanged: (value) {
                    widget.conversation.name = value;
                    save();
                  },
                  header: 'Conversation Name',
                  autofocus: true,
                  labelText: 'Name',
                  validator: (value) => validateNonEmptyValue(value: value),
                ),
                SoundListTile(
                  projectContext: widget.projectContext,
                  value: widget.conversation.music,
                  onDone: (value) {
                    widget.conversation.music = value;
                    save();
                  },
                  assetStore: world.musicAssetStore,
                  defaultGain: world.soundOptions.defaultGain,
                  looping: true,
                  nullable: true,
                  title: 'Music',
                ),
                SelectConversationBranchListTile(
                  projectContext: widget.projectContext,
                  branch: initialBranch,
                  conversation: widget.conversation,
                  title: 'Initial Branch',
                  onChanged: (branch) {
                    Navigator.pop(context);
                    widget.conversation.initialBranchId = branch.id;
                    save();
                  },
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  confirm(
                    context: context,
                    message:
                        'Are you sure you want to delete this conversation?',
                    title: 'Delete Conversation',
                    yesCallback: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      widget.category.conversations.removeWhere(
                        (element) => element.id == widget.conversation.id,
                      );
                      widget.projectContext.save();
                    },
                  );
                },
                child: const Icon(
                  Icons.delete_outlined,
                  semanticLabel: 'Delete Conversation',
                ),
              )
            ],
          ),
          TabbedScaffoldTab(
            title: 'Branches',
            icon: const Icon(Icons.question_answer_outlined),
            builder: (context) {
              final branches = widget.conversation.branches;
              final children = <SearchableListTile>[];
              for (var i = 0; i < branches.length; i++) {
                final branch = branches[i];
                children.add(
                  SearchableListTile(
                    searchString: branch.text ?? 'Untitled Branch',
                    child: EditConversationBranchListTile(
                      autofocus: i == 0,
                      conversation: widget.conversation,
                      branch: branch,
                      projectContext: widget.projectContext,
                    ),
                  ),
                );
              }
              return CallbackShortcuts(
                child: SearchableListView(children: children),
                bindings: {
                  CreateConversationBranchIntent.hotkey: () =>
                      addConversationBranch(context)
                },
              );
            },
            floatingActionButton: FloatingActionButton(
              onPressed: () => addConversationBranch(context),
              child: createIcon,
              tooltip: 'Add Branch',
            ),
          ),
          TabbedScaffoldTab(
            title: 'Responses',
            icon: const Icon(Icons.reply_outlined),
            builder: (context) {
              final responses = widget.conversation.responses;
              if (responses.isEmpty) {
                return const CenterText(
                    text: 'There are no responses to show.');
              }
              final children = <SearchableListTile>[];
              for (var i = 0; i < responses.length; i++) {
                final response = responses[i];
                children.add(
                  SearchableListTile(
                    searchString:
                        response.text ?? 'Untitled Conversation Response',
                    child: ConversationResponseListTile(
                      autofocus: i == 0,
                      projectContext: widget.projectContext,
                      conversation: widget.conversation,
                      response: response,
                    ),
                  ),
                );
              }
              return CallbackShortcuts(
                child: SearchableListView(children: children),
                bindings: {
                  CreateConversationResponse.hotkey: () =>
                      addConversationResponse(context),
                },
              );
            },
            floatingActionButton: FloatingActionButton(
              autofocus: widget.conversation.responses.isEmpty,
              onPressed: () => addConversationResponse(context),
              child: createIcon,
              tooltip: 'Add Response',
            ),
          ),
        ],
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Add a conversation response.
  Future<void> addConversationResponse(BuildContext context) async {
    final response = ConversationResponse(
      id: newId(),
      text: 'Change me',
    );
    widget.conversation.responses.add(response);
    widget.projectContext.save();
    await pushWidget(
      context: context,
      builder: (context) => EditConversationResponse(
        projectContext: widget.projectContext,
        conversation: widget.conversation,
        response: response,
      ),
    );
    setState(() {});
  }

  /// Add a new conversation branch.
  Future<void> addConversationBranch(BuildContext context) async {
    final branch = ConversationBranch(id: newId(), responseIds: []);
    widget.conversation.branches.add(branch);
    widget.projectContext.save();
    await pushWidget(
      context: context,
      builder: (context) => EditConversationBranch(
        projectContext: widget.projectContext,
        conversation: widget.conversation,
        branch: branch,
      ),
    );
    setState(() {});
  }
}
