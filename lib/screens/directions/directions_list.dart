import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import 'edit_direction.dart';

/// A widget for viewing and editing custom directions.
class DirectionsList extends StatefulWidget {
  /// Create an instance.
  const DirectionsList({
    required this.projectContext,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  DirectionsListState createState() => DirectionsListState();
}

/// State for [DirectionsList].
class DirectionsListState extends State<DirectionsList> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final children = <Widget>[];
    final entries = world.directions.entries.toList()
      ..sort((final a, final b) => a.value.compareTo(b.value));
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      children.add(
        ListTile(
          autofocus: i == 0,
          title: Text(entry.key),
          subtitle: Text('${entry.value}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (final context) => EditDirection(
                projectContext: widget.projectContext,
                name: entry.key,
                degrees: entry.value,
              ),
            );
            setState(() {});
          },
        ),
      );
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Directions'),
        ),
        body: ListView(
          children: children,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            for (var i = 0; i <= 360; i++) {
              if (world.directions.values
                  .where(
                    (final element) => element.floor() == i,
                  )
                  .isEmpty) {
                world.directions['Untitled Direction'] = i.toDouble();
                setState(() {});
                return;
              }
            }
            showError(
              context: context,
              message: 'You already have 360 directions.',
            );
          },
          autofocus: world.directions.isEmpty,
          tooltip: 'Add Direction',
          child: createIcon,
        ),
      ),
    );
  }
}
