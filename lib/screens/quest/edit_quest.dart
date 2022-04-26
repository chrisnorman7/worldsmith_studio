// ignore_for_file: prefer_final_parameters
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
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The quest to edit.
  final Quest quest;

  /// Create state for this widget.
  @override
  EditQuestState createState() => EditQuestState();
}

/// State for [EditQuest].
class EditQuestState extends State<EditQuest> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final children = [
      TextListTile(
        value: widget.quest.name,
        onChanged: (final value) {
          widget.quest.name = value;
          save();
        },
        header: 'Name',
        autofocus: true,
        validator: (final value) => validateNonEmptyValue(value: value),
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
                  message: 'Are you sure you want to delete the ${quest.name} '
                      'quest?',
                  title: 'Delete Quest',
                  yesCallback: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    world.quests.removeWhere(
                      (final element) => element.id == id,
                    );
                    save();
                  },
                );
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
          itemBuilder: (final context, final index) {
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
              soundChannel: widget.projectContext.game.interfaceSounds,
              assetReference: assetReference,
              gain: sound?.gain ?? 0,
              child: ListTile(
                title: Text(stage.description ?? 'Not Described'),
                onTap: () async {
                  await pushWidget(
                    context: context,
                    builder: (final context) => EditQuestStage(
                      projectContext: widget.projectContext,
                      quest: widget.quest,
                      stage: stage,
                    ),
                  );
                  setState(() {});
                },
              ),
            );
          },
          itemCount: children.length + widget.quest.stages.length,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final stage = QuestStage(
              id: newId(),
              description: 'New Quest Stage',
            );
            widget.quest.stages.add(stage);
            widget.projectContext.save();
            await pushWidget(
              context: context,
              builder: (final context) => EditQuestStage(
                projectContext: widget.projectContext,
                quest: widget.quest,
                stage: stage,
              ),
            );
            setState(() {});
          },
          tooltip: 'Add Stage',
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
