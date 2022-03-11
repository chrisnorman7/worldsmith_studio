import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/select_item.dart';

/// A widget for selecting a response from the given [conversation].
class SelectResponse extends StatelessWidget {
  /// Create an instance.
  const SelectResponse({
    required this.projectContext,
    required this.conversation,
    required this.onDone,
    this.title = 'Select Response',
    this.value,
    Key? key,
  }) : super(key: key);

  /// The project context to work with.
  final ProjectContext projectContext;

  /// The conversation to work with.
  final Conversation conversation;

  /// The function to call with the new response.
  final ValueChanged<ConversationResponse> onDone;

  /// The title of the [Scaffold].
  final String title;

  /// The current value (if any).
  final ConversationResponse? value;

  /// Build the widget.
  @override
  Widget build(BuildContext context) {
    final world = projectContext.world;
    return SelectItem<ConversationResponse>(
      onDone: onDone,
      values: conversation.responses,
      getItemWidget: (item) {
        final sound = item.sound;
        return PlaySoundSemantics(
          child: Text('${item.text}'),
          soundChannel: projectContext.game.interfaceSounds,
          assetReference: sound == null
              ? null
              : getAssetReferenceReference(
                  assets: world.conversationAssets,
                  id: sound.id,
                ).reference,
          gain: world.soundOptions.defaultGain,
        );
      },
      title: title,
      value: value,
    );
  }
}
