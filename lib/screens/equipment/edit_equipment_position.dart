import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing its [equipmentPosition].
class EditEquipmentPosition extends StatefulWidget {
  /// Create an instance.
  const EditEquipmentPosition({
    required this.projectContext,
    required this.equipmentPosition,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The equipment position to edit.
  final EquipmentPosition equipmentPosition;

  /// Create state for this widget.
  @override
  EditEquipmentPositionState createState() => EditEquipmentPositionState();
}

/// State for [EditEquipmentPosition].
class EditEquipmentPositionState extends State<EditEquipmentPosition> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () => deleteEquipmentPosition(
                context: context,
                equipmentPosition: widget.equipmentPosition,
                world: world,
                onDone: () {
                  Navigator.pop(context);
                  widget.projectContext.save();
                },
              ),
              child: deleteIcon,
            )
          ],
          title: const Text('Edit Equipment Position'),
        ),
        body: ListView(
          children: [
            TextListTile(
              value: widget.equipmentPosition.name,
              onChanged: (value) {
                widget.equipmentPosition.name = value;
                widget.projectContext.save();
                setState(() {});
              },
              header: 'Name',
              autofocus: true,
              title: 'Equipment Position Name',
              validator: (value) => validateNonEmptyValue(value: value),
            )
          ],
        ),
      ),
    );
  }
}
