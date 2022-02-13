import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/sound.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/tabbed_scaffold.dart';
import 'project_asset_stores.dart';
import 'project_reverbs.dart';
import 'project_settings_widget.dart';
import 'project_sound_settings.dart';
import 'project_terrains.dart';
import 'project_zones.dart';

/// A widget for editing its [projectContext].
class ProjectContextWidget extends StatefulWidget {
  /// Create an instance.
  const ProjectContextWidget({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _ProjectContextWidgetState createState() => _ProjectContextWidgetState();
}

/// State for [ProjectContextWidget].
class _ProjectContextWidgetState extends State<ProjectContextWidget> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final closeProjectAction = CallbackAction<CloseProjectIntent>(
      onInvoke: (intent) => Navigator.pop(context),
    );
    return Shortcuts(
      child: Actions(
        actions: {CloseProjectIntent: closeProjectAction},
        child: getTabbedScaffold(world),
      ),
      shortcuts: const {CloseProjectIntent.hotkey: CloseProjectIntent()},
    );
  }

  /// Get the tabbed scaffold.
  TabbedScaffold getTabbedScaffold(World world) => TabbedScaffold(
        tabs: [
          TabbedScaffoldTab(
            title: 'World Options',
            icon: const Icon(Icons.map_outlined),
            child: ProjectSettingsWidget(projectContext: widget.projectContext),
          ),
          TabbedScaffoldTab(
            title: 'Zones',
            icon: const Icon(Icons.map_outlined),
            child: ProjectZones(projectContext: widget.projectContext),
            floatingActionButton: world.terrains.isEmpty
                ? null
                : FloatingActionButton(
                    onPressed: () {
                      final zone = Zone(
                        id: newId(),
                        name: 'Untitled Zone',
                        boxes: [],
                        defaultTerrainId: world.terrains.first.id,
                      );
                      world.zones.add(zone);
                      widget.projectContext.save();
                      setState(() {});
                    },
                    autofocus: world.zones.isEmpty,
                    child: createIcon,
                    tooltip: 'Add Zone',
                  ),
          ),
          TabbedScaffoldTab(
            title: 'Terrain Types',
            icon: const Icon(Icons.carpenter_outlined),
            child: ProjectTerrains(
              projectContext: widget.projectContext,
            ),
            floatingActionButton: world.terrainAssets.isEmpty
                ? null
                : FloatingActionButton(
                    onPressed: () {
                      final sound = world.terrainAssets.first;
                      final terrain = Terrain(
                        id: newId(),
                        name: sound.comment ?? sound.reference.name,
                        slowWalk: WalkingOptions(
                          interval: 1000,
                          distance: 0.1,
                          sound: Sound(
                            id: sound.variableName,
                            gain: world.soundOptions.defaultGain,
                          ),
                          joystickValue: 0.1,
                        ),
                        fastWalk: WalkingOptions(
                          interval: 500,
                          distance: 0.1,
                          sound: Sound(
                              id: sound.variableName,
                              gain: world.soundOptions.defaultGain),
                          joystickValue: 0.5,
                        ),
                      );
                      world.terrains.add(terrain);
                      widget.projectContext.save();
                      setState(() {});
                    },
                    autofocus: world.terrains.isEmpty,
                    child: createIcon,
                    tooltip: 'Add Terrain',
                  ),
          ),
          TabbedScaffoldTab(
            title: 'Asset Stores',
            icon: const Icon(Icons.store_mall_directory_outlined),
            child: ProjectAssetStores(
              projectContext: widget.projectContext,
            ),
          ),
          TabbedScaffoldTab(
            title: 'Reverb Presets',
            icon: const Icon(Icons.room_outlined),
            child: ProjectReverbs(projectContext: widget.projectContext),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                const reverbPreset = ReverbPreset(name: 'Untitled Reverb');
                world.reverbs.add(
                  ReverbPresetReference(
                    id: newId(),
                    reverbPreset: reverbPreset,
                  ),
                );
                widget.projectContext.save();
                setState(() {});
              },
              autofocus: world.reverbs.isEmpty,
              child: createIcon,
              tooltip: 'Add Reverb',
            ),
          ),
          TabbedScaffoldTab(
            title: 'Sound Settings',
            icon: const Icon(Icons.speaker_outlined),
            child: ProjectSoundSettings(
              projectContext: widget.projectContext,
            ),
          )
        ],
      );
}
