import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../conversation_location.dart';
import '../../project_context.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/select_item.dart';

/// A widget for selecting a conversation.
class SelectConversation extends StatefulWidget {
  /// Create an instance.
  const SelectConversation({
    required this.projectContext,
    required this.onDone,
    this.location,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The function to call with the new value.
  final ValueChanged<ConversationLocation?> onDone;

  /// The location of any current conversation.
  final ConversationLocation? location;

  /// Create state for this widget.
  @override
  _SelectConversationState createState() => _SelectConversationState();
}

/// State for [SelectConversation].
class _SelectConversationState extends State<SelectConversation> {
  ConversationCategory? _category;

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final category = _category;
    if (category == null) {
      return SelectItem<ConversationCategory>(
        onDone: (value) => setState(() => _category = value),
        values: world.conversationCategories,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDone(null);
            },
            child: const Icon(
              Icons.clear_outlined,
              semanticLabel: 'Clear Conversation',
            ),
          )
        ],
        getItemWidget: (item) => Text(item.name),
        title: 'Select Category',
        value: widget.location?.category,
      );
    } else {
      return SelectItem<Conversation>(
        onDone: (value) {
          Navigator.pop(context);
          widget.onDone(
            ConversationLocation(
              category: category,
              conversation: value,
            ),
          );
        },
        values: category.conversations,
        getItemWidget: (item) {
          final branch = item.getBranch(item.initialBranchId);
          final sound = branch.sound;
          final assetReference = sound == null
              ? null
              : getAssetReferenceReference(
                  assets: world.conversationAssets,
                  id: sound.id,
                ).reference;
          return PlaySoundSemantics(
            child: Text(item.name),
            soundChannel: widget.projectContext.game.interfaceSounds,
            assetReference: assetReference,
            gain: sound?.gain ?? world.soundOptions.defaultGain,
          );
        },
      );
    }
  }
}