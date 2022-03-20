import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/center_text.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/searchable_list_view.dart';
import '../zone/edit_zone.dart';

/// A widget for displaying and editing [Zone] instances.
class ProjectZones extends StatefulWidget {
  /// Create an instance.
  const ProjectZones({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  ProjectZonesState createState() => ProjectZonesState();
}

/// State for [ProjectZones].
class ProjectZonesState extends State<ProjectZones> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final zones = world.zones;
    if (zones.isEmpty) {
      return const CenterText(text: 'There are no zones yet.');
    }
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
              builder: (context) => ListTile(
                autofocus: i == 0,
                title: Text(zone.name),
                subtitle: Text('Boxes: ${zone.boxes.length}'),
                onTap: () async {
                  PlaySoundSemantics.of(context)?.stop();
                  await pushWidget(
                    context: context,
                    builder: (context) => EditZone(
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
    return SearchableListView(children: children);
  }
}
