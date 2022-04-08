import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/push_widget_list_tile.dart';
import '../../widgets/searchable_list_view.dart';
import 'edit_world_stat.dart';

/// A widget for viewing and changing statistics.
class EditWorldStats extends StatefulWidget {
  /// Create an instance.
  const EditWorldStats({
    required this.projectContext,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  EditWorldStatsState createState() => EditWorldStatsState();
}

/// State for [EditWorldStats].
class EditWorldStatsState extends State<EditWorldStats> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final stats = widget.projectContext.world.stats;
    final Widget child;
    if (stats.isEmpty) {
      child = const CenterText(text: 'There are no stats to show.');
    } else {
      final children = <SearchableListTile>[];
      for (var i = 0; i < stats.length; i++) {
        final stat = stats[i];
        children.add(
          SearchableListTile(
            searchString: stat.name,
            child: PushWidgetListTile(
              autofocus: i == 0,
              title: stat.name,
              subtitle: stat.description,
              builder: (final context) => EditWorldStat(
                projectContext: widget.projectContext,
                stat: stat,
              ),
            ),
          ),
        );
      }
      child = SearchableListView(children: children);
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stats'),
        ),
        body: child,
        floatingActionButton: FloatingActionButton(
          autofocus: stats.isEmpty,
          child: createIcon,
          onPressed: () async {
            final stat = WorldStat(id: newId());
            stats.add(stat);
            widget.projectContext.save();
            await pushWidget(
              context: context,
              builder: (final context) => EditWorldStat(
                projectContext: widget.projectContext,
                stat: stat,
              ),
            );
            setState(() {});
          },
          tooltip: 'Add Stat',
        ),
      ),
    );
  }
}
