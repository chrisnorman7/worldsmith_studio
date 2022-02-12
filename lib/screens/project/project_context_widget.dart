import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/sound.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/tabbed_scaffold.dart';
import 'project_reverbs.dart';
import 'project_settings_widget.dart';
import 'project_sound_settings.dart';
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
        child: TabbedScaffold(
          tabs: [
            TabbedScaffoldTab(
              title: 'World Options',
              icon: const Icon(Icons.map_outlined),
              child:
                  ProjectSettingsWidget(projectContext: widget.projectContext),
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
                      )),
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
        ),
      ),
      shortcuts: const {CloseProjectIntent.hotkey: CloseProjectIntent()},
    );
  }
}
