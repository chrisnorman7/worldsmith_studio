import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/select_item.dart';

/// A widget which allows the selection of a zone.
class SelectZone extends StatelessWidget {
  /// Create an instance.
  const SelectZone({
    required this.projectContext,
    required this.onDone,
    this.zone,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The function to be called with the new value.
  final ValueChanged<Zone> onDone;

  /// The current zone.
  final Zone? zone;

  /// Build a widget.
  @override
  Widget build(BuildContext context) => Cancel(
        child: SelectItem<Zone>(
          onDone: onDone,
          values: projectContext.world.zones,
          getItemWidget: (zone) => Text(zone.name),
          title: 'Select Zone',
          value: zone,
        ),
      );
}
