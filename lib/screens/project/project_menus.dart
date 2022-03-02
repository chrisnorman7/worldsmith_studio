import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../menu/edit_credits_menu.dart';
import '../menu/edit_main_menu.dart';
import '../menu/edit_pause_menu.dart';

/// A widget for editing various game menus.
class ProjectMenus extends StatefulWidget {
  /// Create an instance.
  const ProjectMenus({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _ProjectMenusState createState() => _ProjectMenusState();
}

/// State for [ProjectMenus].
class _ProjectMenusState extends State<ProjectMenus> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
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
                builder: (context) => EditMainMenu(
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
              options.creditsMessage.text ?? world.creditsMenuOptions.title,
            ),
            onTap: () async {
              widget.projectContext.playActivateSound();
              await pushWidget(
                context: context,
                builder: (context) => EditCreditsMenu(
                  projectContext: widget.projectContext,
                ),
              );
              setState(() {});
            },
          ),
        ),
        widget.projectContext.getMenuMoveSemantics(
          child: ListTile(
            title: Text(world.pauseMenuOptions.title),
            onTap: () async {
              widget.projectContext.playActivateSound();
              await pushWidget(
                context: context,
                builder: (context) => EditPauseMenu(
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
              options.soundOptionsMessage.text ?? world.soundMenuOptions.title,
            ),
            onTap: () {},
          ),
        )
      ],
    );
  }
}
