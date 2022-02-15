import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/play_sound_semantics.dart';
import '../menu/edit_main_menu.dart';

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
    return ListView(
      children: [
        getPlaySoundSemantics(
          child: ListTile(
            autofocus: true,
            title: Text(world.mainMenuOptions.title),
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
        getPlaySoundSemantics(
          child: ListTile(
            title: Text(world.creditsMenuOptions.title),
            onTap: () {
              widget.projectContext.playActivateSound();
            },
          ),
        ),
        getPlaySoundSemantics(
          child: ListTile(
            title: Text(world.pauseMenuOptions.title),
            onTap: () {
              widget.projectContext.playActivateSound();
            },
          ),
        )
      ],
    );
  }

  /// Get a play sound semantics widget.
  PlaySoundSemantics getPlaySoundSemantics({required Widget child}) {
    final world = widget.projectContext.world;
    return PlaySoundSemantics(
      child: child,
      soundChannel: widget.projectContext.game.interfaceSounds,
      assetReference: widget.projectContext.menuMoveSound,
      gain:
          world.pauseMenuOptions.music?.gain ?? world.soundOptions.defaultGain,
    );
  }
}
