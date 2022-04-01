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
import '../quest/edit_quest.dart';
import '../terrain/edit_terrain.dart';
import '../world_command/edit_command_category.dart';
import '../zone/edit_zone.dart';
import 'project_asset_stores.dart';
import 'project_command_categories.dart';
import 'project_menus.dart';
import 'project_more_menu.dart';
import 'project_quests.dart';
import 'project_settings.dart';
import 'project_sound_settings.dart';
import 'project_terrains.dart';
import 'project_zones.dart';

/// A widget for editing its [projectContext].
class ProjectContextWidget extends StatefulWidget {
  /// Create an instance.
  const ProjectContextWidget({
    required this.projectContext,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  ProjectContextWidgetState createState() => ProjectContextWidgetState();
}

/// State for [ProjectContextWidget].
class ProjectContextWidgetState extends State<ProjectContextWidget> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final closeProjectAction = CallbackAction<CloseProjectIntent>(
      onInvoke: (final intent) => Navigator.pop(context),
    );
    final runProjectAction = CallbackAction<RunIntent>(
      onInvoke: (final intent) => run(),
    );
    return WithKeyboardShortcuts(
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
      child: Shortcuts(
        shortcuts: {
          CloseProjectIntent.hotkey: const CloseProjectIntent(),
          RunIntent.hotkey: const RunIntent()
        },
        child: Actions(
          actions: {
            CloseProjectIntent: closeProjectAction,
            RunIntent: runProjectAction,
          },
          child: Builder(builder: (final context) => getTabbedScaffold(world)),
        ),
      ),
    );
  }

  /// Get the tabbed scaffold.
  TabbedScaffold getTabbedScaffold(final World world) {
    final projectContext = widget.projectContext;
    return TabbedScaffold(
      tabs: [
        TabbedScaffoldTab(
          title: 'World Options',
          icon: const Icon(Icons.settings_outlined),
          builder: (final context) => ProjectSettings(
            projectContext: projectContext,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: run,
            tooltip: 'Run Project',
            child: const Icon(Icons.run_circle_outlined),
          ),
        ),
        TabbedScaffoldTab(
          title: 'Commands',
          icon: const Icon(Icons.category_outlined),
          builder: (final context) => ProjectCommandCategories(
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
                builder: (final context) => EditCommandCategory(
                  projectContext: projectContext,
                  category: category,
                ),
              );
              setState(() {});
            },
            tooltip: 'Add Command Category',
            child: createIcon,
          ),
        ),
        TabbedScaffoldTab(
          title: 'Conversations',
          icon: const Icon(Icons.message_outlined),
          builder: (final context) => ProjectConversationCategories(
            projectContext: projectContext,
          ),
          floatingActionButton: FloatingActionButton(
            autofocus: world.conversationCategories.isEmpty,
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
                builder: (final context) => EditConversationCategory(
                  projectContext: projectContext,
                  conversationCategory: category,
                ),
              );
              setState(() {});
            },
            tooltip: 'Add Conversation Category',
            child: createIcon,
          ),
        ),
        TabbedScaffoldTab(
          title: 'Zones',
          icon: const Icon(Icons.map_outlined),
          builder: (final context) => ProjectZones(
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
                builder: (final context) => EditZone(
                  projectContext: projectContext,
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
        TabbedScaffoldTab(
          title: 'Quests',
          icon: const Icon(Icons.elderly_outlined),
          builder: (final context) => ProjectQuests(
            projectContext: projectContext,
          ),
          floatingActionButton: FloatingActionButton(
            autofocus: world.quests.isEmpty,
            onPressed: () async {
              final quest = Quest(
                id: newId(),
                name: 'Untitled Quest',
                stages: [],
              );
              world.quests.add(quest);
              projectContext.save();
              await pushWidget(
                context: context,
                builder: (final context) => EditQuest(
                  projectContext: projectContext,
                  quest: quest,
                ),
              );
              setState(() {});
            },
            tooltip: 'Add Quest',
            child: createIcon,
          ),
        ),
        TabbedScaffoldTab(
          title: 'Terrain Types',
          icon: const Icon(Icons.add_location_outlined),
          builder: (final context) => ProjectTerrains(
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
                builder: (final context) => EditTerrain(
                  projectContext: projectContext,
                  terrain: terrain,
                ),
              );
              setState(() {});
            },
            autofocus: world.terrains.isEmpty,
            tooltip: 'Add Terrain',
            child: createIcon,
          ),
        ),
        TabbedScaffoldTab(
          title: 'Asset Stores',
          icon: const Icon(Icons.store_mall_directory_outlined),
          builder: (final context) => ProjectAssetStores(
            projectContext: projectContext,
          ),
        ),
        TabbedScaffoldTab(
          title: 'Sound Settings',
          icon: const Icon(Icons.speaker_outlined),
          builder: (final context) => ProjectSoundSettings(
            projectContext: projectContext,
          ),
        ),
        TabbedScaffoldTab(
          title: 'Menus',
          icon: const Icon(Icons.menu_book_outlined),
          builder: (final context) => ProjectMenus(
            projectContext: projectContext,
          ),
        ),
        TabbedScaffoldTab(
          title: 'More',
          icon: const Icon(Icons.more_outlined),
          builder: (final context) => ProjectMoreMenu(
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
      builder: (final context) => RunGame(
        projectContext: widget.projectContext,
      ),
    );
  }
}
