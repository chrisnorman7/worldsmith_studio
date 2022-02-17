import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import 'edit_equipment_position.dart';

/// A menu for displaying and editing equipment positions.
class EquipmentPositionsMenu extends StatefulWidget {
  /// Create an instance.
  const EquipmentPositionsMenu({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _EquipmentPositionsMenuState createState() => _EquipmentPositionsMenuState();
}

/// State for [EquipmentPositionsMenu].
class _EquipmentPositionsMenuState extends State<EquipmentPositionsMenu> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Equipment Positions'),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            final position = world.equipmentPositions[index];
            return ListTile(
              autofocus: index == 0,
              leading: index == 0
                  ? null
                  : IconButton(
                      onPressed: () {
                        world.equipmentPositions.removeAt(index);
                        world.equipmentPositions.insert(index - 1, position);
                        widget.projectContext.save();
                        setState(() {});
                      },
                      icon: const Icon(Icons.move_up_outlined),
                      tooltip: 'Move Up',
                    ),
              title: Text(position.name),
              onTap: () async {
                await pushWidget(
                  context: context,
                  builder: (context) => EditEquipmentPosition(
                    projectContext: widget.projectContext,
                    equipmentPosition: position,
                  ),
                );
                setState(() {});
              },
            );
          },
          itemCount: world.equipmentPositions.length,
        ),
        floatingActionButton: FloatingActionButton(
          autofocus: world.equipmentPositions.isEmpty,
          onPressed: () async {
            final position = EquipmentPosition(
              id: newId(),
              name: 'Untitled Equipment Position',
            );
            world.equipmentPositions.add(position);
            widget.projectContext.save();
            await pushWidget(
              context: context,
              builder: (context) => EditEquipmentPosition(
                projectContext: widget.projectContext,
                equipmentPosition: position,
              ),
            );
            setState(() {});
          },
          child: createIcon,
          tooltip: 'Add Equipment Position',
        ),
      ),
    );
  }
}
