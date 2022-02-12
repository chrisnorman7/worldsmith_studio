import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat_sounds/ziggurat_sounds.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../asset_store/select_asset.dart';
import 'gain_list_tile.dart';

/// A widget for editing a [sound].
class EditSound extends StatefulWidget {
  /// Create an instance.
  const EditSound({
    required this.projectContext,
    required this.assetStore,
    required this.sound,
    this.title = 'Edit Sound',
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The asset store to get the sound from.
  final AssetStore assetStore;

  /// The sound to work with.
  final Sound sound;

  /// The title of the resulting scaffold.
  final String title;

  /// Create state for this widget.
  @override
  _EditSoundState createState() => _EditSoundState();
}

/// State for [EditSound].
class _EditSoundState extends State<EditSound> {
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
          title: Text(widget.title),
        ),
        body: ListView(
          children: [
            ListTile(
              autofocus: true,
              title: const Text('Asset'),
              subtitle: Text(
                asset == null ? 'Not set' : assetString(asset),
              ),
              onTap: () => pushWidget(
                context: context,
                builder: (context) => SelectAsset(
                  projectContext: widget.projectContext,
                  assetStore: widget.assetStore,
                  onDone: (value) {
                    Navigator.pop(context);
                    widget.sound.id = value!.variableName;
                    widget.projectContext.save();
                    setState(() {});
                  },
                  currentId: widget.sound.id,
                ),
              ),
            ),
            GainListTile(
              gain: gain,
              onChange: (value) {
                widget.sound.gain = value;
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
