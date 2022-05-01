// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/sound/gain_list_tile.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing the given [audioBus].
class EditAudioBus extends StatefulWidget {
  /// Create an instance.
  const EditAudioBus({
    required this.projectContext,
    required this.audioBus,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The audio bus to edit.
  final AudioBus audioBus;

  /// Create state for this widget.
  @override
  EditAudioBusState createState() => EditAudioBusState();
}

/// State for [EditAudioBus].
class EditAudioBusState extends State<EditAudioBus> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Audio Bus'),
        ),
        body: ListView(
          children: [
            TextListTile(
              value: widget.audioBus.name,
              onChanged: (final value) {
                widget.audioBus.name = value;
                save();
              },
              header: 'Name',
              autofocus: true,
              validator: (final value) => validateNonEmptyValue(value: value),
            ),
            GainListTile(
              gain: widget.audioBus.gain ?? world.soundOptions.defaultGain,
              onChange: (final value) {
                widget.audioBus.gain = value;
                save();
              },
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.audioBus.gain = null;
                    save();
                  },
                  child: const Icon(
                    Icons.clear,
                    semanticLabel: 'Clear Gain',
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
