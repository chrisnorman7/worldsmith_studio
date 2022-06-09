import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/sound.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/searchable_list_view.dart';
import 'edit_reverb_preset.dart';

/// A widget for viewing and editing reverb preferences.
class EditReverbs extends StatefulWidget {
  /// Create an instance.
  const EditReverbs({
    required this.projectContext,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  EditReverbsState createState() => EditReverbsState();
}

/// State for [EditReverbs].
class EditReverbsState extends State<EditReverbs> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final reverbPresets = widget.projectContext.world.reverbs;
    final Widget child;
    if (reverbPresets.isEmpty) {
      child = const CenterText(text: 'There are no reverb presets.');
    } else {
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
                  builder: (final context) => EditReverbPreset(
                    projectContext: widget.projectContext,
                    reverbPresetReference: reverbReference,
                  ),
                );
                setState(() {});
              },
            ),
          ),
        );
      }
      child = SearchableListView(children: children);
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reverb Presets'),
        ),
        body: child,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            const reverbPreset = ReverbPreset(name: 'Untitled Reverb');
            final reverbPresetReference = ReverbPresetReference(
              id: newId(),
              reverbPreset: reverbPreset,
            );
            world.reverbs.add(reverbPresetReference);
            widget.projectContext.save();
            await pushWidget(
              context: context,
              builder: (final context) => EditReverbPreset(
                projectContext: widget.projectContext,
                reverbPresetReference: reverbPresetReference,
              ),
            );
            setState(() {});
          },
          autofocus: world.reverbs.isEmpty,
          tooltip: 'Add Reverb',
          child: createIcon,
        ),
      ),
    );
  }
}
