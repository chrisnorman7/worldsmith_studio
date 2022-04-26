// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../screens/conversation/edit_conversation_branch.dart';
import '../../util.dart';
import '../play_sound_semantics.dart';

/// A widget for displaying and editing a [branch].
class EditConversationBranchListTile extends StatefulWidget {
  /// Create an instance.
  const EditConversationBranchListTile({
    required this.projectContext,
    required this.conversation,
    required this.branch,
    this.autofocus = false,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The conversation to work with.
  final Conversation conversation;

  /// The conversation branch to show.
  final ConversationBranch branch;

  /// Whether or not the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Create state for this widget.
  @override
  EditConversationBranchListTileState createState() =>
      EditConversationBranchListTileState();
}

/// State for [EditConversationBranchListTile].
class EditConversationBranchListTileState
    extends State<EditConversationBranchListTile> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final attached = widget.conversation.initialBranchId == widget.branch.id ||
        widget.conversation.responses
            .where(
              (final element) =>
                  element.nextBranch?.branchId == widget.branch.id,
            )
            .isNotEmpty;
    final sound = widget.branch.sound;
    final asset = sound == null
        ? null
        : getAssetReferenceReference(
            assets: world.conversationAssets,
            id: sound.id,
          ).reference;
    final gain = sound?.gain ?? world.soundOptions.defaultGain;
    return PlaySoundSemantics(
      soundChannel: widget.projectContext.game.musicSounds,
      assetReference: asset,
      gain: gain,
      child: Builder(
        builder: (final context) => ListTile(
          autofocus: widget.autofocus,
          title: Text(
            widget.branch.text ?? 'Conversation branch without any text',
          ),
          subtitle: attached ? null : const Text('(Unattached)'),
          onTap: () async {
            PlaySoundSemantics.of(context)?.stop();
            await pushWidget(
              context: context,
              builder: (final context) => EditConversationBranch(
                projectContext: widget.projectContext,
                branch: widget.branch,
                conversation: widget.conversation,
              ),
            );
            setState(() {});
          },
        ),
      ),
    );
  }
}
