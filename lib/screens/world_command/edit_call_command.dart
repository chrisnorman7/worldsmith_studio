import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/command/world_command_list_tile.dart';
import '../../widgets/get_number.dart';
import '../../widgets/get_text.dart';
import '../../widgets/number_list_tile.dart';
import '../../widgets/tabbed_scaffold.dart';
import '../../world_command_location.dart';

/// A widget for editing its [callCommand].
class EditCallCommand extends StatefulWidget {
  /// Create an instance.
  const EditCallCommand({
    required this.projectContext,
    required this.callCommand,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The call command to edit.
  final CallCommand callCommand;

  /// The function to call when [callCommand] changes.
  final ValueChanged<CallCommand?> onChanged;

  /// Create state for this widget.
  @override
  _EditCallCommandState createState() => _EditCallCommandState();
}

/// State for [EditCallCommand].
class _EditCallCommandState extends State<EditCallCommand> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final location = WorldCommandLocation.find(
      categories: widget.projectContext.world.commandCategories,
      commandId: widget.callCommand.commandId,
    );
    return Cancel(
      child: TabbedScaffold(
        tabs: [
          TabbedScaffoldTab(
            title: 'Settings',
            icon: const Icon(Icons.settings),
            builder: (context) {
              final callAfter = widget.callCommand.callAfter;
              var callAfterString = '$callAfter';
              if (callAfter != null) {
                callAfterString += ' millisecond';
                if (callAfter != 1) {
                  callAfterString += 's';
                }
              }
              return ListView(
                children: [
                  WorldCommandListTile(
                    projectContext: widget.projectContext,
                    currentId: location.command.id,
                    onChanged: (value) {
                      widget.callCommand.commandId = value!.id;
                      save();
                    },
                    title: 'Command',
                    autofocus: true,
                  ),
                  NumberListTile(
                    value: widget.callCommand.callAfter?.toDouble() ?? 0.0,
                    onChanged: (value) {
                      if (value <= 0) {
                        widget.callCommand.callAfter = null;
                      } else {
                        widget.callCommand.callAfter = value.floor();
                      }
                      save();
                    },
                    min: 0,
                    title: 'Call After',
                    subtitle: callAfterString,
                  )
                ],
              );
            },
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onChanged(null);
                },
                child: const Icon(
                  Icons.clear_outlined,
                  semanticLabel: 'Clear Command',
                ),
              )
            ],
          ),
          TabbedScaffoldTab(
              title: 'Conditions',
              icon: const Icon(Icons.question_answer),
              builder: (context) {
                final conditions = widget.callCommand.conditions;
                if (conditions.isEmpty) {
                  return const CenterText(text: 'There are no conditions.');
                }
                final rows = <TableRow>[
                  const TableRow(
                    children: [
                      TableCell(child: Text('Quest')),
                      TableCell(child: Text('Random Chance')),
                      TableCell(child: Text('Condition Function')),
                      TableCell(child: Text('Delete'))
                    ],
                  ),
                ];
                for (final condition in conditions) {
                  rows.add(getTableRow(context, condition));
                }
                return Table(children: rows);
              },
              floatingActionButton: FloatingActionButton(
                autofocus: widget.callCommand.conditions.isEmpty,
                child: createIcon,
                onPressed: () {
                  final conditional = Conditional();
                  widget.callCommand.conditions.add(conditional);
                  save();
                },
              ))
        ],
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Get the table row for the given [conditional].
  TableRow getTableRow(BuildContext context, Conditional conditional) {
    final world = widget.projectContext.world;
    final questCondition = conditional.questCondition;
    final quest =
        questCondition == null ? null : world.getQuest(questCondition.questId);
    final questStageId = questCondition?.stageId;
    final questStage = quest == null || questStageId == null
        ? null
        : quest.getStage(questStageId);
    var questDescription = quest == null ? 'Not Set' : '${quest.name}: ';
    if (quest != null) {
      questDescription += questStage == null
          ? 'Not started'
          : questStage.description ?? 'Not described';
    }
    final chance = conditional.chance;
    final conditionalFunctionName = conditional.conditionFunctionName;
    final chanceDescription = chance == 1 ? 'Every time' : '1 in $chance';
    final conditionalFunctionNameDescription =
        conditionalFunctionName ?? 'Not set';
    return TableRow(
      children: [
        TableCell(
          child: TextButton(
            child: Semantics(
              child: Text(questDescription),
              label: 'Quest: $questDescription',
            ),
            onPressed: () {},
          ),
        ),
        TableCell(
          child: CallbackShortcuts(
            child: TextButton(
              onPressed: () => pushWidget(
                context: context,
                builder: (context) => GetNumber(
                  value: chance.toDouble(),
                  onDone: (value) {
                    Navigator.pop(context);
                    conditional.chance = value.floor();
                    save();
                  },
                  min: 1,
                  labelText: 'Chance',
                  title: 'Call Chance',
                ),
              ),
              child: Semantics(
                child: Text(chanceDescription),
                label: 'Random Chance: $chanceDescription',
              ),
            ),
            bindings: {
              DecreaseIntent.hotkey: () {
                if (chance > 1) {
                  conditional.chance = chance - 1;
                  save();
                }
              },
              IncreaseIntent.hotkey: () {
                conditional.chance++;
                save();
              }
            },
          ),
        ),
        TableCell(
          child: TextButton(
            onPressed: () => pushWidget(
              context: context,
              builder: (context) => GetText(
                onDone: (value) {
                  Navigator.pop(context);
                  conditional.conditionFunctionName =
                      value.isEmpty ? null : value;
                  save();
                },
                text: conditionalFunctionName,
                title: 'Conditional Function Name',
              ),
            ),
            child: Semantics(
              child: Text(conditionalFunctionNameDescription),
              label: 'Function Name: $conditionalFunctionNameDescription',
            ),
          ),
        ),
        TableCell(
          child: IconButton(
            icon: const Icon(
              Icons.delete_outline,
              semanticLabel: 'Delete Condition',
            ),
            onPressed: () => confirm(
                context: context,
                message: 'Are you sure you want to delete this condition?',
                title: 'Delete Condition',
                yesCallback: () {
                  Navigator.pop(context);
                  widget.callCommand.conditions.remove(conditional);
                  save();
                }),
          ),
        )
      ],
    );
  }
}
