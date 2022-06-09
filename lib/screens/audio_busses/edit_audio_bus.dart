import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/sound.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/custom_sound/custom_sound_list_tile.dart';
import '../../widgets/number_list_tile.dart';
import '../../widgets/push_widget_list_tile.dart';
import '../../widgets/reverb/reverb_list_tile.dart';
import '../../widgets/select_item.dart';
import '../../widgets/sound/gain_list_tile.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing the given [audioBus].
class EditAudioBus extends StatefulWidget {
  /// Create an instance.
  const EditAudioBus({
    required this.projectContext,
    required this.audioBus,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The audio bus to edit.
  final AudioBus audioBus;

  /// Create state for this widget.
  @override
  EditAudioBusState createState() => EditAudioBusState();
}

/// State for [EditAudioBus].
class EditAudioBusState extends State<EditAudioBus> {
  PlaySound? _sound;
  SoundChannel? _soundChannel;

  /// Reset the sound channel.
  SoundChannel resetSoundChannel() {
    final world = widget.projectContext.world;
    final reverbId = widget.audioBus.reverbId;
    _soundChannel?.destroy();
    final channel = widget.projectContext.game.createSoundChannel(
      position: widget.audioBus.position,
      gain: widget.audioBus.gain ?? world.soundOptions.defaultGain,
      reverb: reverbId == null
          ? null
          : widget.projectContext.worldContext.getReverb(
              world.getReverbPresetReference(
                reverbId,
              ),
            ),
    );
    _soundChannel = channel;
    return channel;
  }

  /// Play or pause the test sound.
  void playPause() {
    final sound = _sound;
    final testSound = widget.audioBus.testSound;
    if (testSound == null || sound != null) {
      destroySoundObjects();
    } else {
      // Start playing.
      final worldContext = widget.projectContext.worldContext;
      final assetStore = worldContext.getAssetStore(testSound.assetStore);
      final asset = getAssetReferenceReference(
        assets: assetStore.assets,
        id: testSound.id,
      );
      _sound = resetSoundChannel().playSound(
        asset.reference,
        keepAlive: true,
        gain: testSound.gain,
        looping: true,
      );
    }
  }

  /// Destroy sound-related objects.
  void destroySoundObjects() {
    _sound?.destroy();
    _sound = null;
    _soundChannel?.destroy();
    _soundChannel = null;
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final panningType = widget.audioBus.panningType;
    String? xTitle;
    double? xMin;
    double? xMax;
    String? yTitle;
    double? yMin;
    double? yMax;
    String? zTitle;
    double? zMin;
    double? zMax;
    switch (panningType) {
      case PanningType.direct:
        // Don't allow editing coordinates.
        break;
      case PanningType.angular:
        xTitle = 'Azimuth';
        xMin = 0.0;
        xMax = 360.0;
        yTitle = 'Elevation';
        yMin = -90.0;
        yMax = 90.0;
        break;
      case PanningType.scalar:
        xTitle = 'Balance';
        xMin = -1.0;
        xMax = 1.0;
        break;
      case PanningType.threeD:
        xTitle = 'X';
        yTitle = 'Y';
        zTitle = 'Z';
        break;
    }
    return Cancel(
      child: CallbackShortcuts(
        bindings: {
          PlayPauseIntent.hotkey: () {
            playPause();
            setState(() {});
          }
        },
        child: Scaffold(
          appBar: AppBar(
            actions: [
              ElevatedButton(
                onPressed: () {
                  playPause();
                  setState(() {});
                },
                child: Icon(
                  _sound == null ? Icons.play_arrow : Icons.pause,
                  semanticLabel:
                      _sound == null ? 'Play Test Sound' : 'Stop Test Sound',
                ),
              )
            ],
            title: const Text('Edit Audio Bus'),
          ),
          body: ListView(
            children: [
              CustomSoundListTile(
                projectContext: widget.projectContext,
                value: widget.audioBus.testSound,
                onChanged: (final value) {
                  widget.audioBus.testSound = value;
                  save();
                },
                title: 'Test Sound',
              ),
              TextListTile(
                value: widget.audioBus.name,
                onChanged: (final value) {
                  widget.audioBus.name = value;
                  save();
                },
                header: 'Name',
                autofocus: true,
                validator: (final value) => validateNonEmptyValue(value: value),
              ),
              GainListTile(
                gain: widget.audioBus.gain ?? world.soundOptions.defaultGain,
                onChange: (final value) {
                  widget.audioBus.gain = value;
                  save();
                },
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.audioBus.gain = null;
                      save();
                    },
                    child: const Icon(
                      Icons.clear,
                      semanticLabel: 'Clear Gain',
                    ),
                  )
                ],
              ),
              PushWidgetListTile(
                title: 'Panning Type',
                builder: (final context) => SelectItem<PanningType>(
                  onDone: (final value) {
                    Navigator.pop(context);
                    widget.audioBus
                      ..panningType = value
                      ..x = 0.0
                      ..y = 0.0
                      ..z = 0.0;
                    save();
                  },
                  values: PanningType.values,
                  getItemWidget: (final value) => Text(value.name),
                  title: 'Select Panning Type',
                  value: panningType,
                ),
                subtitle: panningType.name,
              ),
              if (xTitle != null)
                NumberListTile(
                  value: widget.audioBus.x,
                  onChanged: (final value) {
                    widget.audioBus.x = value;
                    save();
                  },
                  min: xMin,
                  max: xMax,
                  title: xTitle,
                ),
              if (yTitle != null)
                NumberListTile(
                  value: widget.audioBus.y,
                  onChanged: (final value) {
                    widget.audioBus.y = value;
                    save();
                  },
                  min: yMin,
                  max: yMax,
                  title: yTitle,
                ),
              if (zTitle != null)
                NumberListTile(
                  value: widget.audioBus.z,
                  onChanged: (final value) {
                    widget.audioBus.z = value;
                    save();
                  },
                  min: zMin,
                  max: zMax,
                  title: zTitle,
                ),
              ReverbListTile(
                projectContext: widget.projectContext,
                onDone: (final value) {
                  widget.audioBus.reverbId = value?.id;
                  save();
                },
                reverbPresets: world.reverbs,
                currentReverbId: widget.audioBus.reverbId,
                nullable: true,
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    final playing = _sound != null;
    destroySoundObjects();
    if (playing) {
      playPause();
    }
    setState(() {});
  }

  /// Dispose of the widget.
  @override
  void dispose() {
    super.dispose();
    destroySoundObjects();
  }
}
