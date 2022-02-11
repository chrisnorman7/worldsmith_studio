import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/center_text.dart';
import '../reverb/edit_reverb_preset.dart';

/// A widget for viewing and editing reverb preferences.
class ProjectReverbs extends StatefulWidget {
  /// Create an instance.
  const ProjectReverbs({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _ProjectReverbsState createState() => _ProjectReverbsState();
}

/// State for [ProjectReverbs].
class _ProjectReverbsState extends State<ProjectReverbs> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final reverbPresets = widget.projectContext.world.reverbs;
    if (reverbPresets.isEmpty) {
      return const CenterText(text: 'There are no reverb presets.');
    }
    return ListView.builder(
      itemBuilder: (context, index) {
        final reverbReference = widget.projectContext.world.reverbs[index];
        return ListTile(
          title: Text(reverbReference.reverbPreset.name),
          onTap: () => pushWidget(
            context: context,
            builder: (context) => EditReverbPreset(
                projectContext: widget.projectContext,
                reverbPresetReference: reverbReference),
          ),
        );
      },
      itemCount: widget.projectContext.world.reverbs.length,
    );
  }
}
