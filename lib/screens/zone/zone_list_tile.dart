import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import 'select_zone.dart';

/// A widget for viewing and editing a zone.
class ZoneListTile extends StatelessWidget {
  /// Create an instance.
  const ZoneListTile({
    required this.projectContext,
    required this.onDone,
    this.zoneId,
    this.title = 'Zone',
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The function to be called with the resulting zone.
  final ValueChanged<Zone> onDone;

  /// The current zone ID.
  final String? zoneId;

  /// The title of the resulting [ListTile].
  final String title;

  /// Whether or not the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final id = zoneId;
    final world = projectContext.world;
    final currentZone = id == null ? null : world.getZone(id);
    return ListTile(
      autofocus: autofocus,
      title: Text(title),
      subtitle: Text(currentZone == null ? 'Not set' : currentZone.name),
      onTap: () => pushWidget(
        context: context,
        builder: (context) => SelectZone(
          projectContext: projectContext,
          onDone: onDone,
          zone: currentZone,
        ),
      ),
    );
  }
}
