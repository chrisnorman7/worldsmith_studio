import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../asset_store/select_asset.dart';
import '../sound/sound_list_tile.dart';

/// Show a list of [ambiances].
class EditAmbiances extends StatefulWidget {
  /// Create an instance.
  const EditAmbiances({
    required this.projectContext,
    required this.ambiances,
    this.title = 'Ambiances',
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The ambiances to show.
  final List<Sound> ambiances;

  /// The title of the [Scaffold]'s [AppBar].
  final String title;

  /// Create state for this widget.
  @override
  _EditAmbiancesState createState() => _EditAmbiancesState();
}

/// State for [EditAmbiances].
class _EditAmbiancesState extends State<EditAmbiances> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final addAmbianceAction = CallbackAction<AddAmbianceIntent>(
      onInvoke: (intent) => addAmbiance(context),
    );
    final world = widget.projectContext.world;
    return Cancel(
      child: WithKeyboardShortcuts(
        child: Shortcuts(
          child: Actions(
            actions: {AddAmbianceIntent: addAmbianceAction},
            child: Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
              ),
              body: ListView.builder(
                itemBuilder: (context, index) {
                  final sound = widget.ambiances[index];
                  return SoundListTile(
                    projectContext: widget.projectContext,
                    value: sound,
                    onDone: (value) {
                      if (value == null) {
                        widget.ambiances.remove(sound);
                        save();
                      } else {
                        save();
                      }
                    },
                    assetStore: world.ambianceAssetStore,
                    defaultGain: world.soundOptions.defaultGain,
                    autofocus: index == 0,
                    nullable: true,
                    looping: true,
                  );
                },
                itemCount: widget.ambiances.length,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => addAmbiance(context),
                autofocus: widget.ambiances.isEmpty,
                child: const Icon(Icons.add_outlined),
                tooltip: 'Add Ambiance',
              ),
            ),
          ),
          shortcuts: {AddAmbianceIntent.hotkey: const AddAmbianceIntent()},
        ),
        keyboardShortcuts: const [
          KeyboardShortcut(
            description: 'Add a new ambiance.',
            keyName: 'N',
            control: true,
          )
        ],
      ),
    );
  }

  /// Save the project context.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Add an ambiance.
  void addAmbiance(BuildContext context) async => pushWidget(
        context: context,
        builder: (context) => SelectAsset(
          projectContext: widget.projectContext,
          assetStore: widget.projectContext.world.ambianceAssetStore,
          onDone: (value) {
            final sound = Sound(id: value!.variableName);
            widget.ambiances.add(sound);
            Navigator.pop(context);
            save();
          },
          title: 'Select Ambiance Asset',
        ),
      );
}
