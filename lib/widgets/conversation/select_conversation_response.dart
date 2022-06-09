import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../keyboard_shortcuts_list.dart';
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
    super.key,
  });

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
  SelectConversationResponseState createState() =>
      SelectConversationResponseState();
}

/// State for [SelectConversationResponse].
class SelectConversationResponseState
    extends State<SelectConversationResponse> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    return WithKeyboardShortcuts(
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Add a new response',
          keyName: 'A',
          control: true,
        )
      ],
      child: CallbackShortcuts(
        bindings: {AddIntent.hotkey: addResponse},
        child: SelectItem<ConversationResponse>(
          onDone: widget.onDone,
          values: widget.conversation.responses
              .where(
                (final element) =>
                    widget.ignoredResponses.contains(element.id) == false,
              )
              .toList(),
          getItemWidget: (final item) {
            final sound = item.sound;
            return PlaySoundSemantics(
              soundChannel: widget.projectContext.game.interfaceSounds,
              assetReference: sound == null
                  ? null
                  : getAssetReferenceReference(
                      assets: world.conversationAssets,
                      id: sound.id,
                    ).reference,
              gain: sound?.gain ?? world.soundOptions.defaultGain,
              child: Text('${item.text}'),
            );
          },
          actions: [
            ElevatedButton(
              onPressed: addResponse,
              child: const Icon(
                Icons.add,
                semanticLabel: 'Add Response',
              ),
            )
          ],
          title: 'Select Response',
        ),
      ),
    );
  }

  /// Add a new conversation response.
  void addResponse() {
    setState(() {
      widget.conversation.responses.add(
        ConversationResponse(id: newId()),
      );
      widget.projectContext.save();
    });
  }
}
