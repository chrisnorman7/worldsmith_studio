import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/get_number.dart';
import '../../widgets/text_list_tile.dart';
import '../asset_store/select_asset.dart';
import 'reverb_setting.dart';

const _synthizerReverbUrl =
    'https://synthizer.github.io/object_reference/global_fdn_reverb.html';
const _meanFreePathSetting = ReverbSetting(
  name: 'The mean free path of the simulated environment',
  defaultValue: 0.1,
  min: 0.0,
  max: 0.5,
  modify: 0.01,
);
const _t60Setting = ReverbSetting(
  name: 'T60',
  defaultValue: 0.3,
  min: 0.0,
  max: 100.0,
  modify: 1.0,
);
const _lateReflectionsLfRolloffSetting = ReverbSetting(
  name: 'Multiplicative factor on T60 for the low frequency band',
  defaultValue: 1.0,
  min: 0.0,
  max: 2.0,
);
const _lateReflectionsLfReferenceSetting = ReverbSetting(
  name: 'Where the low band of the feedback equalizer ends',
  defaultValue: 200.0,
  min: 0.0,
  max: 22050.0,
  modify: 1000.0,
);
const _lateReflectionsHfRolloffSetting = ReverbSetting(
  name: 'Multiplicative factor on T60 for the high frequency band',
  defaultValue: 0.5,
  min: 0.0,
  max: 2.0,
);
const _lateReflectionsHfReferenceSetting = ReverbSetting(
  name: 'Where the high band of the equalizer starts',
  defaultValue: 500.0,
  min: 0.0,
  max: 22050.0,
  modify: 1000.0,
);
const _lateReflectionsDiffusionSetting = ReverbSetting(
  name: 'Controls the diffusion of the late reflections as a percent',
  defaultValue: 1.0,
  min: 0.0,
  max: 1.0,
);
const _lateReflectionsModulationDepthSetting = ReverbSetting(
  name: 'Depth of the modulation of the delay lines on the feedback path in '
      'seconds',
  defaultValue: 0.01,
  min: 0.0,
  max: 0.3,
);
const _lateReflectionsModulationFrequencySetting = ReverbSetting(
  name: 'Frequency of the modulation of the delay lines int he feedback paths',
  defaultValue: 0.5,
  min: 0.01,
  max: 100.0,
  modify: 5.0,
);
const _lateReflectionsDelaySetting = ReverbSetting(
  name: 'The delay of the late reflections relative to the input in seconds',
  defaultValue: 0.03,
  min: 0.0,
  max: 0.5,
  modify: 0.001,
);
const _gainSetting = ReverbSetting(
  name: 'Gain',
  defaultValue: 0.7,
  min: 0.0,
  max: 5.0,
  modify: 0.25,
);

/// A widget for editing a reverb preset.
class EditReverbPreset extends StatefulWidget {
  /// Create an instance.
  const EditReverbPreset({
    required this.projectContext,
    required this.reverbPresetReference,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The reverb preset to work with.
  final ReverbPresetReference reverbPresetReference;

  /// Create state for this widget.
  @override
  _EditReverbPresetState createState() => _EditReverbPresetState();
}

/// State for [EditReverbPreset].
class _EditReverbPresetState extends State<EditReverbPreset> {
  late final SoundChannel channel;
  CreateReverb? reverb;
  PlaySound? _playSound;

  /// Initialise stuff.
  @override
  void initState() {
    super.initState();
    channel = widget.projectContext.game.createSoundChannel();
  }

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final playPauseAction = CallbackAction<PlayPauseIntent>(
      onInvoke: (intent) {
        if (_playSound == null) {
          play();
        } else {
          stop(false);
        }
        setState(() {});
        return null;
      },
    );
    if (_playSound != null) {
      resetReverb();
    }
    final preset = widget.reverbPresetReference.reverbPreset;
    final testAssetReference = getAssetReferenceReference(
      assets: widget.projectContext.world.interfaceSoundsAssets,
      id: widget.reverbPresetReference.sound?.id,
    );
    final listTiles = [
      ListTile(
        title: const Text('Test asset'),
        subtitle: Text(
          testAssetReference == null
              ? 'Not set'
              : assetString(testAssetReference),
        ),
        onTap: () => pushWidget(
          context: context,
          builder: (context) => SelectAsset(
            projectContext: widget.projectContext,
            assetStore: widget.projectContext.world.interfaceSoundsAssetStore,
            onDone: (value) {
              Navigator.pop(context);
              if (value == null) {
                widget.reverbPresetReference.sound = null;
              } else {
                widget.reverbPresetReference.sound = Sound(
                  id: value.variableName,
                  gain: widget.projectContext.world.soundOptions.defaultGain,
                );
              }
              widget.projectContext.save();
              setState(play);
            },
            currentId: widget.reverbPresetReference.sound?.id,
            nullable: true,
            title: 'Reverb Test Sound',
          ),
        ),
      ),
      TextListTile(
        value: preset.name,
        onChanged: (value) {
          setReverbValue(name: value);
        },
        header: 'Name',
        autofocus: true,
        validator: (value) => validateNonEmptyValue(value: value),
      ),
      getSettingTile(
        context: context,
        value: preset.gain,
        setting: _gainSetting,
        onDone: (value) => setReverbValue(gain: value),
      ),
      getSettingTile(
        context: context,
        value: preset.meanFreePath,
        setting: _meanFreePathSetting,
        onDone: (value) => setReverbValue(meanFreePath: value),
      ),
      getSettingTile(
        context: context,
        value: preset.t60,
        setting: _t60Setting,
        onDone: (value) => setReverbValue(t60: value),
      ),
      getSettingTile(
        context: context,
        value: preset.lateReflectionsLfRolloff,
        setting: _lateReflectionsLfRolloffSetting,
        onDone: (value) => setReverbValue(lateReflectionsLfRolloff: value),
      ),
      getSettingTile(
        context: context,
        value: preset.lateReflectionsLfReference,
        setting: _lateReflectionsLfReferenceSetting,
        onDone: (value) => setReverbValue(lateReflectionsLfReference: value),
      ),
      getSettingTile(
        context: context,
        value: preset.lateReflectionsHfRolloff,
        setting: _lateReflectionsHfRolloffSetting,
        onDone: (value) => setReverbValue(lateReflectionsHfRolloff: value),
      ),
      getSettingTile(
        context: context,
        value: preset.lateReflectionsHfReference,
        setting: _lateReflectionsHfReferenceSetting,
        onDone: (value) => setReverbValue(lateReflectionsHfReference: value),
      ),
      getSettingTile(
        context: context,
        value: preset.lateReflectionsDiffusion,
        setting: _lateReflectionsDiffusionSetting,
        onDone: (value) => setReverbValue(lateReflectionsDiffusion: value),
      ),
      getSettingTile(
        context: context,
        value: preset.lateReflectionsModulationDepth,
        setting: _lateReflectionsModulationDepthSetting,
        onDone: (value) =>
            setReverbValue(lateReflectionsModulationDepth: value),
      ),
      getSettingTile(
        context: context,
        value: preset.lateReflectionsModulationFrequency,
        setting: _lateReflectionsModulationFrequencySetting,
        onDone: (value) =>
            setReverbValue(lateReflectionsModulationFrequency: value),
      ),
      getSettingTile(
        context: context,
        value: preset.lateReflectionsDelay,
        setting: _lateReflectionsDelaySetting,
        onDone: (value) => setReverbValue(lateReflectionsDelay: value),
      )
    ];
    return Cancel(
      child: Shortcuts(
        child: Actions(
          actions: {
            PlayPauseIntent: playPauseAction,
          },
          child: Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Edit Reverb Preset'),
                actions: [
                  IconButton(
                    onPressed: () {
                      final id = widget.reverbPresetReference.id;
                      for (final zone in widget.projectContext.world.zones) {
                        for (final box in zone.boxes) {
                          if (box.reverbId == id) {
                            return showSnackBar(
                              context: context,
                              message: 'You cannot delete the reverb for the '
                                  '${box.name} of the ${zone.name} zone.',
                            );
                          }
                        }
                      }
                      confirm(
                        context: context,
                        yesCallback: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          widget.projectContext.world.reverbs.removeWhere(
                            (element) => element.id == id,
                          );
                        },
                        message: 'Are you sure you want to delete the '
                            '${preset.name} reverb?',
                        title: 'Confirm Delete',
                      );
                    },
                    icon: const Icon(Icons.delete_rounded),
                    tooltip: 'Delete Reverb Preset',
                  ),
                  IconButton(
                    onPressed: () => launch(_synthizerReverbUrl),
                    icon: const Icon(Icons.help_rounded),
                    tooltip: 'Synthizer Help',
                  ),
                  ElevatedButton(
                    onPressed: Actions.handler<PlayPauseIntent>(
                      context,
                      const PlayPauseIntent(),
                    ),
                    child: _playSound == null
                        ? const Icon(
                            Icons.play_arrow_rounded,
                            semanticLabel: 'Play',
                          )
                        : const Icon(
                            Icons.pause_rounded,
                            semanticLabel: 'Pause',
                          ),
                  )
                ],
              ),
              body: ListView(
                children: listTiles,
              ),
            ),
          ),
        ),
        shortcuts: const {
          PlayPauseIntent.hotkey: PlayPauseIntent(),
        },
      ),
    );
  }

  /// Set a reverb value.
  void setReverbValue({
    AssetReference? assetReference,
    String? name,
    String? variableName,
    double? gain,
    double? lateReflectionsDelay,
    double? lateReflectionsDiffusion,
    double? lateReflectionsHfReference,
    double? lateReflectionsHfRolloff,
    double? lateReflectionsLfReference,
    double? lateReflectionsLfRolloff,
    double? lateReflectionsModulationDepth,
    double? lateReflectionsModulationFrequency,
    double? meanFreePath,
    double? t60,
  }) {
    final oldPreset = widget.reverbPresetReference.reverbPreset;
    widget.reverbPresetReference.reverbPreset = ReverbPreset(
      name: name ?? oldPreset.name,
      gain: gain ?? oldPreset.gain,
      lateReflectionsDelay:
          lateReflectionsDelay ?? oldPreset.lateReflectionsDelay,
      lateReflectionsDiffusion:
          lateReflectionsDiffusion ?? oldPreset.lateReflectionsDiffusion,
      lateReflectionsHfReference:
          lateReflectionsHfReference ?? oldPreset.lateReflectionsHfReference,
      lateReflectionsHfRolloff:
          lateReflectionsHfRolloff ?? oldPreset.lateReflectionsHfRolloff,
      lateReflectionsLfReference:
          lateReflectionsLfReference ?? oldPreset.lateReflectionsLfReference,
      lateReflectionsLfRolloff:
          lateReflectionsLfRolloff ?? oldPreset.lateReflectionsLfRolloff,
      lateReflectionsModulationDepth: lateReflectionsModulationDepth ??
          oldPreset.lateReflectionsModulationDepth,
      lateReflectionsModulationFrequency: lateReflectionsModulationFrequency ??
          oldPreset.lateReflectionsModulationFrequency,
      meanFreePath: meanFreePath ?? oldPreset.meanFreePath,
      t60: t60 ?? oldPreset.t60,
    );
    widget.projectContext.save();
    setState(() {});
  }

  /// Stop the sound.
  void stop(bool destroyReverb) {
    _playSound?.destroy();
    _playSound = null;
    if (destroyReverb) {
      channel.setReverb(null);
      reverb?.destroy();
      reverb = null;
    }
  }

  /// Reset the reverb.
  void resetReverb() {
    reverb?.destroy();
    reverb = widget.projectContext.game.createReverb(
      widget.reverbPresetReference.reverbPreset,
    );
    channel.setReverb(reverb);
  }

  /// Play the sound (if any).
  void play() {
    stop(true);
    final sound = widget.reverbPresetReference.sound;
    if (sound != null) {
      resetReverb();
      final reference = getAssetReferenceReference(
        assets: widget.projectContext.world.interfaceSoundsAssets,
        id: sound.id,
      );
      _playSound = channel.playSound(
        widget.projectContext.getRelativeAssetReference(reference!.reference),
        gain: sound.gain,
        keepAlive: true,
        looping: true,
      );
    }
  }

  /// Destroy stuff.
  @override
  void dispose() {
    super.dispose();
    stop(true);
    channel.destroy();
  }

  /// Get a list tile for the given setting.
  Shortcuts getSettingTile({
    required BuildContext context,
    required double value,
    required ReverbSetting setting,
    required ValueChanged<double> onDone,
  }) {
    final increaseAction = CallbackAction<IncreaseIntent>(
      onInvoke: (intent) => onDone(min(setting.max, value + setting.modify)),
    );
    final decreaseAction = CallbackAction<DecreaseIntent>(
      onInvoke: (intent) => onDone(max(setting.min, value - setting.modify)),
    );
    return Shortcuts(
      child: Actions(
        actions: {
          IncreaseIntent: increaseAction,
          DecreaseIntent: decreaseAction,
        },
        child: ListTile(
          title: Text(setting.name),
          subtitle: TextButton(
            child: Text(value.toString()),
            onPressed: () => pushWidget(
              context: context,
              builder: (context) => GetNumber(
                value: value,
                onDone: (value) {
                  Navigator.pop(context);
                  onDone(value);
                },
                min: setting.min,
                max: setting.max,
                labelText: setting.name,
                title: 'Change Reverb Setting',
              ),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.restore_rounded),
            tooltip: 'Restore to ${setting.defaultValue}',
            onPressed: () => onDone(setting.defaultValue),
          ),
          isThreeLine: true,
        ),
      ),
      shortcuts: const {
        IncreaseIntent.hotkey: IncreaseIntent(),
        DecreaseIntent.hotkey: DecreaseIntent(),
      },
    );
  }
}
