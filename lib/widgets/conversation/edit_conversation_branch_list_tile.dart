import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../play_sound_semantics.dart';

/// A widget for displaying and editing a [conversationBranch].
class EditConversationBranchListTile extends StatefulWidget {
  /// Create an instance.
  const EditConversationBranchListTile({
    required this.projectContext,
    required this.conversationBranch,
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The conversation branch to show.
  final ConversationBranch conversationBranch;

  /// Whether or not the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Create state for this widget.
  @override
  _EditConversationBranchListTileState createState() =>
      _EditConversationBranchListTileState();
}

/// State for [EditConversationBranchListTile].
class _EditConversationBranchListTileState
    extends State<EditConversationBranchListTile> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final sound = widget.conversationBranch.sound;
    final asset = sound == null
        ? null
        : getAssetReferenceReference(
            assets: world.conversationAssets,
            id: sound.id,
          )!
            .reference;
    final gain = sound?.gain ?? world.soundOptions.defaultGain;
    return PlaySoundSemantics(
      child: ListTile(
        autofocus: widget.autofocus,
        title: Text(
          widget.conversationBranch.text ??
              'Conversation branch without any text',
        ),
        onTap: () {
          PlaySoundSemantics.of(context)?.stop();
        },
      ),
      soundChannel: widget.projectContext.game.musicSounds,
      assetReference: asset,
      gain: gain,
    );
  }
}
