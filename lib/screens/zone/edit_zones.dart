import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/searchable_list_view.dart';
import 'edit_zone.dart';

/// A widget for displaying and editing [Zone] instances.
class EditZones extends StatefulWidget {
  /// Create an instance.
  const EditZones({
    required this.projectContext,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  EditZonesState createState() => EditZonesState();
}

/// State for [EditZones].
class EditZonesState extends State<EditZones> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final zones = world.zones;
    final Widget child;
    if (zones.isEmpty) {
      child = const CenterText(text: 'There are no zones yet.');
    } else {
      final children = <SearchableListTile>[];
      for (var i = 0; i < zones.length; i++) {
        final zone = zones[i];
        final music = zone.music;
        children.add(
          SearchableListTile(
            searchString: zone.name,
            child: PlaySoundSemantics(
              soundChannel: widget.projectContext.game.interfaceSounds,
              assetReference: music == null
                  ? null
                  : getAssetReferenceReference(
                      assets: world.musicAssets,
                      id: music.id,
                    ).reference,
              gain: music?.gain ?? world.soundOptions.defaultGain,
              looping: true,
              child: Builder(
                builder: (final context) => ListTile(
                  autofocus: i == 0,
                  title: Text(zone.name),
                  subtitle: Text('Boxes: ${zone.boxes.length}'),
                  onTap: () async {
                    PlaySoundSemantics.of(context)?.stop();
                    await pushWidget(
                      context: context,
                      builder: (final context) => EditZone(
                        projectContext: widget.projectContext,
                        zone: zone,
                      ),
                    );
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
        );
      }
      child = SearchableListView(children: children);
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Zones'),
        ),
        body: child,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (world.terrains.isEmpty) {
              return showError(
                context: context,
                message: 'You must add at least 1 terrain before you can add a'
                    ' zone.',
              );
            }
            final zone = Zone(
              id: newId(),
              name: 'Untitled Zone',
              boxes: [],
              defaultTerrainId: world.terrains.first.id,
            );
            world.zones.add(zone);
            widget.projectContext.save();
            await pushWidget(
              context: context,
              builder: (final context) => EditZone(
                projectContext: widget.projectContext,
                zone: zone,
              ),
            );
            setState(() {});
          },
          autofocus: world.zones.isEmpty,
          tooltip: 'Add Zone',
          child: createIcon,
        ),
      ),
    );
  }
}
