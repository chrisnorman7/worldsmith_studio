import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing a [stage] in a [quest].
class EditQuestStage extends StatefulWidget {
  /// Create an instance.
  const EditQuestStage({
    required this.projectContext,
    required this.quest,
    required this.stage,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The quest which owns [stage].
  final Quest quest;

  /// The stage in the [quest].
  final QuestStage stage;

  /// Create state for this widget.
  @override
  EditQuestStageState createState() => EditQuestStageState();
}

/// State for [EditQuestStage].
class EditQuestStageState extends State<EditQuestStage> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () {
                for (final category in world.commandCategories) {
                  for (final command in category.commands) {
                    final setQuestStage = command.setQuestStage;
                    if (setQuestStage?.questId == widget.quest.id &&
                        setQuestStage?.stageId == widget.stage.id) {
                      return showError(
                        context: context,
                        message:
                            'This stage is used by the ${command.name} command '
                            'of the ${category.name} category.',
                      );
                    }
                    for (final callCommand in command.callCommands) {
                      final conditions = callCommand.conditions;
                      for (final condition in conditions) {
                        final questCondition = condition.questCondition;
                        if (questCondition?.questId == widget.quest.id &&
                            questCondition?.stageId == widget.stage.id) {
                          return showError(
                            context: context,
                            message: 'This stage is relied upon by the '
                                '${command.name} command of the '
                                '${category.name} category.',
                          );
                        }
                      }
                    }
                  }
                }
                confirm(
                  context: context,
                  message: 'Are you sure you want to delete this stage?',
                  title: 'Delete Quest Stage',
                  yesCallback: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    widget.quest.stages.removeWhere(
                      (final element) => element.id == widget.stage.id,
                    );
                    widget.projectContext.save();
                  },
                );
              },
              child: const Icon(
                Icons.delete,
                semanticLabel: 'Delete Stage',
              ),
            )
          ],
          title: const Text('Edit Quest Stage'),
        ),
        body: ListView(
          children: [
            TextListTile(
              value: widget.stage.description ?? '',
              onChanged: (final value) {
                widget.stage.description = value.isEmpty ? null : value;
                save();
              },
              header: 'Description',
              autofocus: true,
              title: 'Description',
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: widget.stage.sound,
              onDone: (final value) {
                widget.stage.sound = value;
                save();
              },
              assetStore: world.questsAssetStore,
              defaultGain: world.soundOptions.defaultGain,
              nullable: true,
            )
          ],
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
