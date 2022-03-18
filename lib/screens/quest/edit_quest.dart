import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/text_list_tile.dart';
import 'edit_quest_stage.dart';

/// A widget for editing the given [quest].
class EditQuest extends StatefulWidget {
  /// Create an instance.
  const EditQuest({
    required this.projectContext,
    required this.quest,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The quest to edit.
  final Quest quest;

  /// Create state for this widget.
  @override
  _EditQuestState createState() => _EditQuestState();
}

/// State for [EditQuest].
class _EditQuestState extends State<EditQuest> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final children = [
      TextListTile(
        value: widget.quest.name,
        onChanged: (value) {
          widget.quest.name = value;
          save();
        },
        header: 'Name',
        autofocus: true,
        validator: (value) => validateNonEmptyValue(value: value),
      )
    ];
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () {
                final quest = widget.quest;
                final id = quest.id;
                for (final category in world.commandCategories) {
                  for (final command in category.commands) {
                    if (command.setQuestStage?.questId == id) {
                      return showError(
                        context: context,
                        message: 'This quest is used by the ${command.name} '
                            'command of the ${category.name} category.',
                      );
                    }
                    for (final callCommand in command.callCommands) {
                      final conditionals = callCommand.conditions;
                      for (final conditional in conditionals) {
                        if (conditional.questCondition?.questId == id) {
                          return showError(
                            context: context,
                            message:
                                'This quest is check by the ${command.name} '
                                'command of the ${category.name} category.',
                          );
                        }
                      }
                    }
                  }
                }
                confirm(
                    context: context,
                    message:
                        'Are you sure you want to delete the ${quest.name} '
                        'quest?',
                    title: 'Delete Quest',
                    yesCallback: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      world.quests.removeWhere(
                        (element) => element.id == id,
                      );
                      save();
                    });
              },
              child: const Icon(
                Icons.delete,
                semanticLabel: 'Delete Quest',
              ),
            )
          ],
          title: const Text('Edit Quest'),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            if (index < children.length) {
              return children[index];
            }
            final stage = widget.quest.stages[index - children.length];
            final sound = stage.sound;
            final assetReference = sound == null
                ? null
                : getAssetReferenceReference(
                    assets: world.questAssets,
                    id: sound.id,
                  ).reference;
            return PlaySoundSemantics(
              child: ListTile(
                title: Text(stage.description ?? 'Not Described'),
                onTap: () async {
                  await pushWidget(
                    context: context,
                    builder: (context) => EditQuestStage(
                      projectContext: widget.projectContext,
                      quest: widget.quest,
                      stage: stage,
                    ),
                  );
                  setState(() {});
                },
              ),
              soundChannel: widget.projectContext.game.interfaceSounds,
              assetReference: assetReference,
              gain: sound?.gain ?? 0,
            );
          },
          itemCount: children.length + widget.quest.stages.length,
        ),
        floatingActionButton: FloatingActionButton(
          child: createIcon,
          onPressed: () async {
            final stage = QuestStage(
              id: newId(),
              description: 'New Quest Stage',
            );
            widget.quest.stages.add(stage);
            widget.projectContext.save();
            await pushWidget(
              context: context,
              builder: (context) => EditQuestStage(
                projectContext: widget.projectContext,
                quest: widget.quest,
                stage: stage,
              ),
            );
            setState(() {});
          },
          tooltip: 'Add Stage',
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
