import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import 'select_reverb.dart';

/// A list tile for changing a reverb preset.
class ReverbListTile extends StatelessWidget {
  /// Create an instance.
  const ReverbListTile({
    required this.projectContext,
    required this.onDone,
    required this.reverbPresets,
    this.currentReverbId,
    this.nullable = false,
    this.title = 'Reverb Preset',
    Key? key,
  }) : super(key: key);

  /// The project context to send to [SelectReverb].
  final ProjectContext projectContext;

  /// Create an instance.
  /// The function to be called with the new value.
  final ValueChanged<ReverbPresetReference?> onDone;

  /// The list of reverb presets.
  final List<ReverbPresetReference> reverbPresets;

  /// The ID of the current reverb preset.
  final String? currentReverbId;

  /// Whether or not the new reverb can be `null`.
  final bool nullable;

  /// The title of the resulting [ListTile].
  final String title;
  @override
  Widget build(BuildContext context) {
    ReverbPresetReference? currentReverbPreset;
    if (currentReverbId != null) {
      currentReverbPreset = reverbPresets.firstWhere(
        (element) => element.id == currentReverbId,
      );
    }
    return ListTile(
      title: Text(title),
      subtitle: Text(
        currentReverbPreset == null
            ? 'Not Set'
            : currentReverbPreset.reverbPreset.name,
      ),
      onTap: () => pushWidget(
        context: context,
        builder: (context) => SelectReverb(
          projectContext: projectContext,
          onDone: (reverb) {
            Navigator.pop(context);
            onDone(reverb);
          },
          reverbPresets: reverbPresets,
          currentReverbId: currentReverbId,
          nullable: nullable,
        ),
      ),
    );
  }
}
