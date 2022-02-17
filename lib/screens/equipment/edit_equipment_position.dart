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
  _EditEquipmentPositionState createState() => _EditEquipmentPositionState();
}

/// State for [EditEquipmentPosition].
class _EditEquipmentPositionState extends State<EditEquipmentPosition> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () => confirm(
                  context: context,
                  message: 'Are you sure you want to delete the '
                      '${widget.equipmentPosition.name} equipment position?',
                  title: 'Delete Equipment Position',
                  yesCallback: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    world.equipmentPositions.removeWhere(
                      (element) => element.id == widget.equipmentPosition.id,
                    );
                    widget.projectContext.save();
                  }),
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
