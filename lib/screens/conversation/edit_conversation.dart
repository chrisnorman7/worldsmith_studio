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
import '../../widgets/command/call_command_list_tile.dart';
import '../../widgets/conversation/conversation_branch_list_tile.dart';
import '../../widgets/conversation/conversation_response_list_tile.dart';
import '../../widgets/conversation/edit_conversation_branch_list_tile.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/searchable_list_view.dart';
import '../../widgets/select_item.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/tabbed_scaffold.dart';
import '../../widgets/text_list_tile.dart';
import 'edit_conversation_branch.dart';
import 'edit_conversation_next_branch.dart';
import 'edit_conversation_response.dart';

const _backKeyboardShortcut = KeyboardShortcut(
  description: 'Go back to the previous branch or response.',
  keyName: 'Backspace',
);

/// A class to represent a previous position.
class PreviousState {
  /// Create an index.
  const PreviousState({
    this.index,
    this.branchId,
    this.responseId,
  });

  /// The index.
  final int? index;

  /// The ID of a branch.
  final String? branchId;

  /// The id of a response.
  final String? responseId;
}

/// A widget for editing a [conversation] in the given [category].
class EditConversation extends StatefulWidget {
  /// Create an instance.
  const EditConversation({
    required this.projectContext,
    required this.category,
    required this.conversation,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The category where [conversation] is.
  final ConversationCategory category;

  /// The conversation to edit.
  final Conversation conversation;

  /// Create state for this widget.
  @override
  _EditConversationState createState() => _EditConversationState();
}

/// State for [EditConversation].
class _EditConversationState extends State<EditConversation> {
  int? _index;
  ConversationBranch? _branch;
  ConversationResponse? _response;
  late List<PreviousState> _previousStates;

  /// Initialise lists.
  @override
  void initState() {
    super.initState();
    _previousStates = [];
  }

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final branch = _branch;
    final response = _response;
    final Widget child;
    final String title;
    if (branch != null) {
      title = 'Edit Branch';
      final children = [
        TextListTile(
          value: branch.text ?? '',
          onChanged: (value) {
            branch.text = value.isEmpty ? null : value;
            save();
          },
          header: 'Text',
          autofocus: _index == null,
        ),
        SoundListTile(
          projectContext: widget.projectContext,
          value: branch.sound,
          onDone: (value) {
            branch.sound = value;
            save();
          },
          assetStore: world.conversationAssetStore,
          defaultGain: world.soundOptions.defaultGain,
          nullable: true,
        ),
        const Divider(),
        ListTile(
          title: const Text('Add Response'),
          onTap: () {
            final possibleResponses = widget.conversation.responses
                .where(
                  (element) => branch.responseIds.contains(element.id) == false,
                )
                .toList();
            if (possibleResponses.isEmpty) {
              return showError(
                context: context,
                message: 'There are no more responses.',
              );
            }
            pushWidget(
              context: context,
              builder: (context) => SelectItem<ConversationResponse>(
                onDone: (value) {
                  Navigator.pop(context);
                  branch.responseIds.add(value.id);
                  save();
                },
                values: possibleResponses,
                getItemWidget: (item) {
                  final sound = item.sound;
                  return PlaySoundSemantics(
                    child: Text('${item.text}'),
                    soundChannel: widget.projectContext.game.interfaceSounds,
                    assetReference: sound == null
                        ? null
                        : getAssetReferenceReference(
                            assets: world.conversationAssets,
                            id: sound.id,
                          ).reference,
                    gain: sound?.gain ?? world.soundOptions.defaultGain,
                  );
                },
                title: 'Select Response',
              ),
            );
          },
        )
      ];
      child = WithKeyboardShortcuts(
        child: ListView.builder(
          itemBuilder: (context, index) {
            if (index < children.length) {
              return children[index];
            }
            final position = index - children.length;
            final id = branch.responseIds[position];
            final response = widget.conversation.getResponse(id);
            final sound = response.sound;
            return CallbackShortcuts(
              child: PlaySoundSemantics(
                child: ListTile(
                  autofocus: _index == index,
                  title: Text('Response ${index - children.length + 1}'),
                  subtitle: Text('${response.text}'),
                  onTap: () => setState(
                    () {
                      _previousStates.add(
                        PreviousState(
                          branchId: branch.id,
                          index: index,
                        ),
                      );
                      _index = index;
                      _response = response;
                      _branch = null;
                    },
                  ),
                ),
                soundChannel: widget.projectContext.game.interfaceSounds,
                assetReference: sound == null
                    ? null
                    : getAssetReferenceReference(
                        assets: world.conversationAssets,
                        id: sound.id,
                      ).reference,
                gain: sound?.gain ?? world.soundOptions.defaultGain,
              ),
              bindings: {
                EditIntent.hotkey: () => pushWidget(
                      context: context,
                      builder: (context) => EditConversationResponse(
                        projectContext: widget.projectContext,
                        conversation: widget.conversation,
                        response: response,
                      ),
                    ),
                DeleteIntent.hotkey: () {
                  branch.responseIds.removeAt(position);
                  save();
                },
                MoveUpIntent.hotkey: () {
                  if (position > 0) {
                    branch.responseIds.removeAt(position);
                    branch.responseIds.insert(position - 1, id);
                    _index = index - 1;
                    save();
                  }
                },
                MoveDownIntent.hotkey: () {
                  branch.responseIds.removeAt(position);
                  if (position == branch.responseIds.length) {
                    branch.responseIds.add(id);
                  } else {
                    branch.responseIds.insert(position + 1, id);
                  }
                  _index = index + 1;
                  save();
                },
              },
            );
          },
          itemCount: branch.responseIds.length + children.length,
        ),
        keyboardShortcuts: const [
          KeyboardShortcut(
            description: 'Edit the selected response.',
            keyName: 'E',
            control: true,
          ),
          KeyboardShortcut(
            description: 'Remove the current response from this branch.',
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
          ),
          _backKeyboardShortcut
        ],
      );
    } else if (response != null) {
      title = 'Edit Response';
      final sound = response.sound;
      final nextBranch = response.nextBranch;
      final id = nextBranch?.branchId;
      final branch = id == null ? null : widget.conversation.getBranch(id);
      child = WithKeyboardShortcuts(
        child: CallbackShortcuts(
          child: ListView(
            children: [
              TextListTile(
                value: response.text ?? '',
                onChanged: (value) {
                  response.text = value.isEmpty ? null : value;
                  save();
                },
                header: 'Text',
                autofocus: true,
              ),
              SoundListTile(
                projectContext: widget.projectContext,
                value: sound,
                onDone: (value) {
                  response.sound = value;
                  save();
                },
                assetStore: world.conversationAssetStore,
                defaultGain: world.soundOptions.defaultGain,
                nullable: true,
              ),
              ConversationBranchListTile(
                projectContext: widget.projectContext,
                branch: branch,
                onTap: () {
                  if (branch == null) {
                    pushWidget(
                      context: context,
                      builder: (context) => SelectItem<ConversationBranch>(
                        onDone: (value) {
                          Navigator.pop(context);
                          response.nextBranch =
                              ConversationNextBranch(branchId: value.id);
                          save();
                        },
                        values: widget.conversation.branches,
                        getItemWidget: (item) {
                          final sound = item.sound;
                          return PlaySoundSemantics(
                            child: Text('${item.text}'),
                            soundChannel:
                                widget.projectContext.game.interfaceSounds,
                            assetReference: sound == null
                                ? null
                                : getAssetReferenceReference(
                                    assets: world.conversationAssets,
                                    id: sound.id,
                                  ).reference,
                            gain: sound?.gain ?? world.soundOptions.defaultGain,
                          );
                        },
                        title: 'Select Branch',
                      ),
                    );
                  } else {
                    setState(
                      () {
                        _previousStates.add(
                          PreviousState(responseId: response.id),
                        );
                        _index = null;
                        _branch = branch;
                        _response = null;
                      },
                    );
                  }
                },
                title: 'Next Branch',
              ),
              CallCommandListTile(
                projectContext: widget.projectContext,
                callCommand: response.command,
                onChanged: (value) {
                  response.command = value;
                  save();
                },
              )
            ],
          ),
          bindings: {
            EditIntent.hotkey: () {
              if (nextBranch != null) {
                pushWidget(
                  context: context,
                  builder: (context) => EditConversationNextBranch(
                    projectContext: widget.projectContext,
                    conversation: widget.conversation,
                    response: response,
                    nextBranch: nextBranch,
                  ),
                );
              }
            }
          },
        ),
        keyboardShortcuts: const [
          KeyboardShortcut(
            description: 'Edit next branch parameters.',
            keyName: 'E',
            control: true,
          ),
          _backKeyboardShortcut
        ],
      );
    } else {
      title = 'If you are seeing this there is a bug!!';
      child = TabbedScaffold(
        tabs: [
          TabbedScaffoldTab(
            title: 'Conversation Settings',
            icon: const Icon(Icons.settings_outlined),
            builder: (context) {
              final initialBranch = widget.conversation.getBranch(
                widget.conversation.initialBranchId,
              );
              return WithKeyboardShortcuts(
                child: ListView(
                  children: [
                    TextListTile(
                      value: widget.conversation.name,
                      onChanged: (value) {
                        widget.conversation.name = value;
                        save();
                      },
                      header: 'Conversation Name',
                      autofocus: true,
                      labelText: 'Name',
                      validator: (value) => validateNonEmptyValue(value: value),
                    ),
                    SoundListTile(
                      projectContext: widget.projectContext,
                      value: widget.conversation.music,
                      onDone: (value) {
                        widget.conversation.music = value;
                        save();
                      },
                      assetStore: world.musicAssetStore,
                      defaultGain: world.soundOptions.defaultGain,
                      looping: true,
                      nullable: true,
                      title: 'Music',
                    ),
                    ConversationBranchListTile(
                      projectContext: widget.projectContext,
                      branch: initialBranch,
                      onTap: () => setState(
                        () {
                          _previousStates.clear();
                          _branch = initialBranch;
                          _response = null;
                          _index = null;
                        },
                      ),
                      title: 'Initial Branch',
                    ),
                  ],
                ),
                keyboardShortcuts: const [_backKeyboardShortcut],
              );
            },
            actions: [
              ElevatedButton(
                onPressed: () {
                  confirm(
                    context: context,
                    message:
                        'Are you sure you want to delete this conversation?',
                    title: 'Delete Conversation',
                    yesCallback: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      widget.category.conversations.removeWhere(
                        (element) => element.id == widget.conversation.id,
                      );
                      widget.projectContext.save();
                    },
                  );
                },
                child: const Icon(
                  Icons.delete_outlined,
                  semanticLabel: 'Delete Conversation',
                ),
              )
            ],
          ),
          TabbedScaffoldTab(
            title: 'Branches',
            icon: const Icon(Icons.question_answer_outlined),
            builder: (context) {
              final branches = widget.conversation.branches;
              // No need to check if there are no branches, since there must
              // always be one for `Conversation.initialBranchId`.
              final children = <SearchableListTile>[];
              for (var i = 0; i < branches.length; i++) {
                final branch = branches[i];
                children.add(
                  SearchableListTile(
                    searchString: branch.text ?? 'Untitled Branch',
                    child: EditConversationBranchListTile(
                      autofocus: i == 0,
                      conversation: widget.conversation,
                      branch: branch,
                      projectContext: widget.projectContext,
                    ),
                  ),
                );
              }
              return CallbackShortcuts(
                child: SearchableListView(children: children),
                bindings: {
                  CreateConversationBranchIntent.hotkey: () =>
                      addConversationBranch(context)
                },
              );
            },
            floatingActionButton: FloatingActionButton(
              onPressed: () => addConversationBranch(context),
              child: createIcon,
              tooltip: 'Add Branch',
            ),
          ),
          TabbedScaffoldTab(
            title: 'Responses',
            icon: const Icon(Icons.reply_outlined),
            builder: (context) {
              final responses = widget.conversation.responses;
              if (responses.isEmpty) {
                return const CenterText(
                    text: 'There are no responses to show.');
              }
              final children = <SearchableListTile>[];
              for (var i = 0; i < responses.length; i++) {
                final response = responses[i];
                children.add(
                  SearchableListTile(
                    searchString:
                        response.text ?? 'Untitled Conversation Response',
                    child: ConversationResponseListTile(
                      autofocus: i == 0,
                      projectContext: widget.projectContext,
                      conversation: widget.conversation,
                      response: response,
                    ),
                  ),
                );
              }
              return CallbackShortcuts(
                child: SearchableListView(children: children),
                bindings: {
                  CreateConversationResponseIntent.hotkey: () =>
                      addConversationResponse(context),
                },
              );
            },
            floatingActionButton: FloatingActionButton(
              autofocus: widget.conversation.responses.isEmpty,
              onPressed: () => addConversationResponse(context),
              child: createIcon,
              tooltip: 'Add Response',
            ),
          ),
        ],
      );
    }
    if (child is TabbedScaffold) {
      return Cancel(child: child);
    }
    return Cancel(
      child: CallbackShortcuts(
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: child,
        ),
        bindings: {
          GoUpIntent.hotkey: () {
            if (_previousStates.isNotEmpty) {
              final previousState = _previousStates.removeLast();
              final branchId = previousState.branchId;
              final responseId = previousState.responseId;
              if (branchId != null) {
                setState(() {
                  _branch = widget.conversation.getBranch(branchId);
                  _index = previousState.index;
                  _response = null;
                });
              } else if (responseId != null) {
                setState(() {
                  _response = widget.conversation.getResponse(responseId);
                  _index = null;
                  _branch = null;
                });
              }
            } else {
              setState(() {
                _branch = null;
                _index = null;
                _response = null;
              });
            }
          }
        },
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Add a conversation response.
  Future<void> addConversationResponse(BuildContext context) async {
    final response = ConversationResponse(
      id: newId(),
      text: 'Change me',
    );
    widget.conversation.responses.add(response);
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

  /// Add a new conversation branch.
  Future<void> addConversationBranch(BuildContext context) async {
    final branch = ConversationBranch(id: newId(), responseIds: []);
    widget.conversation.branches.add(branch);
    widget.projectContext.save();
    await pushWidget(
      context: context,
      builder: (context) => EditConversationBranch(
        projectContext: widget.projectContext,
        conversation: widget.conversation,
        branch: branch,
      ),
    );
    setState(() {});
  }
}
