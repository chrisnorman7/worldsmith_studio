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
    required this.response,
    required this.nextBranch,
    required this.onChanged,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The conversation that [nextBranch] belongs to.
  final Conversation conversation;

  /// The response that [nextBranch] belongs to.
  final ConversationResponse response;

  /// The next branch instance to work with.
  final ConversationNextBranch? nextBranch;

  /// The function to be called when a new [nextBranch] is created.
  final ValueChanged<ConversationNextBranch> onChanged;

  /// Create state for this widget.
  @override
  ConversationNextBranchListTileState createState() =>
      ConversationNextBranchListTileState();
}

/// State for [ConversationNextBranchListTile].
class ConversationNextBranchListTileState
    extends State<ConversationNextBranchListTile> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final nextBranch = widget.nextBranch;
    final branch = nextBranch == null
        ? null
        : widget.conversation.getBranch(nextBranch.branchId);
    final sound = branch?.sound;
    final asset = sound == null
        ? null
        : getAssetReferenceReference(
            assets: world.conversationAssets,
            id: sound.id,
          );
    return PlaySoundSemantics(
      soundChannel: widget.projectContext.game.interfaceSounds,
      assetReference: asset?.reference,
      gain: world.soundOptions.defaultGain,
      child: Builder(
        builder: (final context) => ListTile(
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
                builder: (final context) => SelectItem<ConversationBranch>(
                  onDone: (final value) {
                    Navigator.pop(context);
                    widget.onChanged(
                      ConversationNextBranch(
                        branchId: value.id,
                      ),
                    );
                  },
                  values: widget.conversation.branches,
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
                      gain: world.soundOptions.defaultGain,
                      child: Text(item.text ?? '<No Text>'),
                    );
                  },
                ),
              );
            } else {
              await pushWidget(
                context: context,
                builder: (final context) => EditConversationNextBranch(
                  projectContext: widget.projectContext,
                  conversation: widget.conversation,
                  response: widget.response,
                  nextBranch: nextBranch,
                ),
              );
              setState(() {});
            }
            setState(() {});
          },
        ),
      ),
    );
  }
}
