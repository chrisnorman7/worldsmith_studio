import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../quest_location.dart';
import '../../screens/quest/edit_quest.dart';
import '../../screens/quest/edit_quest_stage.dart';
import '../../util.dart';
import '../play_sound_semantics.dart';
import '../select_item.dart';

/// A widget for showing a reference to a [Quest] [stage].
class QuestListTile extends StatefulWidget {
  /// Create an instance.
  const QuestListTile({
    required this.projectContext,
    required this.quest,
    required this.stage,
    required this.onDone,
    this.title = 'Quest',
    this.autofocus = false,
    final Key? key,
  })  : assert(
          quest != null || stage == null,
          'If `quest` is not `null`, then `stage` must not be either.',
        ),
        super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The quest that is used.
  final Quest? quest;

  /// The stage in the given [quest].
  final QuestStage? stage;

  /// The function to be called with the new value.
  final ValueChanged<QuestLocation?> onDone;

  /// The title for the resulting [ListTile].
  final String? title;

  /// Whether the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Create state for this widget.
  @override
  QuestListTileState createState() => QuestListTileState();
}

/// State for [QuestListTile].
class QuestListTileState extends State<QuestListTile> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final quest = widget.quest;
    final stage = widget.stage;
    var questDescription = quest?.name ?? 'Not set';
    if (quest != null) {
      final String stageDescription;
      if (stage == null) {
        stageDescription = 'Not Started';
      } else {
        stageDescription = stage.description ?? 'Not Described';
      }
      questDescription = '$questDescription: $stageDescription';
    }
    final title = widget.title;
    return CallbackShortcuts(
      bindings: {
        EditIntent.hotkey: () async {
          if (quest != null) {
            if (stage == null) {
              await pushWidget(
                context: context,
                builder: (final context) => EditQuest(
                  projectContext: widget.projectContext,
                  quest: quest,
                ),
              );
            } else {
              await pushWidget(
                context: context,
                builder: (final context) => EditQuestStage(
                  projectContext: widget.projectContext,
                  quest: quest,
                  stage: stage,
                ),
              );
            }
            setState(() {});
          }
        }
      },
      child: ListTile(
        autofocus: widget.autofocus,
        title: Text(title ?? questDescription),
        subtitle: title == null ? null : Text(questDescription),
        onTap: () => pushWidget(
          context: context,
          builder: (final context) => SelectItem<Quest?>(
            onDone: (final newQuest) {
              if (newQuest == null) {
                Navigator.pop(context);
                widget.onDone(null);
              } else {
                pushWidget(
                  context: context,
                  builder: (final context) => SelectItem<QuestStage?>(
                    onDone: (final newStage) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      widget.onDone(
                        QuestLocation(
                          quest: newQuest,
                          stage: newStage,
                        ),
                      );
                    },
                    values: [null, ...newQuest.stages],
                    getItemWidget: (final item) {
                      if (item == null) {
                        return const Text('Not Started');
                      } else {
                        final sound = item.sound;
                        final assetReference = sound == null
                            ? null
                            : getAssetReferenceReference(
                                assets: world.questAssets,
                                id: sound.id,
                              ).reference;
                        return PlaySoundSemantics(
                          soundChannel:
                              widget.projectContext.game.interfaceSounds,
                          assetReference: assetReference,
                          gain: sound?.gain ?? world.soundOptions.defaultGain,
                          child: Text('${item.description}'),
                        );
                      }
                    },
                    title: 'Select Stage',
                    value: stage,
                  ),
                );
              }
            },
            values: [null, ...world.quests],
            getItemWidget: (final item) {
              if (item == null) {
                return const Text('Clear');
              } else {
                return Text(item.name);
              }
            },
            title: 'Select Quest',
            value: quest,
          ),
        ),
      ),
    );
  }
}
