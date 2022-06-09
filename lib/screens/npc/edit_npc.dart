import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/push_widget_list_tile.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/text_list_tile.dart';
import '../stats/edit_default_stats.dart';

/// A widget for editing the given [npc].
class EditNpc extends StatefulWidget {
  /// Create an instance.
  const EditNpc({
    required this.projectContext,
    required this.npc,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The NPC to edit.
  final Npc npc;

  /// Create state for this widget.
  @override
  EditNpcState createState() => EditNpcState();
}

/// State for [EditNpc].
class EditNpcState extends State<EditNpc> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final defaultGain = world.soundOptions.defaultGain;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit NPC'),
        ),
        body: ListView(
          children: [
            TextListTile(
              value: widget.npc.name,
              onChanged: (final value) {
                widget.npc.name = value;
                save();
              },
              header: 'Name',
              autofocus: true,
              validator: (final value) => validateNonEmptyValue(value: value),
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: widget.npc.ambiance,
              onDone: (final value) {
                widget.npc.ambiance = value;
                save();
              },
              assetStore: world.ambianceAssetStore,
              defaultGain: defaultGain,
              looping: true,
              nullable: true,
              title: 'Ambiance',
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: widget.npc.icon,
              onDone: (final value) {
                widget.npc.icon = value;
                save();
              },
              assetStore: world.interfaceSoundsAssetStore,
              defaultGain: defaultGain,
              nullable: true,
              title: 'Look Around Icon',
            ),
            PushWidgetListTile(
              title: 'Default Stats',
              builder: (final context) => EditDefaultStats(
                projectContext: widget.projectContext,
                stats: widget.npc.stats.defaultStats,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Save the NPC.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
