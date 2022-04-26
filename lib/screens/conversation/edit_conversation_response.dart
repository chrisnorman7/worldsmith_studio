// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/command/call_command_list_tile.dart';
import '../../widgets/conversation/conversation_next_branch_list_tile.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing a conversation [response].
class EditConversationResponse extends StatefulWidget {
  /// Create an instance.
  const EditConversationResponse({
    required this.projectContext,
    required this.conversation,
    required this.response,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The conversation to work with.
  final Conversation conversation;

  /// The conversation response to edit.
  final ConversationResponse response;

  /// Create state for this widget.
  @override
  EditConversationResponseState createState() =>
      EditConversationResponseState();
}

/// State for [EditConversationResponse].
class EditConversationResponseState extends State<EditConversationResponse> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Conversation Response'),
        ),
        body: ListView(
          children: [
            TextListTile(
              value: widget.response.text ?? '',
              onChanged: (final value) {
                if (value.isEmpty) {
                  widget.response.text = null;
                } else {
                  widget.response.text = value;
                }
                save();
              },
              header: 'Text',
              autofocus: true,
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: widget.response.sound,
              onDone: (final value) {
                widget.response.sound = value;
                save();
              },
              assetStore: world.conversationAssetStore,
              defaultGain: world.soundOptions.defaultGain,
              nullable: true,
            ),
            ConversationNextBranchListTile(
              projectContext: widget.projectContext,
              conversation: widget.conversation,
              response: widget.response,
              nextBranch: widget.response.nextBranch,
              onChanged: (final value) {
                widget.response.nextBranch = value;
                save();
              },
            ),
            CallCommandListTile(
              projectContext: widget.projectContext,
              callCommand: widget.response.command,
              onChanged: (final value) {
                widget.response.command = value;
                save();
              },
            )
          ],
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
