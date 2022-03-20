import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/sound/gain_list_tile.dart';
import '../asset_store/select_asset.dart';

/// A widget for editing a [sound].
class EditSound extends StatefulWidget {
  /// Create an instance.
  const EditSound({
    required this.projectContext,
    required this.assetStore,
    required this.sound,
    required this.onChanged,
    this.nullable = false,
    this.title = 'Edit Sound',
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The asset store to get the sound from.
  final AssetStore assetStore;

  /// The sound to work with.
  final Sound sound;

  /// The function to be called when the value changes.
  final ValueChanged<Sound?> onChanged;

  /// Whether or not the sound can be set to `null`.
  final bool nullable;

  /// The title of the resulting scaffold.
  final String title;

  /// Create state for this widget.
  @override
  EditSoundState createState() => EditSoundState();
}

/// State for [EditSound].
class EditSoundState extends State<EditSound> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final id = widget.sound.id;
    final gain = widget.sound.gain;
    final asset = getAssetReferenceReference(
      assets: widget.assetStore.assets,
      id: id,
    );
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (widget.nullable)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onChanged(null);
                },
                child: const Icon(
                  Icons.clear_all_outlined,
                  semanticLabel: 'Clear Sound',
                ),
              )
          ],
          title: Text(widget.title),
        ),
        body: ListView(
          children: [
            PlaySoundSemantics(
              soundChannel: widget.projectContext.game.interfaceSounds,
              assetReference: asset.reference,
              gain: gain,
              child: Builder(
                builder: (context) => ListTile(
                  autofocus: true,
                  title: const Text('Asset'),
                  subtitle: Text(
                    assetString(asset),
                  ),
                  onTap: () {
                    pushWidget(
                      context: context,
                      builder: (context) => SelectAsset(
                        projectContext: widget.projectContext,
                        assetStore: widget.assetStore,
                        onDone: (value) {
                          Navigator.pop(context);
                          widget.sound.id = value!.variableName;
                          saveSound();
                          setState(() {});
                        },
                        currentId: widget.sound.id,
                        title: widget.title,
                      ),
                    );
                  },
                ),
              ),
            ),
            GainListTile(
              gain: gain,
              onChange: (value) {
                widget.sound.gain = value;
                saveSound();
                setState(() {});
              },
            )
          ],
        ),
      ),
    );
  }

  /// Save the sound.
  void saveSound() {
    widget.onChanged(widget.sound);
  }
}
