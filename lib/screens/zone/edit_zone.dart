import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/get_text.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/tabbed_scaffold.dart';
import '../sound/edit_sound.dart';
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
    final assetReference = getAssetReferenceReference(
      assets: world.musicAssets,
      id: music?.id,
    );
    return ListView(
      children: [
        ListTile(
          autofocus: true,
          title: const Text('Name'),
          subtitle: Text(widget.zone.name),
          onTap: () => pushWidget(
            context: context,
            builder: (context) => GetText(
              onDone: (value) {
                Navigator.pop(context);
                widget.zone.name = value;
                widget.projectContext.save();
                setState(() {});
              },
              labelText: 'Name',
              text: widget.zone.name,
              title: 'Rename Zone',
              validator: (value) => validateNonEmptyValue(value: value),
            ),
          ),
        ),
        PlaySoundSemantics(
          child: Builder(
            builder: (context) => ListTile(
              title: const Text('Music'),
              subtitle: Text(
                assetReference == null
                    ? 'Not Set'
                    : assetString(assetReference),
              ),
              onTap: () async {
                if (world.musicAssets.isEmpty) {
                  return showSnackBar(
                    context: context,
                    message: 'There are no music assets to use.',
                  );
                }
                PlaySoundSemantics.of(context)!.stop();
                final Sound sound;
                if (music == null) {
                  sound = Sound(
                    id: world.musicAssets.first.variableName,
                    gain: world.soundOptions.defaultGain,
                  );
                  widget.zone.music = sound;
                  widget.projectContext.save();
                } else {
                  sound = music;
                }
                await pushWidget(
                  context: context,
                  builder: (context) => EditSound(
                    projectContext: widget.projectContext,
                    assetStore: world.musicAssetStore,
                    sound: sound,
                    title: 'Zone Music',
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.zone.music = null;
                          widget.projectContext.save();
                          setState(() {});
                        },
                        child: deleteIcon,
                      )
                    ],
                  ),
                );
                setState(() {});
              },
            ),
          ),
          soundChannel: widget.projectContext.game.interfaceSounds,
          assetReference: assetReference == null
              ? null
              : widget.projectContext.getRelativeAssetReference(
                  assetReference.reference,
                ),
          gain: music?.gain ?? world.soundOptions.defaultGain,
          looping: true,
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
