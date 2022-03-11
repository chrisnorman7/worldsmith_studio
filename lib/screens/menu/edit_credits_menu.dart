import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/ziggurat.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/music_widget.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/sound/fade_time_list_tile.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/text_list_tile.dart';
import '../credits/edit_credit.dart';

/// A widget for editing the credits menu.
class EditCreditsMenu extends StatefulWidget {
  /// Create an instance.
  const EditCreditsMenu({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _EditCreditsMenuState createState() => _EditCreditsMenuState();
}

/// State for [EditCreditsMenu].
class _EditCreditsMenuState extends State<EditCreditsMenu> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final defaultGain = world.soundOptions.defaultGain;
    final options = world.creditsMenuOptions;
    return Cancel(
      child: MusicWidget(
        getFadeTime: () => options.fadeTime,
        getMusic: () => world.creditsMenuMusic,
        soundChannel: widget.projectContext.game.musicSounds,
        title: options.title,
        child: ListView(
          children: [
            TextListTile(
              value: options.title,
              onChanged: (value) {
                options.title = value;
                save();
              },
              header: 'Title',
              autofocus: true,
              title: 'Menu Title',
              validator: (value) => validateNonEmptyValue(value: value),
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: options.music,
              onDone: (value) {
                options.music = value;
                save();
              },
              assetStore: world.musicAssetStore,
              defaultGain: defaultGain,
              nullable: true,
              title: 'Credits Menu Music',
              playSound: false,
            ),
            FadeTimeListTile(
              value: options.fadeTime,
              onChanged: (value) {
                options.fadeTime = value;
                save();
              },
            ),
            const Divider(),
            for (final credit in world.credits)
              getCreditListTile(context: context, credit: credit)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final credit = WorldCredit(
              id: newId(),
              title: 'Person: Responsibility',
            );
            world.credits.add(credit);
            save();
          },
          child: createIcon,
          tooltip: 'Add Credit',
        ),
      ),
    );
  }

  /// Save the project context and set state.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Return  list tile suitable for editing the given [credit].
  Widget getCreditListTile({
    required BuildContext context,
    required WorldCredit credit,
  }) {
    final world = widget.projectContext.world;
    final defaultGain = world.soundOptions.defaultGain;
    final sound = credit.sound;
    final AssetReference? assetReference;
    if (sound != null) {
      assetReference =
          getAssetReferenceReference(assets: world.creditsAssets, id: sound.id)
              .reference;
    } else {
      assetReference = world.menuMoveSound;
    }
    final gain =
        sound?.gain ?? world.soundOptions.menuMoveSound?.gain ?? defaultGain;
    return PlaySoundSemantics(
      child: ListTile(
        leading: credit.id == world.credits.first.id
            ? null
            : IconButton(
                onPressed: () {
                  final index = world.credits.indexWhere(
                    (element) => element.id == credit.id,
                  );
                  world.credits.removeAt(index);
                  world.credits.insert(index - 1, credit);
                  widget.projectContext.save();
                  setState(() {});
                },
                icon: const Icon(Icons.move_up),
                tooltip: 'Move Up',
              ),
        title: Text(credit.title),
        subtitle: Text(credit.url ?? 'Not set'),
        onTap: () async {
          widget.projectContext.playActivateSound();
          await pushWidget(
            context: context,
            builder: (context) => EditCredit(
              projectContext: widget.projectContext,
              credit: credit,
            ),
          );
          setState(() {});
        },
      ),
      soundChannel: widget.projectContext.game.interfaceSounds,
      assetReference: assetReference,
      gain: gain,
    );
  }
}
