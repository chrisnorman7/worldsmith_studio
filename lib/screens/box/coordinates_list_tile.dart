import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../util.dart';
import 'edit_coordinates.dart';

/// What should happen to a coordinate.
enum CoordinateModification {
  /// Increase x coordinate.
  increaseX,

  /// Decrease x coordinate.
  decreaseX,

  /// Increase y coordinate.
  increaseY,

  /// Decrease y coordinate.
  decreaseY,
}

/// An intent to change a coordinate.
class ModifyCoordinateIntent extends Intent {
  /// Create an instance.
  const ModifyCoordinateIntent(this.modification);

  /// The modification to apply.
  final CoordinateModification modification;
}

/// A list tile that shows the given [value].
class CoordinatesListTile extends StatelessWidget {
  /// Create an instance.
  const CoordinatesListTile({
    required this.value,
    required this.zone,
    required this.onChanged,
    this.title = 'Coordinates',
    Key? key,
  }) : super(key: key);

  /// The coordinates to edit.
  final Coordinates value;

  /// The zone that contains the box who the given coordinates belong to.
  final Zone zone;

  /// The function to call when the value changes.
  final ValueChanged<Coordinates> onChanged;

  /// The title of the resulting [ListTile].
  final String title;

  @override
  Widget build(BuildContext context) {
    final coordinates = zone.getAbsoluteCoordinates(value);
    final modifyCoordinateAction = CallbackAction<ModifyCoordinateIntent>(
      onInvoke: (intent) {
        final int x;
        final int y;
        switch (intent.modification) {
          case CoordinateModification.increaseX:
            x = value.x + 1;
            y = value.y;
            break;
          case CoordinateModification.decreaseX:
            x = value.x - 1;
            y = value.y;
            break;
          case CoordinateModification.increaseY:
            x = value.x;
            y = value.y + 1;
            break;
          case CoordinateModification.decreaseY:
            x = value.x;
            y = value.y - 1;
            break;
        }
        onChanged(
          Coordinates(x, y, clamp: value.clamp),
        );
        return null;
      },
    );
    return Shortcuts(
      child: Actions(
        actions: {ModifyCoordinateIntent: modifyCoordinateAction},
        child: ListTile(
          title: Text(title),
          subtitle: Text('${coordinates.x},${coordinates.y}'),
          onTap: () => pushWidget(
            context: context,
            builder: (context) => EditCoordinates(
              zone: zone,
              value: value,
              onChanged: onChanged,
              title: title,
            ),
          ),
        ),
      ),
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowUp, alt: true):
            ModifyCoordinateIntent(
          CoordinateModification.increaseY,
        ),
        SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
            ModifyCoordinateIntent(
          CoordinateModification.decreaseY,
        ),
        SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true):
            ModifyCoordinateIntent(
          CoordinateModification.decreaseX,
        ),
        SingleActivator(LogicalKeyboardKey.arrowRight, alt: true):
            ModifyCoordinateIntent(
          CoordinateModification.increaseX,
        ),
      },
    );
  }
}
