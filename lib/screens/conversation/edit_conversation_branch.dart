import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/tabbed_scaffold.dart';
import '../../widgets/text_list_tile.dart';
import 'edit_conversation_response.dart';
import 'select_response.dart';

/// A widget for editing a conversation [branch].
class EditConversationBranch extends StatefulWidget {
  /// Create an instance.
  const EditConversationBranch({
    required this.projectContext,
    required this.conversation,
    required this.branch,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The conversation that [branch] belongs to.
  final Conversation conversation;

  /// The conversation branch to edit.
  final ConversationBranch branch;

  /// Create state for this widget.
  @override
  _EditConversationBranchState createState() => _EditConversationBranchState();
}

/// State for [EditConversationBranch].
class _EditConversationBranchState extends State<EditConversationBranch> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    return Cancel(
      child: TabbedScaffold(
        tabs: [
          TabbedScaffoldTab(
            title: 'Branch Settings',
            icon: const Icon(Icons.settings_outlined),
            builder: (context) => ListView(
              children: [
                TextListTile(
                  value: widget.branch.text ?? '',
                  onChanged: (value) {
                    if (value.isEmpty) {
                      widget.branch.text = null;
                    } else {
                      widget.branch.text = value;
                    }
                    save();
                  },
                  header: 'Text',
                  autofocus: true,
                ),
                SoundListTile(
                  projectContext: widget.projectContext,
                  value: widget.branch.sound,
                  onDone: (value) {
                    widget.branch.sound = value;
                    save();
                  },
                  assetStore: world.conversationAssetStore,
                  defaultGain: world.soundOptions.defaultGain,
                  nullable: true,
                )
              ],
            ),
          ),
          TabbedScaffoldTab(
            title: 'Responses',
            icon: const Icon(Icons.reply_outlined),
            builder: (context) => WithKeyboardShortcuts(
              child: CallbackShortcuts(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    final id = widget.branch.responseIds[index];
                    final response = widget.conversation.getResponse(id);
                    final sound = response.sound;
                    return CallbackShortcuts(
                      child: PlaySoundSemantics(
                        child: Builder(
                          builder: (context) => ListTile(
                            autofocus: index == 0,
                            title: Text('${response.text}'),
                            onTap: () async {
                              PlaySoundSemantics.of(context)?.stop();
                              await pushWidget(
                                context: context,
                                builder: (context) => EditConversationResponse(
                                  projectContext: widget.projectContext,
                                  conversation: widget.conversation,
                                  response: response,
                                ),
                              );
                              setState(() {});
                            },
                          ),
                        ),
                        soundChannel:
                            widget.projectContext.game.interfaceSounds,
                        assetReference: sound == null
                            ? null
                            : getAssetReferenceReference(
                                assets: world.conversationAssets,
                                id: sound.id,
                              ).reference,
                        gain: world.soundOptions.defaultGain,
                      ),
                      bindings: {
                        DeleteIntent.hotkey: () {
                          widget.branch.responseIds.remove(id);
                          save();
                        },
                        MoveUpIntent.hotkey: () {
                          if (index >= 0) {
                            widget.branch.responseIds.removeAt(index);
                            widget.branch.responseIds.insert(index - 1, id);
                            save();
                          }
                        },
                        MoveDownIntent.hotkey: () {
                          widget.branch.responseIds.removeAt(index);
                          if (index == widget.branch.responseIds.length) {
                            widget.branch.responseIds.add(id);
                          } else {
                            widget.branch.responseIds.insert(index + 1, id);
                          }
                          save();
                        },
                      },
                    );
                  },
                  itemCount: widget.branch.responseIds.length,
                ),
                bindings: {
                  AddIntent.hotkey: () => addConversationResponse(context),
                  CreateConversationResponseIntent.hotkey: () =>
                      createConversationResponse(context)
                },
              ),
              keyboardShortcuts: const [
                KeyboardShortcut(
                  description: 'Add an existing response.',
                  keyName: 'A',
                  control: true,
                ),
                KeyboardShortcut(
                  description: 'Create a new response.',
                  keyName: 'N',
                  control: true,
                ),
                KeyboardShortcut(
                  description: 'Remove the selected response from this branch.',
                  keyName: 'Delete',
                ),
                KeyboardShortcut(
                  description: 'Move the selected response up in the list.',
                  keyName: 'Up Arrow',
                  alt: true,
                ),
                KeyboardShortcut(
                  description: 'Move the selected response down in the list.',
                  keyName: 'Down Arrow',
                  alt: true,
                )
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => createConversationResponse(context),
                child: const Icon(
                  Icons.create_sharp,
                  semanticLabel: 'Create Response',
                ),
              )
            ],
            floatingActionButton: FloatingActionButton(
              autofocus: widget.branch.responseIds.isEmpty,
              onPressed: () => addConversationResponse(context),
              child: createIcon,
              tooltip: 'Add Response',
            ),
          )
        ],
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Create a new response.
  Future<void> createConversationResponse(BuildContext context) async {
    final response = ConversationResponse(id: newId());
    widget.conversation.responses.add(response);
    widget.branch.responseIds.add(response.id);
    widget.projectContext.save();
    await pushWidget(
      context: context,
      builder: (context) => EditConversationResponse(
        projectContext: widget.projectContext,
        conversation: widget.conversation,
        response: response,
      ),
    );
    setState(() {});
  }

  /// Add an existing conversation response.
  Future<void> addConversationResponse(BuildContext context) => pushWidget(
        context: context,
        builder: (context) => SelectResponse(
          projectContext: widget.projectContext,
          conversation: widget.conversation,
          onDone: (value) {
            Navigator.pop(context);
            widget.branch.responseIds.add(value.id);
            save();
          },
        ),
      );
}
