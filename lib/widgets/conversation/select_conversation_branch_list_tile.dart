import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../play_sound_semantics.dart';
import 'select_conversation_branch.dart';

/// A widget for showing and changing the given [branch].
class SelectConversationBranchListTile extends StatelessWidget {
  /// Create an instance.
  const SelectConversationBranchListTile({
    required this.projectContext,
    required this.conversation,
    required this.branch,
    required this.onChanged,
    this.title = 'Branch',
    this.autofocus = false,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The conversation that [branch] is part of.
  final Conversation conversation;

  /// The conversation branch to show.
  final ConversationBranch branch;

  /// The function to be called when the [branch] changes.
  final ValueChanged<ConversationBranch> onChanged;

  /// The title for the resulting [ListTile].
  final String title;

  /// Whether or not the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Build the list tile.
  @override
  Widget build(final BuildContext context) {
    final world = projectContext.world;
    final sound = branch.sound;
    final asset = sound == null
        ? null
        : getAssetReferenceReference(
            assets: world.conversationAssets,
            id: sound.id,
          ).reference;
    return PlaySoundSemantics(
      soundChannel: projectContext.game.interfaceSounds,
      assetReference: asset,
      gain: sound?.gain ?? world.soundOptions.defaultGain,
      child: ListTile(
        autofocus: autofocus,
        title: Text(title),
        subtitle: Text(branch.text ?? 'Branch with no text'),
        onTap: () => pushWidget(
          context: context,
          builder: (final context) => SelectConversationBranch(
            projectContext: projectContext,
            conversation: conversation,
            onDone: onChanged,
          ),
        ),
      ),
    );
  }
}
