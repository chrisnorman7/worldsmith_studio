import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../widgets/cancel.dart';

/// A widget for selecting a box from a [zone].
class SelectBox extends StatelessWidget {
  /// Create an instance.
  const SelectBox({
    required this.zone,
    required this.onDone,
    this.currentBoxId,
    this.excludedBoxIds = const [],
    this.title = 'Select Box',
    this.canClear = false,
    final Key? key,
  }) : super(key: key);

  /// The zone which contains the boxes to choose from.
  final Zone zone;

  /// The function to call with the selected box.
  final ValueChanged<Box?> onDone;

  /// The ID of the currently-selected box.
  final String? currentBoxId;

  /// A list of Ids to ignore.
  final List<String> excludedBoxIds;

  /// The title of the resulting [Scaffold].
  final String title;

  /// Whether or not the box can be cleared.
  final bool canClear;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final boxes = zone.boxes
        .where(
          (final element) => excludedBoxIds.contains(element.id) == false,
        )
        .toList();
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (canClear == true)
              ElevatedButton(
                onPressed: () => onDone(null),
                child: const Icon(
                  Icons.clear,
                  semanticLabel: 'Clear Box',
                ),
              )
          ],
          title: Text(title),
        ),
        body: ListView.builder(
          itemBuilder: (final context, final index) {
            final box = boxes[index];
            final startCoordinates = zone.getAbsoluteCoordinates(box.start);
            final endCoordinates = zone.getAbsoluteCoordinates(box.end);
            return ListTile(
              autofocus: currentBoxId == box.id || index == 0,
              title: Text(box.name),
              subtitle: Text(
                '${startCoordinates.x},${startCoordinates.y} -- '
                '${endCoordinates.x},${endCoordinates.y}',
              ),
              onTap: () => onDone(box),
              selected: box.id == currentBoxId,
            );
          },
          itemCount: boxes.length,
        ),
      ),
    );
  }
}
