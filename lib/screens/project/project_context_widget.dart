import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/sound.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/tabbed_scaffold.dart';
import '../reverb/edit_reverb_preset.dart';
import '../terrain/edit_terrain.dart';
import '../world_command/edit_command_category.dart';
import '../zone/edit_zone.dart';
import 'project_asset_stores.dart';
import 'project_command_categories.dart';
import 'project_menus.dart';
import 'project_more_menu.dart';
import 'project_reverbs.dart';
import 'project_settings.dart';
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
    return WithKeyboardShortcuts(
      child: Shortcuts(
        child: Actions(
          actions: {
            CloseProjectIntent: closeProjectAction,
          },
          child: Builder(builder: (context) => getTabbedScaffold(world)),
        ),
        shortcuts: {
          CloseProjectIntent.hotkey: const CloseProjectIntent(),
        },
      ),
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Close the project and return to the main menu.',
          keyName: 'w',
          control: true,
        )
      ],
    );
  }

  /// Get the tabbed scaffold.
  TabbedScaffold getTabbedScaffold(World world) => TabbedScaffold(
        tabs: [
          TabbedScaffoldTab(
            title: 'World Options',
            icon: const Icon(Icons.settings_outlined),
            builder: (context) => ProjectSettings(
              projectContext: widget.projectContext,
            ),
          ),
          TabbedScaffoldTab(
            title: 'Commands',
            icon: const Icon(Icons.category_outlined),
            builder: (context) => ProjectCommandCategories(
              projectContext: widget.projectContext,
            ),
            floatingActionButton: FloatingActionButton(
              autofocus: world.commandCategories.isEmpty,
              onPressed: () async {
                final category = CommandCategory(
                  id: newId(),
                  name: 'Untitled Command Category',
                  commands: [],
                );
                world.commandCategories.add(category);
                widget.projectContext.save();
                await pushWidget(
                  context: context,
                  builder: (context) => EditCommandCategory(
                    projectContext: widget.projectContext,
                    category: category,
                  ),
                );
                setState(() {});
              },
              child: createIcon,
              tooltip: 'Add Command Category',
            ),
          ),
          TabbedScaffoldTab(
            title: 'Zones',
            icon: const Icon(Icons.map_outlined),
            builder: (context) => ProjectZones(
              projectContext: widget.projectContext,
            ),
            floatingActionButton: world.terrains.isEmpty
                ? null
                : FloatingActionButton(
                    onPressed: () async {
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
                        builder: (context) => EditZone(
                          projectContext: widget.projectContext,
                          zone: zone,
                        ),
                      );
                      setState(() {});
                    },
                    autofocus: world.zones.isEmpty,
                    child: createIcon,
                    tooltip: 'Add Zone',
                  ),
          ),
          TabbedScaffoldTab(
            title: 'Terrain Types',
            icon: const Icon(Icons.add_location_outlined),
            builder: (context) => ProjectTerrains(
              projectContext: widget.projectContext,
            ),
            floatingActionButton: world.terrainAssets.isEmpty
                ? null
                : FloatingActionButton(
                    onPressed: () async {
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
                      await pushWidget(
                        context: context,
                        builder: (context) => EditTerrain(
                          projectContext: widget.projectContext,
                          terrain: terrain,
                        ),
                      );
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
            builder: (context) => ProjectAssetStores(
              projectContext: widget.projectContext,
            ),
          ),
          TabbedScaffoldTab(
            title: 'Reverb Presets',
            icon: const Icon(Icons.crop_outlined),
            builder: (context) => ProjectReverbs(
              projectContext: widget.projectContext,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                const reverbPreset = ReverbPreset(name: 'Untitled Reverb');
                final reverbPresetReference = ReverbPresetReference(
                  id: newId(),
                  reverbPreset: reverbPreset,
                );
                world.reverbs.add(reverbPresetReference);
                widget.projectContext.save();
                await pushWidget(
                  context: context,
                  builder: (context) => EditReverbPreset(
                    projectContext: widget.projectContext,
                    reverbPresetReference: reverbPresetReference,
                  ),
                );
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
            builder: (context) => ProjectSoundSettings(
              projectContext: widget.projectContext,
            ),
          ),
          TabbedScaffoldTab(
            title: 'Menus',
            icon: const Icon(Icons.menu_book_outlined),
            builder: (context) =>
                ProjectMenus(projectContext: widget.projectContext),
          ),
          TabbedScaffoldTab(
            title: 'More',
            icon: const Icon(Icons.more_outlined),
            builder: (context) => ProjectMoreMenu(
              projectContext: widget.projectContext,
            ),
          )
        ],
      );
}
