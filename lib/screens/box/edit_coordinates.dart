import 'dart:math';

import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/get_coordinates.dart';
import 'select_box.dart';
import 'select_box_corner.dart';

/// A widget that allows full editing of its [value].
class EditCoordinates extends StatefulWidget {
  /// Create an instance.
  const EditCoordinates({
    required this.projectContext,
    required this.zone,
    required this.value,
    this.box,
    this.actions = const [],
    this.title = 'Edit Coordinates',
    this.canChangeClamp = false,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The zone which contains the box whose [value] this widget will edit.
  final Zone zone;

  /// The box that the coordinates are part of.
  final Box? box;

  /// The coordinates to edit.
  final Coordinates value;

  /// The actions for the resulting [AppBar];
  final List<Widget> actions;

  /// The title of the resulting [Scaffold].
  final String title;

  /// Whether or not the clamp can be changed.
  ///
  /// This value was added so that [WorldCommand] instances could have fine
  /// control over [ZoneTeleport] instances.
  final bool canChangeClamp;

  /// Create state for this widget.
  @override
  EditCoordinatesState createState() => EditCoordinatesState();
}

/// State for [EditCoordinates].
class EditCoordinatesState extends State<EditCoordinates> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final clamp = widget.value.clamp;
    final boxId = widget.box?.id;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: widget.actions,
          title: Text(widget.title),
        ),
        body: ListView(
          children: [
            if (clamp != null) ...[
              ListTile(
                autofocus: true,
                title: const Text('Clamped To'),
                subtitle: Text(
                  widget.zone.getBox(clamp.boxId).name,
                ),
                onTap: () => pushWidget(
                  context: context,
                  builder: (final context) => SelectBox(
                    zone: widget.zone,
                    onDone: (final value) {
                      Navigator.pop(context);
                      setState(() => widget.value.clamp!.boxId = value.id);
                    },
                    currentBoxId: clamp.boxId,
                    excludedBoxIds: [if (boxId != null) boxId],
                  ),
                ),
              ),
              ListTile(
                title: const Text('Clamp Corner'),
                subtitle: Text(clamp.corner.name),
                onTap: () => pushWidget(
                  context: context,
                  builder: (final context) => SelectBoxCorner(
                    onDone: (final value) {
                      Navigator.pop(context);
                      setState(() => clamp.corner = value);
                    },
                    value: clamp.corner,
                  ),
                ),
              )
            ],
            if (clamp == null && widget.canChangeClamp == true) ...[
              ListTile(
                title: const Text('Clamp Coordinates'),
                onTap: () async {
                  await pushWidget(
                    context: context,
                    builder: (final context) => SelectBox(
                      zone: widget.zone,
                      onDone: (final box) => pushWidget(
                        context: context,
                        builder: (final context) => SelectBoxCorner(
                          onDone: (final corner) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            widget.value.clamp = CoordinateClamp(
                              boxId: box.id,
                              corner: corner,
                            );
                          },
                        ),
                      ),
                    ),
                  );
                  setState(() {});
                },
              )
            ],
            ListTile(
              autofocus: clamp == null,
              title: Text(clamp == null ? 'Coordinates' : 'Coordinates Offset'),
              subtitle: Text('${widget.value.x},${widget.value.y}'),
              onTap: () => pushWidget(
                context: context,
                builder: (final context) => GetCoordinates(
                  value: Point(widget.value.x, widget.value.y),
                  onDone: (final value) {
                    Navigator.pop(context);
                    setState(
                      () => widget.value
                        ..x = value.x
                        ..y = value.y,
                    );
                  },
                  labelText:
                      clamp == null ? 'Coordinates' : 'Coordinates Offset',
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
