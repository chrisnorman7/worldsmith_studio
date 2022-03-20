import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../screens/conversation/edit_conversation.dart';
import '../../screens/conversation/edit_start_conversation.dart';
import '../../screens/conversation/select_conversation.dart';
import '../../util.dart';
import '../play_sound_semantics.dart';

/// A list for showing a [startConversation].
class StartConversationListTile extends StatefulWidget {
  /// Create an instance.
  const StartConversationListTile({
    required this.projectContext,
    required this.startConversation,
    required this.onChanged,
    this.autofocus = false,
    this.title = 'Start Conversation',
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The start conversation to edit.
  final StartConversation? startConversation;

  /// The function to call when [startConversation] changes.
  final ValueChanged<StartConversation?> onChanged;

  /// Whether the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// The title of the resulting [ListTile].
  final String title;

  /// Create state for this widget.
  @override
  StartConversationListTileState createState() =>
      StartConversationListTileState();
}

/// State for [StartConversationListTile].
class StartConversationListTileState extends State<StartConversationListTile> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final conversationId = widget.startConversation?.conversationId;
    final conversation = conversationId == null
        ? null
        : widget.projectContext.world.getConversation(conversationId);
    final branch = conversation?.initialBranch;
    final sound = branch?.sound;
    final assetReference = sound == null
        ? null
        : getAssetReferenceReference(
                assets: widget.projectContext.world.conversationAssets,
                id: sound.id)
            .reference;
    return CallbackShortcuts(
      bindings: {
        EditIntent.hotkey: () async {
          if (conversation != null) {
            await pushWidget(
              context: context,
              builder: (context) => EditConversation(
                projectContext: widget.projectContext,
                category: widget.projectContext.world.conversationCategories
                    .firstWhere(
                  (element) => element.conversations
                      .where((element) => element.id == conversation.id)
                      .isNotEmpty,
                ),
                conversation: conversation,
              ),
            );
            setState(() {});
          }
        }
      },
      child: PlaySoundSemantics(
        soundChannel: widget.projectContext.game.interfaceSounds,
        assetReference: assetReference,
        gain: sound?.gain ?? 0.0,
        child: ListTile(
          autofocus: widget.autofocus,
          title: Text(widget.title),
          subtitle: Text(
            conversation == null
                ? 'Not set'
                : '${conversation.name} '
                    '(${widget.startConversation?.fadeTime})',
          ),
          onTap: () async {
            final startConversation = widget.startConversation;
            if (startConversation == null) {
              await pushWidget(
                context: context,
                builder: (context) => SelectConversation(
                  projectContext: widget.projectContext,
                  onDone: (value) {
                    if (value == null) {
                      widget.onChanged(null);
                    } else {
                      widget.onChanged(
                        StartConversation(
                            conversationId: value.conversation.id),
                      );
                    }
                  },
                ),
              );
            } else {
              await pushWidget(
                context: context,
                builder: (context) => EditStartConversation(
                  projectContext: widget.projectContext,
                  startConversation: startConversation,
                  onChanged: widget.onChanged,
                ),
              );
            }
            setState(() {});
          },
        ),
      ),
    );
  }
}
