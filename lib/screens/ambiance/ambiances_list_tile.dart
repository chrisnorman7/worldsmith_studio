import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/sound.dart';

import '../../project_context.dart';
import '../../util.dart';
import 'edit_ambiances.dart';

/// A list tile that plays a list of [ambiances].
class AmbiancesListTile extends StatefulWidget {
  /// Create an instance.
  const AmbiancesListTile({
    required this.projectContext,
    required this.ambiances,
    required this.title,
    this.subtitle,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The ambiances to use.
  final List<Sound> ambiances;

  /// The title of the [ListTile].
  final String title;

  /// The subtitle for the [ListTile].
  ///
  /// If this value is `null`, then the length of the [ambiances] list will be
  /// used.
  final String? subtitle;

  /// Create state for this widget.
  @override
  _AmbiancesListTileState createState() => _AmbiancesListTileState();
}

/// State for [AmbiancesListTile].
class _AmbiancesListTileState extends State<AmbiancesListTile> {
  late final List<PlaySound> ambiances;

  /// Initialise [ambiances].
  @override
  void initState() {
    super.initState();
    ambiances = [];
  }

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    return Semantics(
      child: ListTile(
        title: Text(widget.title),
        subtitle: Text(widget.subtitle ?? widget.ambiances.length.toString()),
        onTap: () async {
          await pushWidget(
            context: context,
            builder: (context) => EditAmbiances(
              projectContext: widget.projectContext,
              ambiances: widget.ambiances,
              title: widget.title,
            ),
          );
          setState(() {});
        },
      ),
      onDidGainAccessibilityFocus: () {
        stopAmbiances();
        for (final sound in widget.ambiances) {
          final ambiance = getAmbiance(
            assets: world.ambianceAssets,
            sound: sound,
          )!;
          ambiances.add(
            widget.projectContext.game.ambianceSounds.playSound(
              ambiance.sound,
              gain: ambiance.gain,
              keepAlive: true,
              looping: true,
            ),
          );
        }
      },
      onDidLoseAccessibilityFocus: stopAmbiances,
    );
  }

  /// Stop all [ambiances].
  void stopAmbiances() {
    while (ambiances.isNotEmpty) {
      ambiances.removeLast().destroy();
    }
  }

  /// Dispose of all [ambiances].
  @override
  void dispose() {
    super.dispose();
    stopAmbiances();
  }
}
