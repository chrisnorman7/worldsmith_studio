import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/tabbed_scaffold.dart';
import '../../widgets/text_list_tile.dart';
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
            builder: (context) => ListView.builder(
              itemBuilder: (context, index) {
                final id = widget.branch.responseIds[index];
                final response = widget.conversation.getResponse(id);
                return PlaySoundSemantics(
                  child: ListTile(
                    autofocus: index == 0,
                    title: Text('${response.text}'),
                    onTap: () {
                      widget.branch.responseIds.remove(id);
                      save();
                    },
                  ),
                  soundChannel: widget.projectContext.game.interfaceSounds,
                  assetReference: getAssetReferenceReference(
                    assets: world.conversationAssets,
                    id: response.sound?.id,
                  )?.reference,
                  gain: world.soundOptions.defaultGain,
                );
              },
              itemCount: widget.branch.responseIds.length,
            ),
            floatingActionButton: FloatingActionButton(
              autofocus: widget.branch.responseIds.isEmpty,
              onPressed: () => pushWidget(
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
              ),
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
}
