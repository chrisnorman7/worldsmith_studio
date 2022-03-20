import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../screens/reverb/edit_reverb_preset.dart';
import '../../screens/reverb/select_reverb.dart';
import '../../util.dart';

/// A list tile for changing a reverb preset.
class ReverbListTile extends StatefulWidget {
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
  State<ReverbListTile> createState() => _ReverbListTileState();
}

class _ReverbListTileState extends State<ReverbListTile> {
  @override
  Widget build(BuildContext context) {
    ReverbPresetReference? currentReverbPreset;
    if (widget.currentReverbId != null) {
      currentReverbPreset = widget.reverbPresets.firstWhere(
        (element) => element.id == widget.currentReverbId,
      );
    }
    return CallbackShortcuts(
      bindings: {
        EditIntent.hotkey: () async {
          final preset = currentReverbPreset;
          if (preset != null) {
            await pushWidget(
              context: context,
              builder: (context) => EditReverbPreset(
                projectContext: widget.projectContext,
                reverbPresetReference: preset,
              ),
            );
            setState(() {});
          }
        }
      },
      child: ListTile(
        title: Text(widget.title),
        subtitle: Text(
          currentReverbPreset == null
              ? 'Not Set'
              : currentReverbPreset.reverbPreset.name,
        ),
        onTap: () => pushWidget(
          context: context,
          builder: (context) => SelectReverb(
            projectContext: widget.projectContext,
            onDone: (reverb) {
              Navigator.pop(context);
              widget.onDone(reverb);
            },
            reverbPresets: widget.reverbPresets,
            currentReverbId: widget.currentReverbId,
            nullable: widget.nullable,
          ),
        ),
      ),
    );
  }
}
