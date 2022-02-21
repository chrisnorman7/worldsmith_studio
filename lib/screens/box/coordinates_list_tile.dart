import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
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
class CoordinatesListTile extends StatefulWidget {
  /// Create an instance.
  const CoordinatesListTile({
    required this.projectContext,
    required this.zone,
    required this.value,
    required this.onChanged,
    this.box,
    this.actions = const [],
    this.title = 'Coordinates',
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The zone that contains the box who the given coordinates belong to.
  final Zone zone;

  /// The box which owns the coordinates.
  final Box? box;

  /// The coordinates to edit.
  final Coordinates value;

  /// The function to call when [value] has been updated.
  final VoidCallback onChanged;

  /// The actions for the resulting [AppBar].
  final List<Widget> actions;

  /// The title of the resulting [ListTile].
  final String title;

  @override
  State<CoordinatesListTile> createState() => _CoordinatesListTileState();
}

class _CoordinatesListTileState extends State<CoordinatesListTile> {
  @override
  Widget build(BuildContext context) {
    final coordinates = widget.zone.getAbsoluteCoordinates(widget.value);
    final modifyCoordinateAction = CallbackAction<ModifyCoordinateIntent>(
      onInvoke: (intent) {
        final int x;
        final int y;
        switch (intent.modification) {
          case CoordinateModification.increaseX:
            x = widget.value.x + 1;
            y = widget.value.y;
            break;
          case CoordinateModification.decreaseX:
            x = widget.value.x - 1;
            y = widget.value.y;
            break;
          case CoordinateModification.increaseY:
            x = widget.value.x;
            y = widget.value.y + 1;
            break;
          case CoordinateModification.decreaseY:
            x = widget.value.x;
            y = widget.value.y - 1;
            break;
        }
        widget.value
          ..x = x
          ..y = y;
        save();
        return null;
      },
    );
    return Shortcuts(
      child: Actions(
        actions: {ModifyCoordinateIntent: modifyCoordinateAction},
        child: ListTile(
          title: Text(widget.title),
          subtitle: Text('${coordinates.x},${coordinates.y}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (context) => EditCoordinates(
                zone: widget.zone,
                box: widget.box,
                value: widget.value,
                title: widget.title,
              ),
            );
            save();
          },
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

  /// Save the project context.
  void save() {
    widget.projectContext.save();
    setState(widget.onChanged);
  }
}
