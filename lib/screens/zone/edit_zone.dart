import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/tabbed_scaffold.dart';
import '../../widgets/text_list_tile.dart';
import '../sound/sound_list_tile.dart';
import '../terrain/select_terrain.dart';

/// A widget for editing its [zone].
class EditZone extends StatefulWidget {
  /// Create an instance.
  const EditZone({
    required this.projectContext,
    required this.zone,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The zone to edit.
  final Zone zone;

  /// Create state for this widget.
  @override
  _EditZoneState createState() => _EditZoneState();
}

/// State for [EditZone].
class _EditZoneState extends State<EditZone> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () {
                final id = widget.zone.id;
                confirm(
                  context: context,
                  message: 'Are you sure you want to delete the '
                      '${widget.zone.name} zone?',
                  title: 'Confirm Delete',
                  yesCallback: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    world.zones.removeWhere((element) => element.id == id);
                    widget.projectContext.save();
                  },
                );
              },
              child: deleteIcon,
            )
          ],
          title: Text(widget.zone.name),
        ),
        body: TabbedScaffold(
          tabs: [
            TabbedScaffoldTab(
              title: 'Zone Settings',
              icon: const Icon(Icons.settings_display_outlined),
              child: settingsListView,
            ),
            TabbedScaffoldTab(
              title: 'Boxes',
              icon: const Icon(Icons.map_outlined),
              child: boxesListView,
            )
          ],
        ),
      ),
    );
  }

  /// Get the zone settings list view.
  ListView get settingsListView {
    final world = widget.projectContext.world;
    final music = widget.zone.music;
    return ListView(
      children: [
        TextListTile(
            value: widget.zone.name,
            onChanged: (value) {
              widget.zone.name = value;
              widget.projectContext.save();
              setState(() {});
            },
            header: 'Name',
            autofocus: true,
            validator: (value) => validateNonEmptyValue(value: value)),
        SoundListTile(
          projectContext: widget.projectContext,
          value: music,
          onDone: (value) {
            widget.zone.music = value;
            widget.projectContext.save();
            setState(() {});
          },
          assetStore: world.musicAssetStore,
          defaultGain: world.soundOptions.defaultGain,
          looping: true,
          nullable: true,
          title: 'Zone Music',
        ),
        ListTile(
          title: const Text('Default Terrain'),
          subtitle: Text(
            widget.projectContext.world
                .getTerrain(widget.zone.defaultTerrainId)
                .name,
          ),
          onTap: () => pushWidget(
            context: context,
            builder: (context) => SelectTerrain(
              onDone: (value) {
                Navigator.pop(context);
                widget.zone.defaultTerrainId = value.id;
                widget.projectContext.save();
                setState(() {});
              },
              currentTerrainId: widget.zone.defaultTerrainId,
              title: 'Default Terrain',
              terrains: widget.projectContext.world.terrains,
            ),
          ),
        ),
        CheckboxListTile(
          value: widget.zone.topDownMap,
          onChanged: (value) {
            widget.zone.topDownMap = !widget.zone.topDownMap;
            widget.projectContext.save();
            setState(() {});
          },
          title: const Text('Top-down Map Visible'),
        ),
      ],
    );
  }

  /// Get the boxes list view.
  Widget get boxesListView {
    if (widget.zone.boxes.isEmpty) {
      return const CenterText(text: 'There are currently no boxes.');
    }
    return ListView.builder(
      itemBuilder: (context, index) {
        final box = widget.zone.boxes[index];
        return ListTile(
          title: Text(box.name),
          onTap: () {},
        );
      },
      itemCount: widget.zone.boxes.length,
    );
  }
}
