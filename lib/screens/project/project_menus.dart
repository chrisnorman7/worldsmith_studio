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
    final defaultGain = world.soundOptions.defaultGain;
    final moveSound = world.menuMoveSound;
    final sound = moveSound == null
        ? null
        : widget.projectContext.getRelativeAssetReference(moveSound);
    final channel = widget.projectContext.game.interfaceSounds;
    return ListView(
      children: [
        PlaySoundSemantics(
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
          soundChannel: channel,
          assetReference: sound,
          gain: world.soundOptions.menuMoveSound?.gain ?? defaultGain,
        ),
        PlaySoundSemantics(
          child: ListTile(
            title: Text(world.creditsMenuOptions.title),
            onTap: () {
              widget.projectContext.playActivateSound();
            },
          ),
          soundChannel: channel,
          assetReference: sound,
          gain: world.creditsMenuOptions.music?.gain ?? defaultGain,
        ),
        PlaySoundSemantics(
          child: ListTile(
            title: Text(world.pauseMenuOptions.title),
            onTap: () {
              widget.projectContext.playActivateSound();
            },
          ),
          soundChannel: channel,
          assetReference: sound,
          gain: world.pauseMenuOptions.music?.gain ?? defaultGain,
        )
      ],
    );
  }
}
