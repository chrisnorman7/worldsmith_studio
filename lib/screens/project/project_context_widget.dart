import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../widgets/tabbed_scaffold.dart';
import 'project_reverbs.dart';
import 'project_settings_widget.dart';

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
  Widget build(BuildContext context) => TabbedScaffold(
        tabs: [
          TabbedScaffoldTab(
            title: 'World Options',
            icon: const Icon(Icons.map_outlined),
            child: ProjectSettingsWidget(projectContext: widget.projectContext),
          ),
          TabbedScaffoldTab(
            title: 'Reverb Presets',
            icon: const Icon(Icons.room_outlined),
            child: ProjectReverbs(projectContext: widget.projectContext),
          )
        ],
      );
}
