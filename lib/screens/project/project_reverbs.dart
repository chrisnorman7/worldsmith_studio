import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/center_text.dart';
import '../../widgets/searchable_list_view.dart';
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
    final children = <SearchableListTile>[];
    for (var i = 0; i < reverbPresets.length; i++) {
      final reverbReference = reverbPresets[i];
      children.add(
        SearchableListTile(
          searchString: reverbReference.reverbPreset.name,
          child: ListTile(
            autofocus: i == 0,
            title: Text(reverbReference.reverbPreset.name),
            onTap: () async {
              await pushWidget(
                context: context,
                builder: (context) => EditReverbPreset(
                    projectContext: widget.projectContext,
                    reverbPresetReference: reverbReference),
              );
              setState(() {});
            },
          ),
        ),
      );
    }
    return SearchableListView(children: children);
  }
}
