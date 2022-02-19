import 'dart:math';

import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/get_coordinates.dart';
import 'select_box.dart';
import 'select_box_corner.dart';

/// A widget that allows full editing of its [value].
class EditCoordinates extends StatefulWidget {
  /// Create an instance.
  const EditCoordinates({
    required this.zone,
    required this.box,
    required this.value,
    this.title = 'Edit Coordinates',
    Key? key,
  }) : super(key: key);

  /// The zone which contains the box whose [value] this widget will edit.
  final Zone zone;

  /// The box that the coordinates are part of.
  final Box box;

  /// The coordinates to edit.
  final Coordinates value;

  /// The title of the resulting [Scaffold].
  final String title;

  /// Create state for this widget.
  @override
  _EditCoordinatesState createState() => _EditCoordinatesState();
}

/// State for [EditCoordinates].
class _EditCoordinatesState extends State<EditCoordinates> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final clamp = widget.value.clamp;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(
          children: [
            if (clamp != null) ...[
              ListTile(
                autofocus: true,
                title: const Text('Clamped To'),
                subtitle: Text(widget.zone.getBox(clamp.boxId).name),
                onTap: () => pushWidget(
                  context: context,
                  builder: (context) => SelectBox(
                    boxes: widget.zone.boxes
                        .where(
                          (element) => element.id != widget.box.id,
                        )
                        .toList(),
                    onDone: (value) {
                      setState(() => widget.value.clamp!.boxId = value.id);
                    },
                    currentBoxId: clamp.boxId,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Clamp Corner'),
                subtitle: Text(clamp.corner.name),
                onTap: () => pushWidget(
                  context: context,
                  builder: (context) => SelectBoxCorner(
                    onDone: (value) => setState(() => clamp.corner = value),
                    value: clamp.corner,
                  ),
                ),
              )
            ],
            ListTile(
              autofocus: clamp == null,
              title: Text(clamp == null ? 'Coordinates' : 'Coordinates Offset'),
              subtitle: Text('${widget.value.x},${widget.value.y}'),
              onTap: () => pushWidget(
                context: context,
                builder: (context) => GetCoordinates(
                  value: Point(widget.value.x, widget.value.y),
                  onDone: (value) {
                    Navigator.pop(context);
                    setState(() => widget.value
                      ..x = value.x
                      ..y = value.y);
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
