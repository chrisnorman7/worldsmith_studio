import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/sound.dart';

import '../../project_context.dart';
import '../play_sound_semantics.dart';

/// A widget for showing a conversation [branch].
class ConversationBranchListTile extends StatelessWidget {
  /// Create an instance.
  const ConversationBranchListTile({
    required this.projectContext,
    required this.branch,
    required this.onTap,
    this.title,
    this.autofocus = false,
    this.soundChannel,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The conversation branch to show.
  final ConversationBranch? branch;

  /// What to do when the resulting [ListTile] is tapped.
  final VoidCallback onTap;

  /// The title of the resulting [ListTile].
  ///
  /// If this value is `null`, there will be no title used, and the branch will
  /// be shown with no header.
  final String? title;

  /// Whether or not the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// The sound channel to play sounds through.
  final SoundChannel? soundChannel;

  /// Return the widget.
  @override
  Widget build(final BuildContext context) {
    final world = projectContext.world;
    final b = branch;
    final sound = b?.sound;
    final text = Text(b == null ? 'Not set' : '${b.text}');
    final titleText = title;
    return PlaySoundSemantics(
      soundChannel: soundChannel ?? projectContext.game.interfaceSounds,
      assetReference: sound == null
          ? null
          : getAssetReferenceReference(
              assets: world.conversationAssets,
              id: sound.id,
            ).reference,
      gain: sound?.gain ?? world.soundOptions.defaultGain,
      child: ListTile(
        autofocus: autofocus,
        title: titleText == null ? text : Text(titleText),
        subtitle: titleText == null ? null : text,
        onTap: onTap,
      ),
    );
  }
}
