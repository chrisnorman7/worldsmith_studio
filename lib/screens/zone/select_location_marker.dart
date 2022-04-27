// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/select_item.dart';

/// A widget for selecting a location marker.
class SelectLocationMarker extends StatelessWidget {
  /// Create an instance.
  const SelectLocationMarker({
    required this.projectContext,
    required this.locationMarkers,
    required this.onDone,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The location markers to choose from.
  final List<LocationMarker> locationMarkers;

  /// The function to call with the resulting marker.
  final ValueChanged<LocationMarker> onDone;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => SelectItem<LocationMarker>(
        onDone: onDone,
        values: locationMarkers,
        getItemWidget: (final value) {
          final text = value.name;
          final sound = value.sound;
          final asset = sound == null
              ? null
              : getAssetReferenceReference(
                  assets: projectContext.world.interfaceSoundsAssets,
                  id: sound.id,
                ).reference;
          return PlaySoundSemantics(
            child: Text(text ?? 'Untitled Location Marker'),
            soundChannel: projectContext.game.interfaceSounds,
            assetReference: asset,
            gain: sound?.gain ?? 0,
          );
        },
      );
}
