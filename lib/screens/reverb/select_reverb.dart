// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/sound.dart';

import '../../project_context.dart';
import '../../widgets/cancel.dart';

/// A widget for selecting from a list of [reverbPresets].
class SelectReverb extends StatefulWidget {
  /// Create an instance.
  const SelectReverb({
    required this.projectContext,
    required this.onDone,
    required this.reverbPresets,
    this.currentReverbId,
    this.nullable = false,
    this.title = 'Select Reverb Preset',
    this.actions = const [],
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The function to be called with the new value.
  final ValueChanged<ReverbPresetReference?> onDone;

  /// The list of presets to use.
  final List<ReverbPresetReference> reverbPresets;

  /// The ID of the current preset.
  final String? currentReverbId;

  /// Whether or not the new preset can be `null`.
  final bool nullable;

  /// The title of the resulting [AppBar].
  final String title;

  /// The actions to apply to the resulting [AppBar].
  final List<Widget> actions;

  @override
  State<SelectReverb> createState() => _SelectReverbState();
}

class _SelectReverbState extends State<SelectReverb> {
  PlaySound? _playSound;
  SoundChannel? _channel;
  late final Map<String, CreateReverb> _reverbs;

  @override
  void initState() {
    super.initState();
    _reverbs = {};
  }

  @override
  Widget build(final BuildContext context) {
    final children = <Widget>[];
    if (widget.nullable) {
      children.add(
        ListTile(
          autofocus: widget.currentReverbId == null,
          title: const Text('Clear Reverb'),
          onTap: () => widget.onDone(null),
        ),
      );
    }
    for (var i = 0; i < widget.reverbPresets.length; i++) {
      final reverbPreset = widget.reverbPresets[i];
      final select = reverbPreset.id == widget.currentReverbId;
      final sound = reverbPreset.sound;
      children.add(
        Semantics(
          onDidGainAccessibilityFocus: sound == null
              ? null
              : () {
                  var reverb = _reverbs[reverbPreset.id];
                  if (reverb == null) {
                    reverb = widget.projectContext.game.createReverb(
                      reverbPreset.reverbPreset,
                    );
                    _reverbs[reverbPreset.id] = reverb;
                  }
                  var channel = _channel;
                  if (channel == null) {
                    channel = widget.projectContext.game.createSoundChannel(
                      reverb: reverb,
                    );
                    _channel = channel;
                  } else {
                    channel.reverb = reverb.id;
                  }
                  stopSound();
                  final assetReference = getAssetReferenceReference(
                    assets: widget.projectContext.world.interfaceSoundsAssets,
                    id: sound.id,
                  ).reference;
                  _playSound = channel.playSound(
                    assetReference,
                    gain: sound.gain,
                    keepAlive: true,
                  );
                },
          onDidLoseAccessibilityFocus: stopSound,
          child: ListTile(
            autofocus: widget.currentReverbId == null ? i == 0 : select,
            title: Text(reverbPreset.reverbPreset.name),
            selected: select,
            onTap: () => widget.onDone(reverbPreset),
          ),
        ),
      );
    }
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: widget.actions,
          title: Text(widget.title),
        ),
        body: ListView.builder(
          itemBuilder: (final context, final index) => children[index],
          itemCount: children.length,
        ),
      ),
    );
  }

  /// Stop the playing sound.
  void stopSound() {
    _playSound?.destroy();
    _playSound = null;
  }

  /// Destroy everything.
  @override
  void dispose() {
    super.dispose();
    stopSound();
    while (_reverbs.isNotEmpty) {
      _reverbs.remove(_reverbs.keys.first)!.destroy();
    }
    _channel?.destroy();
    _channel = null;
  }
}
