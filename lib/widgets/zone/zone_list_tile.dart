import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../screens/zone/edit_zone.dart';
import '../../screens/zone/select_zone.dart';
import '../../util.dart';
import '../push_widget_list_tile.dart';

/// A widget for viewing and editing a zone.
class ZoneListTile extends StatefulWidget {
  /// Create an instance.
  const ZoneListTile({
    required this.projectContext,
    required this.onDone,
    this.zoneId,
    this.title = 'Zone',
    this.autofocus = false,
    super.key,
  });

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

  @override
  State<ZoneListTile> createState() => _ZoneListTileState();
}

class _ZoneListTileState extends State<ZoneListTile> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final id = widget.zoneId;
    final world = widget.projectContext.world;
    final currentZone = id == null ? null : world.getZone(id);
    return CallbackShortcuts(
      bindings: {
        EditIntent.hotkey: () async {
          if (currentZone != null) {
            await pushWidget(
              context: context,
              builder: (final context) => EditZone(
                projectContext: widget.projectContext,
                zone: currentZone,
              ),
            );
            setState(() {});
          }
        }
      },
      child: PushWidgetListTile(
        autofocus: widget.autofocus,
        title: widget.title,
        subtitle: currentZone == null ? 'Not set' : currentZone.name,
        builder: (final context) => SelectZone(
          projectContext: widget.projectContext,
          onDone: widget.onDone,
          zone: currentZone,
        ),
      ),
    );
  }
}
