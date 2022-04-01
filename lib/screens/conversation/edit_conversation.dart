import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/sound.dart';

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
import '../../widgets/conversation/select_conversation_branch.dart';
import '../../widgets/conversation/select_conversation_response.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/reverb/reverb_list_tile.dart';
import '../../widgets/searchable_list_view.dart';
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
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The category where [conversation] is.
  final ConversationCategory category;

  /// The conversation to edit.
  final Conversation conversation;

  /// Create state for this widget.
  @override
  EditConversationState createState() => EditConversationState();
}

/// State for [EditConversation].
class EditConversationState extends State<EditConversation> {
  int? _index;
  ConversationBranch? _branch;
  ConversationResponse? _response;
  late List<PreviousState> _previousStates;
  SoundChannel? _channel;
  CreateReverb? _reverb;

  /// Initialise lists.
  @override
  void initState() {
    super.initState();
    _previousStates = [];
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final reverbId = widget.conversation.reverbId;
    var channel = _channel;
    var reverb = _reverb;
    if (reverb == null && reverbId != null) {
      final preset = world.getReverb(reverbId);
      reverb = widget.projectContext.game.createReverb(preset);
      _reverb = reverb;
    }
    if (channel == null) {
      channel = widget.projectContext.game.createSoundChannel(reverb: reverb);
      _channel = channel;
    }
    final branch = _branch;
    final response = _response;
    final Widget child;
    final String title;
    if (branch != null) {
      title = 'Edit Branch';
      final children = [
        TextListTile(
          value: branch.text ?? '',
          onChanged: (final value) {
            branch.text = value.isEmpty ? null : value;
            save();
          },
          header: 'Text',
          autofocus: _index == null,
        ),
        SoundListTile(
          projectContext: widget.projectContext,
          value: branch.sound,
          onDone: (final value) {
            branch.sound = value;
            save();
          },
          assetStore: world.conversationAssetStore,
          defaultGain: world.soundOptions.defaultGain,
          nullable: true,
          soundChannel: channel,
        ),
        const Divider(),
        ListTile(
          title: const Text('Add Response'),
          onTap: () {
            pushWidget(
              context: context,
              builder: (final context) => SelectConversationResponse(
                projectContext: widget.projectContext,
                conversation: widget.conversation,
                onDone: (final value) {
                  Navigator.pop(context);
                  branch.responseIds.add(value.id);
                  save();
                },
                ignoredResponses: branch.responseIds,
              ),
            );
          },
        )
      ];
      child = WithKeyboardShortcuts(
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
        child: ListView.builder(
          itemBuilder: (final context, final index) {
            if (index < children.length) {
              return children[index];
            }
            final position = index - children.length;
            final id = branch.responseIds[position];
            final response = widget.conversation.getResponse(id);
            final sound = response.sound;
            return CallbackShortcuts(
              bindings: {
                EditIntent.hotkey: () => pushWidget(
                      context: context,
                      builder: (final context) => EditConversationResponse(
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
              child: PlaySoundSemantics(
                soundChannel:
                    channel ?? widget.projectContext.game.interfaceSounds,
                assetReference: sound == null
                    ? null
                    : getAssetReferenceReference(
                        assets: world.conversationAssets,
                        id: sound.id,
                      ).reference,
                gain: sound?.gain ?? world.soundOptions.defaultGain,
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
              ),
            );
          },
          itemCount: branch.responseIds.length + children.length,
        ),
      );
    } else if (response != null) {
      title = 'Edit Response';
      final sound = response.sound;
      final nextBranch = response.nextBranch;
      final id = nextBranch?.branchId;
      final branch = id == null ? null : widget.conversation.getBranch(id);
      child = WithKeyboardShortcuts(
        keyboardShortcuts: const [
          KeyboardShortcut(
            description: 'Edit next branch parameters.',
            keyName: 'E',
            control: true,
          ),
          _backKeyboardShortcut
        ],
        child: CallbackShortcuts(
          bindings: {
            EditIntent.hotkey: () {
              if (nextBranch != null) {
                pushWidget(
                  context: context,
                  builder: (final context) => EditConversationNextBranch(
                    projectContext: widget.projectContext,
                    conversation: widget.conversation,
                    response: response,
                    nextBranch: nextBranch,
                  ),
                );
              }
            }
          },
          child: ListView(
            children: [
              TextListTile(
                value: response.text ?? '',
                onChanged: (final value) {
                  response.text = value.isEmpty ? null : value;
                  save();
                },
                header: 'Text',
                autofocus: true,
              ),
              SoundListTile(
                projectContext: widget.projectContext,
                value: sound,
                onDone: (final value) {
                  response.sound = value;
                  save();
                },
                assetStore: world.conversationAssetStore,
                defaultGain: world.soundOptions.defaultGain,
                nullable: true,
                soundChannel: channel,
              ),
              ConversationBranchListTile(
                projectContext: widget.projectContext,
                branch: branch,
                onTap: () {
                  if (branch == null) {
                    pushWidget(
                      context: context,
                      builder: (final context) => SelectConversationBranch(
                        projectContext: widget.projectContext,
                        conversation: widget.conversation,
                        onDone: (final value) {
                          Navigator.pop(context);
                          response.nextBranch = ConversationNextBranch(
                            branchId: value.id,
                          );
                          save();
                        },
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
                soundChannel: channel,
                title: 'Next Branch',
              ),
              CallCommandListTile(
                projectContext: widget.projectContext,
                callCommand: response.command,
                onChanged: (final value) {
                  response.command = value;
                  save();
                },
              )
            ],
          ),
        ),
      );
    } else {
      title = 'If you are seeing this there is a bug!!';
      child = TabbedScaffold(
        tabs: [
          TabbedScaffoldTab(
            title: 'Conversation Settings',
            icon: const Icon(Icons.settings_outlined),
            builder: (final context) {
              final initialBranch = widget.conversation.getBranch(
                widget.conversation.initialBranchId,
              );
              return WithKeyboardShortcuts(
                keyboardShortcuts: const [_backKeyboardShortcut],
                child: ListView(
                  children: [
                    TextListTile(
                      value: widget.conversation.name,
                      onChanged: (final value) {
                        widget.conversation.name = value;
                        save();
                      },
                      header: 'Conversation Name',
                      autofocus: true,
                      labelText: 'Name',
                      validator: (final value) =>
                          validateNonEmptyValue(value: value),
                    ),
                    SoundListTile(
                      projectContext: widget.projectContext,
                      value: widget.conversation.music,
                      onDone: (final value) {
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
                      soundChannel: channel,
                      title: 'Initial Branch',
                    ),
                    ReverbListTile(
                      projectContext: widget.projectContext,
                      onDone: (final reverb) {
                        _reverb?.destroy();
                        _reverb = null;
                        _channel?.destroy();
                        _channel = null;
                        widget.conversation.reverbId = reverb?.id;
                        save();
                      },
                      reverbPresets: world.reverbs,
                      currentReverbId: widget.conversation.reverbId,
                      nullable: true,
                    )
                  ],
                ),
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
                        (final element) => element.id == widget.conversation.id,
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
            builder: (final context) {
              final branches = widget.conversation.branches;
              // No need to check if there are no branches, since there must
              // always be one for `Conversation.initialBranchId`.
              final children = <SearchableListTile>[];
              for (var i = 0; i < branches.length; i++) {
                final branch = branches[i];
                children.add(
                  SearchableListTile(
                    searchString: branch.text ?? 'Untitled Branch',
                    child: WithKeyboardShortcuts(
                      keyboardShortcuts: const [
                        KeyboardShortcut(
                          description: 'Delete the current branch.',
                          keyName: 'Delete',
                        )
                      ],
                      child: CallbackShortcuts(
                        bindings: {
                          DeleteIntent.hotkey: () =>
                              deleteBranch(context: context, branch: branch)
                        },
                        child: EditConversationBranchListTile(
                          autofocus: i == 0,
                          conversation: widget.conversation,
                          branch: branch,
                          projectContext: widget.projectContext,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return CallbackShortcuts(
                bindings: {
                  CreateConversationBranchIntent.hotkey: () =>
                      addConversationBranch(context)
                },
                child: SearchableListView(children: children),
              );
            },
            floatingActionButton: FloatingActionButton(
              onPressed: () => addConversationBranch(context),
              tooltip: 'Add Branch',
              child: createIcon,
            ),
          ),
          TabbedScaffoldTab(
            title: 'Responses',
            icon: const Icon(Icons.reply_outlined),
            builder: (final context) {
              final responses = widget.conversation.responses;
              if (responses.isEmpty) {
                return const CenterText(
                  text: 'There are no responses to show.',
                );
              }
              final children = <SearchableListTile>[];
              for (var i = 0; i < responses.length; i++) {
                final response = responses[i];
                children.add(
                  SearchableListTile(
                    searchString:
                        response.text ?? 'Untitled Conversation Response',
                    child: WithKeyboardShortcuts(
                      keyboardShortcuts: const [
                        KeyboardShortcut(
                          description: 'Delete the current response.',
                          keyName: 'Delete',
                        )
                      ],
                      child: CallbackShortcuts(
                        bindings: {
                          DeleteIntent.hotkey: () => deleteResponse(
                                context: context,
                                response: response,
                              )
                        },
                        child: ConversationResponseListTile(
                          autofocus: i == 0,
                          projectContext: widget.projectContext,
                          conversation: widget.conversation,
                          response: response,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return CallbackShortcuts(
                bindings: {
                  CreateConversationResponseIntent.hotkey: () =>
                      addConversationResponse(context),
                },
                child: SearchableListView(children: children),
              );
            },
            floatingActionButton: FloatingActionButton(
              autofocus: widget.conversation.responses.isEmpty,
              onPressed: () => addConversationResponse(context),
              tooltip: 'Add Response',
              child: createIcon,
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
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: child,
        ),
      ),
    );
  }

  /// Delete the given [branch].
  void deleteBranch({
    required final BuildContext context,
    required final ConversationBranch branch,
  }) {
    final attached = widget.conversation.initialBranchId == branch.id ||
        widget.conversation.responses
            .where((final element) => element.nextBranch?.branchId == branch.id)
            .isNotEmpty;
    if (attached) {
      showError(
        context: context,
        message: 'You cannot delete this branch because it is attached to a '
            'response.',
      );
    } else {
      confirm(
        context: context,
        message: 'Are you sure you want to delete this branch?',
        title: 'Delete Branch',
        yesCallback: () {
          Navigator.pop(context);
          widget.conversation.branches.removeWhere(
            (final element) => element.id == branch.id,
          );
          save();
        },
      );
    }
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Add a conversation response.
  Future<void> addConversationResponse(final BuildContext context) async {
    final response = ConversationResponse(
      id: newId(),
      text: 'Change me',
    );
    widget.conversation.responses.add(response);
    widget.projectContext.save();
    await pushWidget(
      context: context,
      builder: (final context) => EditConversationResponse(
        projectContext: widget.projectContext,
        conversation: widget.conversation,
        response: response,
      ),
    );
    setState(() {});
  }

  /// Add a new conversation branch.
  Future<void> addConversationBranch(final BuildContext context) async {
    final branch = ConversationBranch(id: newId(), responseIds: []);
    widget.conversation.branches.add(branch);
    widget.projectContext.save();
    await pushWidget(
      context: context,
      builder: (final context) => EditConversationBranch(
        projectContext: widget.projectContext,
        conversation: widget.conversation,
        branch: branch,
      ),
    );
    setState(() {});
  }

  /// Dispose of the sound channel.
  @override
  void dispose() {
    super.dispose();
    _channel?.destroy();
    _reverb?.destroy();
  }

  /// Delete the given [response].
  void deleteResponse({
    required final BuildContext context,
    required final ConversationResponse response,
  }) {
    final attached = widget.conversation.branches.any(
      (final element) => element.responseIds.contains(response.id),
    );
    if (attached) {
      showError(
        context: context,
        message: 'You cannot delete this response because it is attached to a '
            'branch.',
      );
    } else {
      confirm(
        context: context,
        message: 'Are you sure you want to delete this response?',
        title: 'Delete Response',
        yesCallback: () {
          Navigator.pop(context);
          widget.conversation.responses.removeWhere(
            (final element) => element.id == response.id,
          );
          save();
        },
      );
    }
  }
}
