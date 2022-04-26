// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../asset_store/select_asset.dart';

/// Show a list of [ambiances].
class EditAmbiances extends StatefulWidget {
  /// Create an instance.
  const EditAmbiances({
    required this.projectContext,
    required this.ambiances,
    this.title = 'Ambiances',
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The ambiances to show.
  final List<Sound> ambiances;

  /// The title of the [Scaffold]'s [AppBar].
  final String title;

  /// Create state for this widget.
  @override
  EditAmbiancesState createState() => EditAmbiancesState();
}

/// State for [EditAmbiances].
class EditAmbiancesState extends State<EditAmbiances> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final addAmbianceAction = CallbackAction<AddAmbianceIntent>(
      onInvoke: (final intent) => addAmbiance(context),
    );
    final world = widget.projectContext.world;
    return Cancel(
      child: WithKeyboardShortcuts(
        keyboardShortcuts: const [
          KeyboardShortcut(
            description: 'Add a new ambiance.',
            keyName: 'N',
            control: true,
          )
        ],
        child: Shortcuts(
          shortcuts: {AddAmbianceIntent.hotkey: const AddAmbianceIntent()},
          child: Actions(
            actions: {AddAmbianceIntent: addAmbianceAction},
            child: Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
              ),
              body: ListView.builder(
                itemBuilder: (final context, final index) {
                  final sound = widget.ambiances[index];
                  return SoundListTile(
                    projectContext: widget.projectContext,
                    value: sound,
                    onDone: (final value) {
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
                tooltip: 'Add Ambiance',
                child: const Icon(Icons.add_outlined),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Save the project context.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Add an ambiance.
  Future<void> addAmbiance(final BuildContext context) async => pushWidget(
        context: context,
        builder: (final context) => SelectAsset(
          projectContext: widget.projectContext,
          assetStore: widget.projectContext.world.ambianceAssetStore,
          onDone: (final value) {
            final sound = Sound(id: value!.variableName);
            widget.ambiances.add(sound);
            Navigator.pop(context);
            save();
          },
          title: 'Select Ambiance Asset',
        ),
      );
}
