import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../play_sound_semantics.dart';
import '../select_item.dart';

/// A widget for selecting a conversation response from [conversation].
class SelectConversationResponse extends StatefulWidget {
  /// Create an instance.
  const SelectConversationResponse({
    required this.projectContext,
    required this.conversation,
    required this.onDone,
    this.ignoredResponses = const [],
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The conversation to use.
  final Conversation conversation;

  /// The function to be called with the result.
  final ValueChanged<ConversationResponse> onDone;

  /// The responses to offer up.
  ///
  /// If this value is `null`, then the full list of responses from the
  /// [conversation] will be used.
  final List<String> ignoredResponses;

  /// Create state for this widget.
  @override
  _SelectConversationResponseState createState() =>
      _SelectConversationResponseState();
}

/// State for [SelectConversationResponse].
class _SelectConversationResponseState
    extends State<SelectConversationResponse> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    return SelectItem<ConversationResponse>(
      onDone: widget.onDone,
      values: widget.conversation.responses
          .where(
            (element) => widget.ignoredResponses.contains(element.id) == false,
          )
          .toList(),
      getItemWidget: (item) {
        final sound = item.sound;
        return PlaySoundSemantics(
          child: Text('${item.text}'),
          soundChannel: widget.projectContext.game.interfaceSounds,
          assetReference: sound == null
              ? null
              : getAssetReferenceReference(
                  assets: world.conversationAssets,
                  id: sound.id,
                ).reference,
          gain: sound?.gain ?? world.soundOptions.defaultGain,
        );
      },
      actions: [
        ElevatedButton(
          onPressed: () async {
            setState(() {
              widget.conversation.responses.add(
                ConversationResponse(id: newId()),
              );
              widget.projectContext.save();
            });
          },
          child: const Icon(
            Icons.add,
            semanticLabel: 'Add Response',
          ),
        )
      ],
      title: 'Select Response',
    );
  }
}
