import 'package:flutter/material.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../custom_message.dart';
import '../../project_context.dart';
import '../cancel.dart';
import '../sound/gain_list_tile.dart';
import '../sound/sound_list_tile.dart';
import '../text_list_tile.dart';

/// A widget for editing a [customMessage].
class EditCustomMessage extends StatefulWidget {
  /// Create an instance.
  const EditCustomMessage({
    required this.projectContext,
    required this.customMessage,
    required this.assetStore,
    required this.onChanged,
    this.validator,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The custom message to work on.
  final CustomMessage customMessage;

  /// The asset store to get sounds from.
  final AssetStore assetStore;

  /// The function to call when [customMessage] changes.
  final ValueChanged<CustomMessage> onChanged;

  /// The validator to use for the text.
  final FormFieldValidator<String>? validator;

  /// Create state for this widget.
  @override
  EditCustomMessageState createState() => EditCustomMessageState();
}

/// State for [EditCustomMessage].
class EditCustomMessageState extends State<EditCustomMessage> {
  late CustomMessage _customMessage;

  /// Initialise the custom message.
  @override
  void initState() {
    super.initState();
    _customMessage = widget.customMessage;
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final message = _customMessage;
    final text = message.text;
    final sound = message.sound;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Message'),
        ),
        body: ListView(
          children: [
            TextListTile(
              value: text ?? '',
              onChanged: (final value) {
                _customMessage = CustomMessage(
                  sound: sound,
                  text: value.isEmpty ? null : value,
                );
                widget.onChanged(_customMessage);
                setState(() {});
              },
              header: 'Text',
              autofocus: true,
              validator: widget.validator,
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: sound,
              onDone: (final value) {
                _customMessage = CustomMessage(
                  sound: value,
                  text: text,
                );
                widget.onChanged(_customMessage);
                setState(() {});
              },
              assetStore: widget.assetStore,
              defaultGain: widget.projectContext.world.soundOptions.defaultGain,
              nullable: true,
            ),
            if (sound != null)
              GainListTile(
                gain: sound.gain,
                onChange: (final value) {
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
}
