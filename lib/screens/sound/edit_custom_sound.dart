// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/sound/audio_bus_list_tile.dart';
import '../../widgets/sound/gain_list_tile.dart';
import '../asset_store/select_asset.dart';
import '../asset_store/select_asset_store.dart';

/// A widget for editing a [CustomSound] [value].
class EditCustomSound extends StatefulWidget {
  /// Create an instance.
  const EditCustomSound({
    required this.projectContext,
    required this.value,
    this.clearFunc,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The custom sound to edit.
  final CustomSound value;

  /// The function to call to clear the [value].
  ///
  /// If this value is `null`, then it will not be possible to clear the
  /// [value].
  final VoidCallback? clearFunc;

  /// Create state for this widget.
  @override
  EditCustomSoundState createState() => EditCustomSoundState();
}

/// State for [EditCustomSound].
class EditCustomSoundState extends State<EditCustomSound> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final clearFunc = widget.clearFunc;
    final worldContext = widget.projectContext.worldContext;
    final assetStore = worldContext.getAssetStore(widget.value.assetStore);
    final assetReferenceReference = assetStore.assets.firstWhere(
      (element) => element.variableName == widget.value.id,
    );
    final audioBusId = widget.value.audioBusId;
    final audioBus =
        audioBusId == null ? null : worldContext.world.getAudioBus(audioBusId);
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (clearFunc != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  clearFunc();
                },
                child: const Icon(
                  Icons.clear,
                  semanticLabel: 'Clear Sound',
                ),
              )
          ],
          title: const Text('Edit Custom Sound'),
        ),
        body: ListView(
          children: [
            ListTile(
              autofocus: true,
              title: const Text('Asset Store'),
              subtitle: Text('${assetStore.comment}'),
              onTap: () => pushWidget(
                context: context,
                builder: (context) => SelectAssetStore(
                  projectContext: widget.projectContext,
                  onDone: (store) {
                    if (store == null) {
                      Navigator.pop(context);
                    } else {
                      pushWidget(
                        context: context,
                        builder: (context) {
                          final newAssetStore = worldContext.getAssetStore(
                            store,
                          );
                          return SelectAsset(
                            projectContext: widget.projectContext,
                            assetStore: newAssetStore,
                            onDone: (asset) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              if (asset != null) {
                                widget.value
                                  ..assetStore = store
                                  ..id = asset.variableName;
                                save();
                              }
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
            PlaySoundSemantics(
              child: Builder(
                builder: (context) => ListTile(
                  title: const Text('Asset'),
                  subtitle: Text('${assetReferenceReference.comment}'),
                  onTap: () {
                    PlaySoundSemantics.of(context)?.stop();
                    pushWidget(
                      context: context,
                      builder: (context) => SelectAsset(
                        projectContext: widget.projectContext,
                        assetStore: assetStore,
                        onDone: (value) {
                          widget.value.id = value!.variableName;
                          save();
                        },
                        currentId: widget.value.id,
                        title: 'Asset',
                      ),
                    );
                  },
                ),
              ),
              soundChannel: widget.projectContext.game.interfaceSounds,
              assetReference: assetReferenceReference.reference,
              gain: widget.value.gain,
            ),
            GainListTile(
              gain: widget.value.gain,
              onChange: (value) {
                widget.value.gain = value;
                save();
              },
            ),
            AudioBusListTile(
              projectContext: widget.projectContext,
              audioBus: audioBus,
              onChanged: (value) {
                widget.value.audioBusId = value?.id;
                save();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Save the project context, and call[setState].
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
