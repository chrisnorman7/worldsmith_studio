import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../screens/asset_store/select_asset.dart';
import '../../screens/asset_store/select_asset_store.dart';
import '../../util.dart';
import '../play_sound_semantics.dart';

/// A widget for displaying a [CustomSound].
class CustomSoundListTile extends StatefulWidget {
  /// Create an instance.
  const CustomSoundListTile({
    required this.projectContext,
    required this.value,
    required this.onCreate,
    this.title = 'Sound',
    this.onClear,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The sound to view and edit.
  final CustomSound? value;

  /// The function to call to create a new sound.
  final ValueChanged<CustomSound> onCreate;

  /// The title for the resulting [ListTile].
  final String title;

  /// A function to be called to set the [value] to `null`.
  ///
  /// If this value is `null`, then it will not be possible to clear the
  /// [value].
  final VoidCallback? onClear;

  /// Create state for this widget.
  @override
  CustomSoundListTileState createState() => CustomSoundListTileState();
}

/// State for [CustomSoundListTile].
class CustomSoundListTileState extends State<CustomSoundListTile> {
  CustomSound? _sound;

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final onClear = widget.onClear;
    final sound = _sound ?? widget.value;
    if (sound == null) {
      return ListTile(
        title: Text(widget.title),
        subtitle: const Text('Not set'),
        onTap: () => pushWidget(
          context: context,
          builder: (context) => SelectAssetStore(
            projectContext: widget.projectContext,
            onDone: (customAssetStore) {
              if (customAssetStore == null) {
                Navigator.pop(context);
                return;
              }
              pushWidget(
                context: context,
                builder: (context) => SelectAsset(
                  projectContext: widget.projectContext,
                  assetStore: widget.projectContext.worldContext.getAssetStore(
                    customAssetStore,
                  ),
                  onDone: (reference) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    if (reference == null) {
                      return;
                    }
                    final sound = CustomSound(
                      assetStore: customAssetStore,
                      id: reference.variableName,
                    );
                    widget.onCreate(sound);
                  },
                ),
              );
            },
          ),
        ),
      );
    }
    final assetStore = widget.projectContext.worldContext.getAssetStore(
      sound.assetStore,
    );
    final reference = assetStore.assets.firstWhere(
      (element) => element.variableName == sound.id,
    );
    return PlaySoundSemantics(
      soundChannel: widget.projectContext.game.interfaceSounds,
      assetReference: reference.reference,
      gain: sound.gain,
      child: ListTile(
        title: Text(widget.title),
        subtitle: Text('${assetStore.comment}/${reference.comment}'),
        onTap: () => pushWidget(
          context: context,
          builder: (context) => SelectAssetStore(
            projectContext: widget.projectContext,
            onDone: (customSoundAssetStore) {
              if (customSoundAssetStore == null) {
                if (onClear != null) {
                  onClear();
                }
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
                        if (onClear != null) {
                          onClear();
                        }
                      } else {
                        sound
                          ..assetStore = customSoundAssetStore
                          ..id = newAssetReference.variableName;
                      }
                      save();
                    },
                    currentId: sound.id,
                    nullable: onClear != null,
                  ),
                );
              }
            },
            currentAssetStore: sound.assetStore,
          ),
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
