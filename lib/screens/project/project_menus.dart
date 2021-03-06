import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../menu/edit_controls_menu.dart';
import '../menu/edit_credits_menu.dart';
import '../menu/edit_main_menu.dart';
import '../menu/edit_pause_menu.dart';
import '../menu/edit_quest_menu.dart';
import '../menu/edit_sound_menu.dart';

/// A widget for editing various game menus.
class ProjectMenus extends StatefulWidget {
  /// Create an instance.
  const ProjectMenus({
    required this.projectContext,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  ProjectMenusState createState() => ProjectMenusState();
}

/// State for [ProjectMenus].
class ProjectMenusState extends State<ProjectMenus> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final options = world.mainMenuOptions;
    return ListView(
      children: [
        widget.projectContext.getMenuMoveSemantics(
          child: ListTile(
            autofocus: true,
            title: Text(options.title),
            onTap: () async {
              widget.projectContext.playActivateSound();
              await pushWidget(
                context: context,
                builder: (final context) => EditMainMenu(
                  projectContext: widget.projectContext,
                ),
              );
              setState(() {});
            },
          ),
        ),
        widget.projectContext.getMenuMoveSemantics(
          child: ListTile(
            title: Text(
              options.creditsString ?? world.creditsMenuOptions.title,
            ),
            onTap: () async {
              widget.projectContext.playActivateSound();
              await pushWidget(
                context: context,
                builder: (final context) => EditCreditsMenu(
                  projectContext: widget.projectContext,
                ),
              );
              setState(() {});
            },
          ),
          sound: options.creditsSound,
        ),
        widget.projectContext.getMenuMoveSemantics(
          child: ListTile(
            title: Text(
              options.controlsMenuString ?? 'Show Game Controls',
            ),
            onTap: () async {
              widget.projectContext.playActivateSound();
              await pushWidget(
                context: context,
                builder: (final context) => EditControlsMenu(
                  projectContext: widget.projectContext,
                ),
              );
              setState(() {});
            },
          ),
        ),
        widget.projectContext.getMenuMoveSemantics(
          child: ListTile(
            title: Text(
              options.soundOptionsString ?? world.soundMenuOptions.title,
            ),
            onTap: () async {
              widget.projectContext.playActivateSound();
              await pushWidget(
                context: context,
                builder: (final context) => EditSoundMenu(
                  projectContext: widget.projectContext,
                ),
              );
              setState(() {});
            },
          ),
          sound: options.soundOptionsSound,
        ),
        widget.projectContext.getMenuMoveSemantics(
          child: ListTile(
            title: Text(world.pauseMenuOptions.title),
            onTap: () async {
              widget.projectContext.playActivateSound();
              await pushWidget(
                context: context,
                builder: (final context) => EditPauseMenu(
                  projectContext: widget.projectContext,
                ),
              );
              setState(() {});
            },
          ),
        ),
        widget.projectContext.getMenuMoveSemantics(
          child: ListTile(
            title: Text(world.questMenuOptions.title),
            onTap: () async {
              await pushWidget(
                context: context,
                builder: (final context) => EditQuestMenu(
                  projectContext: widget.projectContext,
                ),
              );
              setState(() {});
            },
          ),
        )
      ],
    );
  }
}
