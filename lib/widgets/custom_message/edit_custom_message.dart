import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../screens/sound/gain_list_tile.dart';
import '../cancel.dart';
import '../custom_sound/custom_sound_list_tile.dart';
import '../text_list_tile.dart';

/// A widget for editing a [customMessage].
class EditCustomMessage extends StatefulWidget {
  /// Create an instance.
  const EditCustomMessage({
    required this.projectContext,
    required this.customMessage,
    this.validator,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The custom message to work on.
  final CustomMessage customMessage;

  /// The validator to use for the text.
  final FormFieldValidator<String>? validator;

  /// Create state for this widget.
  @override
  _EditCustomMessageState createState() => _EditCustomMessageState();
}

/// State for [EditCustomMessage].
class _EditCustomMessageState extends State<EditCustomMessage> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final text = widget.customMessage.text;
    final sound = widget.customMessage.sound;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Message'),
        ),
        body: ListView(
          children: [
            TextListTile(
              value: text ?? '',
              onChanged: (value) {
                widget.customMessage.text = value.isEmpty ? null : value;
                save();
              },
              header: 'Text',
              autofocus: true,
              validator: widget.validator,
            ),
            CustomSoundListTile(
              projectContext: widget.projectContext,
              value: sound,
              onClear: () {
                widget.customMessage.sound = null;
                save();
              },
              onCreate: (value) {
                widget.customMessage.sound = value;
                save();
              },
            ),
            if (sound != null)
              GainListTile(
                gain: sound.gain,
                onChange: (value) {
                  sound.gain = value;
                  widget.projectContext.save();
                  setState(() {});
                },
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
