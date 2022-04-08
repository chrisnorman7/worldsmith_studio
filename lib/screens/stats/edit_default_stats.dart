import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/number_list_tile.dart';
import '../../widgets/searchable_list_view.dart';

/// A widget for editing the given [stats].
class EditDefaultStats extends StatefulWidget {
  /// Create an instance.
  const EditDefaultStats({
    required this.projectContext,
    required this.stats,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The stats to edit.
  final StatsMap stats;

  /// Create state for this widget.
  @override
  EditDefaultStatsState createState() => EditDefaultStatsState();
}

/// State for [EditDefaultStats].
class EditDefaultStatsState extends State<EditDefaultStats> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final stats = world.stats;
    final Widget child;
    if (stats.isEmpty) {
      child = const CenterText(text: 'There are no stats to modify.');
    } else {
      child = WithKeyboardShortcuts(
        keyboardShortcuts: const [
          KeyboardShortcut(
            description: 'Reset stat value.',
            keyName: 'Delete',
          )
        ],
        child: BuiltSearchableListView(
          items: stats,
          builder: (final context, final index) {
            final stat = stats[index];
            final value = widget.stats[stat.id] ?? stat.defaultValue;
            return SearchableListTile(
              searchString: stat.name,
              child: CallbackShortcuts(
                bindings: {
                  DeleteIntent.hotkey: () {
                    widget.stats.remove(stat.id);
                    save();
                  }
                },
                child: NumberListTile(
                  onChanged: (final value) {
                    widget.stats[stat.id] = value.floor();
                    save();
                  },
                  value: value.toDouble(),
                  autofocus: index == 0,
                  modifier: 5,
                  title: stat.name,
                  subtitle: '$value'
                      '${value != stat.defaultValue ? " (Modified)" : ""}',
                ),
              ),
            );
          },
        ),
      );
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Default Stats'),
        ),
        body: child,
      ),
    );
  }

  /// Save the NPC.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
