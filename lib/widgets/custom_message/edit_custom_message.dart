import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../screens/asset_store/select_asset.dart';
import '../../screens/asset_store/select_asset_store.dart';
import '../../screens/sound/gain_list_tile.dart';
import '../../util.dart';
import '../cancel.dart';
import '../play_sound_semantics.dart';
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
    final assetStore = sound == null
        ? null
        : widget.projectContext.worldContext.getAssetStore(sound.assetStore);
    final reference = sound == null
        ? null
        : getAssetReferenceReference(assets: assetStore!.assets, id: sound.id);
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
            PlaySoundSemantics(
              child: ListTile(
                title: const Text('Asset'),
                subtitle: Text(
                  sound == null
                      ? 'Not Set'
                      : '${assetStore!.comment}/${reference!.comment}',
                ),
                onTap: () => pushWidget(
                  context: context,
                  builder: (context) => SelectAssetStore(
                    projectContext: widget.projectContext,
                    onDone: (customSoundAssetStore) {
                      if (customSoundAssetStore == null) {
                        widget.customMessage.sound = null;
                        Navigator.pop(context);
                        save();
                      } else {
                        pushWidget(
                          context: context,
                          builder: (context) => SelectAsset(
                            projectContext: widget.projectContext,
                            assetStore: widget.projectContext.worldContext
                                .getAssetStore(customSoundAssetStore),
                            onDone: (newAssetReference) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              if (newAssetReference == null) {
                                widget.customMessage.sound = null;
                              } else {
                                final sound = widget.customMessage.sound;
                                if (sound == null) {
                                  widget.customMessage.sound = CustomSound(
                                    assetStore: customSoundAssetStore,
                                    id: newAssetReference.variableName,
                                  );
                                } else {
                                  sound
                                    ..assetStore = customSoundAssetStore
                                    ..id = newAssetReference.variableName;
                                }
                              }
                              save();
                            },
                            currentId: sound?.id,
                            nullable: true,
                          ),
                        );
                      }
                    },
                    currentAssetStore: sound?.assetStore,
                  ),
                ),
              ),
              soundChannel: widget.projectContext.game.interfaceSounds,
              assetReference: reference?.reference,
              gain: sound?.gain ??
                  widget.projectContext.world.soundOptions.defaultGain,
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
