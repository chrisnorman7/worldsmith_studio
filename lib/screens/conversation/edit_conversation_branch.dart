import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing a conversation [branch].
class EditConversationBranch extends StatefulWidget {
  /// Create an instance.
  const EditConversationBranch({
    required this.projectContext,
    required this.branch,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The conversation branch to edit.
  final ConversationBranch branch;

  /// Create state for this widget.
  @override
  _EditConversationBranchState createState() => _EditConversationBranchState();
}

/// State for [EditConversationBranch].
class _EditConversationBranchState extends State<EditConversationBranch> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Conversation Branch'),
        ),
        body: ListView(
          children: [
            TextListTile(
              value: widget.branch.text ?? '',
              onChanged: (value) {
                if (value.isEmpty) {
                  widget.branch.text = null;
                } else {
                  widget.branch.text = value;
                }
                save();
              },
              header: 'Text',
              autofocus: true,
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: widget.branch.sound,
              onDone: (value) {
                widget.branch.sound = value;
                save();
              },
              assetStore: world.conversationAssetStore,
              defaultGain: world.soundOptions.defaultGain,
              nullable: true,
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
