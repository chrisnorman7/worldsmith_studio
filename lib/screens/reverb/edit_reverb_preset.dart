import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/custom_sound/custom_sound_list_tile.dart';
import '../../widgets/get_number.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/text_list_tile.dart';
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
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The reverb preset to work with.
  final ReverbPresetReference reverbPresetReference;

  /// Create state for this widget.
  @override
  EditReverbPresetState createState() => EditReverbPresetState();
}

/// State for [EditReverbPreset].
class EditReverbPresetState extends State<EditReverbPreset> {
  /// The channel to play sounds through.
  late final SoundChannel channel;

  /// The reverb that [SoundChannel] will use.
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
  Widget build(final BuildContext context) {
    final playPauseAction = CallbackAction<PlayPauseIntent>(
      onInvoke: (final intent) {
        if (_playSound == null) {
          play();
        } else {
          stop(destroyReverb: false);
        }
        setState(() {});
        return null;
      },
    );
    if (_playSound != null) {
      resetReverb();
    }
    final preset = widget.reverbPresetReference.reverbPreset;
    final listTiles = [
      CustomSoundListTile(
        projectContext: widget.projectContext,
        value: widget.reverbPresetReference.sound,
        title: 'Preview Sound',
        onClear: () {
          widget.reverbPresetReference.sound = null;
          save();
        },
        onCreate: (final value) {
          widget.reverbPresetReference.sound = value;
          save();
        },
      ),
      TextListTile(
        value: preset.name,
        onChanged: (final value) {
          setReverbValue(name: value);
        },
        header: 'Name',
        autofocus: true,
        validator: (final value) => validateNonEmptyValue(value: value),
      ),
      getSettingTile(
        context: context,
        value: preset.gain,
        setting: _gainSetting,
        onDone: (final value) => setReverbValue(gain: value),
      ),
      getSettingTile(
        context: context,
        value: preset.meanFreePath,
        setting: _meanFreePathSetting,
        onDone: (final value) => setReverbValue(meanFreePath: value),
      ),
      getSettingTile(
        context: context,
        value: preset.t60,
        setting: _t60Setting,
        onDone: (final value) => setReverbValue(t60: value),
      ),
      getSettingTile(
        context: context,
        value: preset.lateReflectionsLfRolloff,
        setting: _lateReflectionsLfRolloffSetting,
        onDone: (final value) =>
            setReverbValue(lateReflectionsLfRolloff: value),
      ),
      getSettingTile(
        context: context,
        value: preset.lateReflectionsLfReference,
        setting: _lateReflectionsLfReferenceSetting,
        onDone: (final value) =>
            setReverbValue(lateReflectionsLfReference: value),
      ),
      getSettingTile(
        context: context,
        value: preset.lateReflectionsHfRolloff,
        setting: _lateReflectionsHfRolloffSetting,
        onDone: (final value) =>
            setReverbValue(lateReflectionsHfRolloff: value),
      ),
      getSettingTile(
        context: context,
        value: preset.lateReflectionsHfReference,
        setting: _lateReflectionsHfReferenceSetting,
        onDone: (final value) =>
            setReverbValue(lateReflectionsHfReference: value),
      ),
      getSettingTile(
        context: context,
        value: preset.lateReflectionsDiffusion,
        setting: _lateReflectionsDiffusionSetting,
        onDone: (final value) =>
            setReverbValue(lateReflectionsDiffusion: value),
      ),
      getSettingTile(
        context: context,
        value: preset.lateReflectionsModulationDepth,
        setting: _lateReflectionsModulationDepthSetting,
        onDone: (final value) =>
            setReverbValue(lateReflectionsModulationDepth: value),
      ),
      getSettingTile(
        context: context,
        value: preset.lateReflectionsModulationFrequency,
        setting: _lateReflectionsModulationFrequencySetting,
        onDone: (final value) =>
            setReverbValue(lateReflectionsModulationFrequency: value),
      ),
      getSettingTile(
        context: context,
        value: preset.lateReflectionsDelay,
        setting: _lateReflectionsDelaySetting,
        onDone: (final value) => setReverbValue(lateReflectionsDelay: value),
      )
    ];
    return WithKeyboardShortcuts(
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Play or pause the preview sound.',
          keyName: 'P',
          control: true,
        ),
        KeyboardShortcut(
          description: 'Increase the selected value.',
          keyName: 'Equals (=)',
          control: true,
        ),
        KeyboardShortcut(
          description: 'Decrease the selected value',
          keyName: 'Dash (-)',
          control: true,
        )
      ],
      child: Cancel(
        child: Shortcuts(
          shortcuts: {
            PlayPauseIntent.hotkey: const PlayPauseIntent(),
          },
          child: Actions(
            actions: {
              PlayPauseIntent: playPauseAction,
            },
            child: Builder(
              builder: (final context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Edit Reverb Preset'),
                  actions: [
                    IconButton(
                      onPressed: () {
                        final id = widget.reverbPresetReference.id;
                        for (final zone in widget.projectContext.world.zones) {
                          for (final box in zone.boxes) {
                            if (box.reverbId == id) {
                              return showError(
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
                              (final element) => element.id == id,
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
        ),
      ),
    );
  }

  /// Set a reverb value.
  void setReverbValue({
    final AssetReference? assetReference,
    final String? name,
    final String? variableName,
    final double? gain,
    final double? lateReflectionsDelay,
    final double? lateReflectionsDiffusion,
    final double? lateReflectionsHfReference,
    final double? lateReflectionsHfRolloff,
    final double? lateReflectionsLfReference,
    final double? lateReflectionsLfRolloff,
    final double? lateReflectionsModulationDepth,
    final double? lateReflectionsModulationFrequency,
    final double? meanFreePath,
    final double? t60,
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
    save();
  }

  /// Stop the sound.
  void stop({required final bool destroyReverb}) {
    _playSound?.destroy();
    _playSound = null;
    if (destroyReverb) {
      channel.reverb = null;
      reverb?.destroy();
      reverb = null;
    }
  }

  /// Reset the reverb.
  void resetReverb() {
    channel.reverb = null;
    reverb?.destroy();
    reverb = widget.projectContext.game.createReverb(
      widget.reverbPresetReference.reverbPreset,
    );
    channel.reverb = reverb?.id;
  }

  /// Play the sound (if any).
  void play() {
    stop(destroyReverb: true);
    final sound = widget.reverbPresetReference.sound;
    if (sound != null) {
      resetReverb();
      final reference = widget.projectContext.worldContext.getCustomSound(
        sound,
      );
      _playSound = channel.playSound(
        reference,
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
    stop(destroyReverb: true);
    channel.destroy();
  }

  /// Get a list tile for the given setting.
  Shortcuts getSettingTile({
    required final BuildContext context,
    required final double value,
    required final ReverbSetting setting,
    required final ValueChanged<double> onDone,
  }) {
    final increaseAction = CallbackAction<IncreaseIntent>(
      onInvoke: (final intent) =>
          onDone(min(setting.max, value + setting.modify)),
    );
    final decreaseAction = CallbackAction<DecreaseIntent>(
      onInvoke: (final intent) =>
          onDone(max(setting.min, value - setting.modify)),
    );
    final valueString = value.toString();
    return Shortcuts(
      shortcuts: const {
        IncreaseIntent.hotkey: IncreaseIntent(),
        DecreaseIntent.hotkey: DecreaseIntent(),
      },
      child: Actions(
        actions: {
          IncreaseIntent: increaseAction,
          DecreaseIntent: decreaseAction,
        },
        child: ListTile(
          title: TextButton(
            child: Text('${setting.name}: $valueString'),
            onPressed: () => pushWidget(
              context: context,
              builder: (final context) => GetNumber(
                value: value,
                onDone: (final value) {
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
          subtitle: IconButton(
            icon: const Icon(Icons.restore_rounded),
            tooltip: 'Restore ${setting.name} to ${setting.defaultValue}',
            onPressed: () => onDone(setting.defaultValue),
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
