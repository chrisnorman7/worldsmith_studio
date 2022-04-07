import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../conversation_location.dart';
import '../../project_context.dart';
import '../../screens/conversation/select_conversation.dart';
import '../play_sound_semantics.dart';
import '../push_widget_list_tile.dart';

/// A list tile for selecting a new conversation.
class ConversationListTile extends StatelessWidget {
  /// Create an instance.
  const ConversationListTile({
    required this.projectContext,
    required this.value,
    required this.onChanged,
    this.title = 'Conversation',
    this.autofocus = false,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The ID of the current conversation.
  final String? value;

  /// The function to call with the new conversation.
  final ValueChanged<Conversation?> onChanged;

  /// The title of the resulting [ListTile].
  final String title;

  /// Whether the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final world = projectContext.world;
    final id = value;
    final conversation = id == null ? null : world.getConversation(id);
    final branch = conversation?.initialBranch;
    final sound = branch?.sound;
    final assetReference = sound == null
        ? null
        : getAssetReferenceReference(
            assets: world.conversationAssets,
            id: sound.id,
          ).reference;
    final location = conversation == null
        ? null
        : ConversationLocation.find(
            world: world,
            conversationId: conversation.id,
          );
    return PlaySoundSemantics(
      soundChannel: projectContext.game.interfaceSounds,
      assetReference: assetReference,
      gain: sound?.gain ?? world.soundOptions.defaultGain,
      child: PushWidgetListTile(
        autofocus: autofocus,
        title: title,
        subtitle: conversation == null ? 'Not set' : conversation.name,
        builder: (final context) => SelectConversation(
          projectContext: projectContext,
          onDone: (final value) => onChanged(value?.conversation),
          location: location,
        ),
      ),
    );
  }
}
