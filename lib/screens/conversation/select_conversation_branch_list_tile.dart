import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/select_item.dart';

/// A widget for showing and changing the given [branch].
class SelectConversationBranchListTile extends StatelessWidget {
  /// Create an instance.
  const SelectConversationBranchListTile({
    required this.projectContext,
    required this.conversation,
    required this.branch,
    required this.onChanged,
    this.title = 'Branch',
    Key? key,
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

  /// Build the list tile.
  @override
  Widget build(BuildContext context) {
    final world = projectContext.world;
    final sound = branch.sound;
    final asset = sound == null
        ? null
        : getAssetReferenceReference(
            assets: world.conversationAssets,
            id: sound.id,
          )!
            .reference;
    return PlaySoundSemantics(
      child: ListTile(
        title: Text(title),
        subtitle: Text(branch.text ?? 'Branch with no text'),
        onTap: () => pushWidget(
          context: context,
          builder: (context) => SelectItem<ConversationBranch>(
            onDone: onChanged,
            values: conversation.branches,
            getItemWidget: (item) => Text(
              item.text ?? 'Untitled',
            ),
          ),
        ),
      ),
      soundChannel: projectContext.game.interfaceSounds,
      assetReference: asset,
      gain: sound?.gain ?? world.soundOptions.defaultGain,
    );
  }
}
