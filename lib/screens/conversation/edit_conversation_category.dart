import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/get_text.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/searchable_list_view.dart';
import 'edit_conversation.dart';

/// A widget for editing the given [conversationCategory].
class EditConversationCategory extends StatefulWidget {
  /// Create an instance.
  const EditConversationCategory({
    required this.projectContext,
    required this.conversationCategory,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The conversation category to edit.
  final ConversationCategory conversationCategory;

  /// Create state for this widget.
  @override
  EditConversationCategoryState createState() =>
      EditConversationCategoryState();
}

/// State for [EditConversationCategory].
class EditConversationCategoryState extends State<EditConversationCategory> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final Widget child;
    final world = widget.projectContext.world;
    final conversations = widget.conversationCategory.conversations;
    if (conversations.isEmpty) {
      child = const CenterText(text: 'There are no conversations to show.');
    } else {
      final children = <SearchableListTile>[];
      for (var i = 0; i < conversations.length; i++) {
        final conversation = conversations[i];
        final music = conversation.music;
        final asset = music == null
            ? null
            : getAssetReferenceReference(
                assets: world.musicAssets,
                id: music.id,
              ).reference;
        final gain = music?.gain ?? world.soundOptions.defaultGain;
        children.add(
          SearchableListTile(
            searchString: conversation.name,
            child: CallbackShortcuts(
              bindings: {
                RenameIntent.hotkey: () => pushWidget(
                      context: context,
                      builder: (final context) => GetText(
                        onDone: (final value) {
                          conversation.name = value;
                          Navigator.pop(context);
                          save();
                        },
                        labelText: 'Name',
                        text: conversation.name,
                        title: 'Rename Conversation',
                        validator: (final value) => validateNonEmptyValue(
                          value: value,
                        ),
                      ),
                    )
              },
              child: PlaySoundSemantics(
                soundChannel: widget.projectContext.game.musicSounds,
                assetReference: asset,
                gain: gain,
                looping: true,
                child: Builder(
                  builder: (final context) => ListTile(
                    autofocus: i == 0,
                    title: Text(conversation.name),
                    onTap: () async {
                      PlaySoundSemantics.of(context)?.stop();
                      await pushWidget(
                        context: context,
                        builder: (final context) => EditConversation(
                          projectContext: widget.projectContext,
                          category: widget.conversationCategory,
                          conversation: conversation,
                        ),
                      );
                      save();
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      }
      child = SearchableListView(children: children);
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () => pushWidget(
                context: context,
                builder: (final context) => GetText(
                  onDone: (final value) {
                    widget.conversationCategory.name = value;
                    widget.projectContext.save();
                    Navigator.pop(context);
                  },
                  labelText: 'Name',
                  text: widget.conversationCategory.name,
                  title: 'Rename Conversation Category',
                  validator: (final value) =>
                      validateNonEmptyValue(value: value),
                ),
              ),
              child: const Icon(
                Icons.drive_file_rename_outline,
                semanticLabel: 'Rename Category',
              ),
            )
          ],
          title: const Text('Edit Conversation Category'),
        ),
        body: child,
        floatingActionButton: FloatingActionButton(
          autofocus: conversations.isEmpty,
          onPressed: () async {
            final branch = ConversationBranch(
              id: newId(),
              text: 'I need changing.',
              responseIds: [],
            );
            final conversation = Conversation(
              id: newId(),
              name: 'Untitled Conversation',
              branches: [branch],
              initialBranchId: branch.id,
              responses: [],
            );
            conversations.add(conversation);
            widget.projectContext.save();
            await pushWidget(
              context: context,
              builder: (final context) => EditConversation(
                projectContext: widget.projectContext,
                category: widget.conversationCategory,
                conversation: conversation,
              ),
            );
            setState(() {});
          },
          tooltip: 'Add Conversation',
          child: createIcon,
        ),
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
