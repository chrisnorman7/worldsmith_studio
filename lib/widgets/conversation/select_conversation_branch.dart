import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../keyboard_shortcuts_list.dart';
import '../play_sound_semantics.dart';
import '../select_item.dart';

/// A widget for selecting a branch from a [conversation].
class SelectConversationBranch extends StatefulWidget {
  /// Create an instance.
  const SelectConversationBranch({
    required this.projectContext,
    required this.conversation,
    required this.onDone,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The conversation to select a branch from.
  final Conversation conversation;

  /// The function to call with the branch.
  final ValueChanged<ConversationBranch> onDone;

  /// Create state for this widget.
  @override
  SelectConversationBranchState createState() =>
      SelectConversationBranchState();
}

/// State for [SelectConversationBranch].
class SelectConversationBranchState extends State<SelectConversationBranch> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    return WithKeyboardShortcuts(
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Add a new branch.',
          keyName: 'A',
          control: true,
        )
      ],
      child: CallbackShortcuts(
        bindings: {AddIntent.hotkey: addBranch},
        child: SelectItem<ConversationBranch>(
          onDone: widget.onDone,
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
              gain: sound?.gain ?? world.soundOptions.defaultGain,
              child: Text(
                item.text ?? 'Untitled',
              ),
            );
          },
          actions: [
            ElevatedButton(
              onPressed: addBranch,
              child: const Icon(
                Icons.add,
                semanticLabel: 'Add Branch',
              ),
            )
          ],
          title: 'Select Branch',
        ),
      ),
    );
  }

  /// Add a new conversation branch.
  void addBranch() => setState(
        () {
          widget.conversation.branches.add(
            ConversationBranch(
              id: newId(),
              responseIds: [],
            ),
          );
          widget.projectContext.save();
        },
      );
}
