import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/conversation/conversation_list_tile.dart';
import '../../widgets/number_list_tile.dart';

/// A widget for editing a [startConversation].
class EditStartConversation extends StatefulWidget {
  /// Create an instance.
  const EditStartConversation({
    required this.projectContext,
    required this.startConversation,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The start conversation to edit.
  final StartConversation startConversation;

  /// The function to be called when [startConversation] changes.
  final ValueChanged<StartConversation?> onChanged;

  /// Create state for this widget.
  @override
  _EditStartConversationState createState() => _EditStartConversationState();
}

/// State for [EditStartConversation].
class _EditStartConversationState extends State<EditStartConversation> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final fadeTime = widget.startConversation.fadeTime;
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onChanged(null);
            },
            child: const Icon(
              Icons.clear,
              semanticLabel: 'Clear Start Conversation',
            ),
          )
        ],
        title: const Text('Start A Conversation'),
      ),
      body: ListView(
        children: [
          ConversationListTile(
            projectContext: widget.projectContext,
            value: widget.startConversation.conversationId,
            onChanged: (value) {
              if (value == null) {
                Navigator.pop(context);
                widget.onChanged(null);
              } else {
                widget.startConversation.conversationId = value.id;
                save();
              }
              save();
            },
            autofocus: true,
          ),
          NumberListTile(
            value: fadeTime?.toDouble() ?? 0.0,
            onChanged: (value) {
              final i = value.floor();
              if (i == 0) {
                widget.startConversation.fadeTime = null;
              } else {
                widget.startConversation.fadeTime = i;
              }
              save();
            },
            min: 0.0,
            title: 'Fade Time',
            subtitle: '$fadeTime millisecond${fadeTime == 1 ? "" : "s"}',
          )
        ],
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
