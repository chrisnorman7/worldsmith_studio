import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../screens/conversation/edit_conversation_next_branch.dart';
import '../../util.dart';
import '../play_sound_semantics.dart';
import '../select_item.dart';

/// A widget for editing a conversation [nextBranch].
class ConversationNextBranchListTile extends StatefulWidget {
  /// Create an instance.
  const ConversationNextBranchListTile({
    required this.projectContext,
    required this.conversation,
    required this.nextBranch,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The conversation that [nextBranch] belongs to.
  final Conversation conversation;

  /// The next branch instance to work with.
  final ConversationNextBranch? nextBranch;

  /// The function to be called when [nextBranch] changes.
  final ValueChanged<ConversationNextBranch?> onChanged;

  /// Create state for this widget.
  @override
  _ConversationNextBranchListTileState createState() =>
      _ConversationNextBranchListTileState();
}

/// State for [ConversationNextBranchListTile].
class _ConversationNextBranchListTileState
    extends State<ConversationNextBranchListTile> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final nextBranch = widget.nextBranch;
    final branch = nextBranch == null
        ? null
        : widget.conversation.getBranch(nextBranch.branchId);
    final asset = branch == null
        ? null
        : getAssetReferenceReference(
            assets: world.conversationAssets,
            id: branch.sound?.id,
          );
    return PlaySoundSemantics(
      child: Builder(
        builder: (context) => ListTile(
          title: const Text('Next Branch'),
          subtitle: Text(
            branch == null
                ? 'Not set'
                : ('${branch.text} (${nextBranch?.fadeTime} seconds)'),
          ),
          onTap: () async {
            PlaySoundSemantics.of(context)?.stop();
            if (nextBranch == null) {
              await pushWidget(
                context: context,
                builder: (context) => SelectItem<ConversationBranch>(
                  onDone: (value) {
                    Navigator.pop(context);
                    widget.onChanged(
                      ConversationNextBranch(
                        branchId: value.id,
                      ),
                    );
                  },
                  values: widget.conversation.branches,
                  getItemWidget: (item) => PlaySoundSemantics(
                    child: Text(item.text ?? '<No Text>'),
                    soundChannel: widget.projectContext.game.interfaceSounds,
                    assetReference: getAssetReferenceReference(
                      assets: world.conversationAssets,
                      id: item.sound?.id,
                    )?.reference,
                    gain: world.soundOptions.defaultGain,
                  ),
                ),
              );
            } else {
              await pushWidget(
                context: context,
                builder: (context) => EditConversationNextBranch(
                  projectContext: widget.projectContext,
                  conversation: widget.conversation,
                  nextBranch: nextBranch,
                  onChanged: widget.onChanged,
                ),
              );
              setState(() {});
            }
            setState(() {});
          },
        ),
      ),
      soundChannel: widget.projectContext.game.interfaceSounds,
      assetReference: asset?.reference,
      gain: world.soundOptions.defaultGain,
    );
  }
}