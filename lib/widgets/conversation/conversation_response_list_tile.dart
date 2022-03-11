import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../screens/conversation/edit_conversation_response.dart';
import '../../util.dart';
import '../play_sound_semantics.dart';

/// A widget for showing and editing the given conversation [response].
class ConversationResponseListTile extends StatefulWidget {
  /// Create an instance.
  const ConversationResponseListTile({
    required this.projectContext,
    required this.conversation,
    required this.response,
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The conversation to work with.
  final Conversation conversation;

  /// The conversation response to use.
  final ConversationResponse response;

  /// Whether or not the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Create state for this widget.
  @override
  _ConversationResponseListTileState createState() =>
      _ConversationResponseListTileState();
}

/// State for [ConversationResponseListTile].
class _ConversationResponseListTileState
    extends State<ConversationResponseListTile> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final sound = widget.response.sound;
    final asset = sound == null
        ? null
        : getAssetReferenceReference(
                assets: world.conversationAssets, id: sound.id)
            .reference;
    final gain = sound?.gain ?? world.soundOptions.defaultGain;
    return PlaySoundSemantics(
      child: Builder(
        builder: (context) => ListTile(
          autofocus: widget.autofocus,
          title: Text(
            widget.response.text ?? 'Response with no text',
          ),
          onTap: () async {
            PlaySoundSemantics.of(context)?.stop();
            await pushWidget(
              context: context,
              builder: (context) => EditConversationResponse(
                projectContext: widget.projectContext,
                conversation: widget.conversation,
                response: widget.response,
              ),
            );
            setState(() {});
          },
        ),
      ),
      soundChannel: widget.projectContext.game.interfaceSounds,
      assetReference: asset,
      gain: gain,
    );
  }
}
