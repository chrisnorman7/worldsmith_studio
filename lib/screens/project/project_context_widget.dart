import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/run_game.dart';
import '../../widgets/tabbed_scaffold.dart';
import '../conversation/edit_conversation_category.dart';
import '../conversation/project_conversation_categories.dart';
import '../terrain/edit_terrain.dart';
import '../world_command/edit_command_category.dart';
import '../zone/edit_zone.dart';
import 'project_asset_stores.dart';
import 'project_command_categories.dart';
import 'project_menus.dart';
import 'project_more_menu.dart';
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
    final runProjectAction = CallbackAction<RunIntent>(
      onInvoke: (intent) => run(),
    );
    return WithKeyboardShortcuts(
      child: Shortcuts(
        child: Actions(
          actions: {
            CloseProjectIntent: closeProjectAction,
            RunIntent: runProjectAction,
          },
          child: Builder(builder: (context) => getTabbedScaffold(world)),
        ),
        shortcuts: {
          CloseProjectIntent.hotkey: const CloseProjectIntent(),
          RunIntent.hotkey: const RunIntent()
        },
      ),
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Close the project and return to the main menu.',
          keyName: 'w',
          control: true,
        ),
        KeyboardShortcut(
          description: 'Run the game.',
          keyName: 'R',
          control: true,
        )
      ],
    );
  }

  /// Get the tabbed scaffold.
  TabbedScaffold getTabbedScaffold(World world) {
    final projectContext = widget.projectContext;
    return TabbedScaffold(
      tabs: [
        TabbedScaffoldTab(
          title: 'World Options',
          icon: const Icon(Icons.settings_outlined),
          builder: (context) => ProjectSettings(
            projectContext: projectContext,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: run,
            child: const Icon(Icons.run_circle_outlined),
            tooltip: 'Run Project',
          ),
        ),
        TabbedScaffoldTab(
          title: 'Commands',
          icon: const Icon(Icons.category_outlined),
          builder: (context) => ProjectCommandCategories(
            projectContext: projectContext,
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
              projectContext.save();
              await pushWidget(
                context: context,
                builder: (context) => EditCommandCategory(
                  projectContext: projectContext,
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
          title: 'Conversations',
          icon: const Icon(Icons.message_outlined),
          builder: (context) => ProjectConversationCategories(
            projectContext: projectContext,
          ),
          floatingActionButton: FloatingActionButton(
            autofocus: world.conversationCategories.isEmpty,
            child: createIcon,
            onPressed: () async {
              final category = ConversationCategory(
                id: newId(),
                name: 'Untitled Category',
                conversations: [],
              );
              world.conversationCategories.add(category);
              projectContext.save();
              await pushWidget(
                context: context,
                builder: (context) => EditConversationCategory(
                  projectContext: projectContext,
                  conversationCategory: category,
                ),
              );
              setState(() {});
            },
            tooltip: 'Add Conversation Category',
          ),
        ),
        TabbedScaffoldTab(
          title: 'Zones',
          icon: const Icon(Icons.map_outlined),
          builder: (context) => ProjectZones(
            projectContext: projectContext,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (world.terrains.isEmpty) {
                return showError(
                  context: context,
                  message:
                      'You must add at least 1 terrain before you can add a'
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
              projectContext.save();
              await pushWidget(
                context: context,
                builder: (context) => EditZone(
                  projectContext: projectContext,
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
            projectContext: projectContext,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final terrain = Terrain(
                id: newId(),
                name: 'Untitled Terrain',
                slowWalk: WalkingOptions(
                  interval: 1000,
                  joystickValue: 0.1,
                ),
                fastWalk: WalkingOptions(
                  interval: 500,
                  joystickValue: 0.5,
                ),
              );
              world.terrains.add(terrain);
              projectContext.save();
              await pushWidget(
                context: context,
                builder: (context) => EditTerrain(
                  projectContext: projectContext,
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
            projectContext: projectContext,
          ),
        ),
        TabbedScaffoldTab(
          title: 'Sound Settings',
          icon: const Icon(Icons.speaker_outlined),
          builder: (context) => ProjectSoundSettings(
            projectContext: projectContext,
          ),
        ),
        TabbedScaffoldTab(
          title: 'Menus',
          icon: const Icon(Icons.menu_book_outlined),
          builder: (context) => ProjectMenus(
            projectContext: projectContext,
          ),
        ),
        TabbedScaffoldTab(
          title: 'More',
          icon: const Icon(Icons.more_outlined),
          builder: (context) => ProjectMoreMenu(
            projectContext: projectContext,
          ),
        )
      ],
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Run the project.
  Future<void> run() async {
    await pushWidget(
      context: context,
      builder: (context) => RunGame(
        projectContext: widget.projectContext,
      ),
    );
  }
}
