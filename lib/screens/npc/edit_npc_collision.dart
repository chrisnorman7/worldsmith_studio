import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';
import '../../widgets/command/call_command_list_tile.dart';
import '../../widgets/number_list_tile.dart';

/// A widget to edit the given [npcCollision].
class EditNpcCollision extends StatefulWidget {
  /// Create an instance.
  const EditNpcCollision({
    required this.projectContext,
    required this.npcCollision,
    required this.onChanged,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The NPC collision to edit.
  final NpcCollision npcCollision;

  /// The function to call when [npcCollision] changes.
  final ValueChanged<NpcCollision?> onChanged;

  /// Create state for this widget.
  @override
  EditNpcCollisionState createState() => EditNpcCollisionState();
}

/// State for [EditNpcCollision].
class EditNpcCollisionState extends State<EditNpcCollision> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) => Cancel(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onChanged(null);
                },
                child: const Icon(
                  Icons.clear_outlined,
                  semanticLabel: 'Clear Collision',
                ),
              )
            ],
            title: const Text('NPC Collision Settings'),
          ),
          body: ListView(
            children: [
              CallCommandListTile(
                projectContext: widget.projectContext,
                callCommand: widget.npcCollision.callCommand,
                onChanged: (final value) {
                  widget.npcCollision.callCommand = value;
                  save();
                },
                autofocus: true,
              ),
              NumberListTile(
                value: widget.npcCollision.distance,
                onChanged: (final value) {
                  widget.npcCollision.distance = value;
                  save();
                },
                min: 0.1,
                modifier: 0.5,
                title: 'Collision Radius',
                subtitle: '${widget.npcCollision.distance} tiles',
              ),
              CheckboxListTile(
                value: widget.npcCollision.collideWithPlayer,
                onChanged: (final value) {
                  widget.npcCollision.collideWithPlayer = value ?? true;
                  save();
                },
                title: Text(
                  widget.npcCollision.collideWithPlayer
                      ? "Don't Collide With Player"
                      : 'Collide With Player',
                ),
              ),
              CheckboxListTile(
                value: widget.npcCollision.collideWithNpcs,
                onChanged: (final value) {
                  widget.npcCollision.collideWithNpcs = value ?? false;
                  save();
                },
                title: Text(
                  widget.npcCollision.collideWithNpcs
                      ? "Don't Collide With NPC's"
                      : "Collide With NPC's",
                ),
              ),
              CheckboxListTile(
                value: widget.npcCollision.collideWithObjects,
                onChanged: (final value) {
                  widget.npcCollision.collideWithObjects = value ?? false;
                  save();
                },
                title: Text(
                  widget.npcCollision.collideWithObjects
                      ? "Don't Collide With Objects"
                      : 'Collide With Objects',
                ),
              )
            ],
          ),
        ),
      );

  /// Save the project context, and call[setState].
  void save() {
    widget.onChanged(widget.npcCollision);
    setState(() {});
  }
}
