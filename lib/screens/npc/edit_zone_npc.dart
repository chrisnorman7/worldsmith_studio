import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/box/coordinates_list_tile.dart';
import '../../widgets/cancel.dart';
import '../../widgets/push_widget_list_tile.dart';
import 'edit_npc_moves.dart';

/// A widget for editing the given [zoneNpc].
class EditZoneNpc extends StatefulWidget {
  /// Create an instance.
  const EditZoneNpc({
    required this.projectContext,
    required this.zone,
    required this.zoneNpc,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The zone that [zoneNpc] is attached to.
  final Zone zone;

  /// The zone NPC to edit.
  final ZoneNpc zoneNpc;

  /// Create state for this widget.
  @override
  EditZoneNpcState createState() => EditZoneNpcState();
}

/// State for [EditZoneNpc].
class EditZoneNpcState extends State<EditZoneNpc> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) => Cancel(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              ElevatedButton(
                onPressed: () {
                  confirm(
                    context: context,
                    message:
                        'Are you sure you want to unlink this NPC? The NPC '
                        'will not be deleted.',
                    yesCallback: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      widget.zone.npcs.removeWhere(
                        (final element) =>
                            element.npcId == widget.zoneNpc.npcId,
                      );
                    },
                  );
                },
                child: const Icon(
                  Icons.delete,
                  semanticLabel: 'Unlink NPC',
                ),
              )
            ],
            title: const Text('Edit ZoneNPC'),
          ),
          body: ListView(
            children: [
              CoordinatesListTile(
                projectContext: widget.projectContext,
                zone: widget.zone,
                value: widget.zoneNpc.initialCoordinates,
                onChanged: save,
                autofocus: true,
                canChangeClamp: true,
                title: 'Initial Coordinates',
              ),
              PushWidgetListTile(
                title: 'Moves',
                subtitle: '${widget.zoneNpc.moves.length}',
                builder: (final context) => EditNpcMoves(
                  projectContext: widget.projectContext,
                  zone: widget.zone,
                  zoneNpc: widget.zoneNpc,
                ),
              ),
            ],
          ),
        ),
      );

  /// Save the project context, and call[setState].
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
