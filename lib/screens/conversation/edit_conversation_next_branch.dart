import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/conversation/select_conversation_branch_list_tile.dart';
import '../../widgets/number_list_tile.dart';

/// A widget for editing a conversation [nextBranch].
class EditConversationNextBranch extends StatefulWidget {
  /// Create an instance.
  const EditConversationNextBranch({
    required this.projectContext,
    required this.conversation,
    required this.response,
    required this.nextBranch,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The conversation to work with.
  final Conversation conversation;

  /// The response that [nextBranch] belongs to.
  final ConversationResponse response;

  /// The next branch instance to edit.
  final ConversationNextBranch nextBranch;

  /// Create state for this widget.
  @override
  EditConversationNextBranchState createState() =>
      EditConversationNextBranchState();
}

/// State for [EditConversationNextBranch].
class EditConversationNextBranchState
    extends State<EditConversationNextBranch> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) => Cancel(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.response.nextBranch = null;
                  widget.projectContext.save();
                },
                child: const Icon(
                  Icons.clear_outlined,
                  semanticLabel: 'Clear Next Branch',
                ),
              )
            ],
            title: const Text('Next Branch'),
          ),
          body: ListView(
            children: [
              SelectConversationBranchListTile(
                projectContext: widget.projectContext,
                conversation: widget.conversation,
                branch: widget.conversation.getBranch(
                  widget.nextBranch.branchId,
                ),
                onChanged: (final value) {
                  Navigator.pop(context);
                  widget.nextBranch.branchId = value.id;
                  save();
                },
                autofocus: true,
              ),
              NumberListTile(
                value: widget.nextBranch.fadeTime,
                onChanged: (final value) {
                  widget.nextBranch.fadeTime = value;
                  save();
                },
                min: 0.1,
                title: 'Transition Time',
                subtitle: '${widget.nextBranch.fadeTime} seconds',
              )
            ],
          ),
        ),
      );

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
