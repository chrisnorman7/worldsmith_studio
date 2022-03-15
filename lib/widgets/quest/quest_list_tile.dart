import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../quest_location.dart';
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
    Key? key,
  })  : assert(
          stage != null || quest == null,
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
  final String title;

  /// Whether the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Create state for this widget.
  @override
  _QuestListTileState createState() => _QuestListTileState();
}

/// State for [QuestListTile].
class _QuestListTileState extends State<QuestListTile> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final quest = widget.quest;
    final stage = widget.stage;
    var questDescription = quest?.name ?? 'Not set';
    if (stage != null) {
      questDescription = '$questDescription: ${stage.description}';
    }
    return ListTile(
      autofocus: widget.autofocus,
      title: Text(widget.title),
      subtitle: Text(questDescription),
      onTap: () => pushWidget(
        context: context,
        builder: (context) => SelectItem<Quest?>(
          onDone: (newQuest) {
            if (newQuest == null) {
              Navigator.pop(context);
              widget.onDone(null);
            } else {
              pushWidget(
                context: context,
                builder: (context) => SelectItem<QuestStage?>(
                  onDone: (newStage) {
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
                  getItemWidget: (item) {
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
                        child: Text('${item.description}'),
                        soundChannel:
                            widget.projectContext.game.interfaceSounds,
                        assetReference: assetReference,
                        gain: sound?.gain ?? world.soundOptions.defaultGain,
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
          getItemWidget: (item) {
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
    );
  }
}
