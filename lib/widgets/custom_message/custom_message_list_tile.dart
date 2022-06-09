import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:ziggurat/ziggurat.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../custom_message.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../play_sound_semantics.dart';
import 'edit_custom_message.dart';

/// A widget for showing and editing a [customMessage].
class CustomMessageListTile extends StatefulWidget {
  /// Create an instance.
  const CustomMessageListTile({
    required this.projectContext,
    required this.customMessage,
    required this.assetStore,
    required this.onChanged,
    required this.title,
    this.assetReference,
    this.autofocus = false,
    this.validator,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The message to use.
  final CustomMessage customMessage;

  /// The asset store to choose sounds from.
  final AssetStore assetStore;

  /// The function to call when [customMessage] changes.
  final ValueChanged<CustomMessage> onChanged;

  /// The title of the resulting [ListTile].
  final String title;

  /// The sound to use when the [customMessage] doesn't have one.
  final AssetReference? assetReference;

  /// The autofocus value.
  final bool autofocus;

  /// The validator to use when editing text.
  final FormFieldValidator<String>? validator;

  /// Create state for this widget.
  @override
  CustomMessageListTileState createState() => CustomMessageListTileState();
}

/// State for [CustomMessageListTile].
class CustomMessageListTileState extends State<CustomMessageListTile> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final text = widget.customMessage.text;
    final sound = widget.customMessage.sound;
    return PlaySoundSemantics(
      soundChannel: widget.projectContext.game.interfaceSounds,
      assetReference: sound == null
          ? widget.assetReference
          : getAssetReferenceReference(
              assets: widget.assetStore.assets,
              id: sound.id,
            ).reference,
      child: Builder(
        builder: (final context) => ListTile(
          autofocus: widget.autofocus,
          title: Text(widget.title),
          subtitle: Text('$text'),
          onTap: () async {
            PlaySoundSemantics.of(context)?.stop();
            await pushWidget(
              context: context,
              builder: (final context) => EditCustomMessage(
                projectContext: widget.projectContext,
                customMessage: widget.customMessage,
                assetStore: widget.assetStore,
                onChanged: widget.onChanged,
                validator: widget.validator,
              ),
            );
            widget.projectContext.save();
            setState(() {});
          },
        ),
      ),
    );
  }
}
