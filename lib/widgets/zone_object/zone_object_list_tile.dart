import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../screens/zone_object/edit_zone_object.dart';
import '../../util.dart';
import '../play_sound_semantics.dart';

/// A widget which shows a [zoneObject].
class ZoneObjectListTile extends StatefulWidget {
  /// Create an instance.
  const ZoneObjectListTile({
    required this.projectContext,
    required this.zone,
    required this.zoneObject,
    required this.onDone,
    this.autofocus = false,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The zone where [zoneObject] is located.
  final Zone zone;

  /// THe zone object to edit.
  final ZoneObject zoneObject;

  /// The function to call when editing is complete.
  final VoidCallback onDone;

  /// Whether or not the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Create state for this widget.
  @override
  ZoneObjectListTileState createState() => ZoneObjectListTileState();
}

/// State for [ZoneObjectListTile].
class ZoneObjectListTileState extends State<ZoneObjectListTile> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final coordinates = widget.zone.getAbsoluteCoordinates(
      widget.zoneObject.initialCoordinates,
    );
    final sound = widget.zoneObject.ambiance;
    final assetReference = sound == null
        ? null
        : getAssetReferenceReference(
            assets: widget.projectContext.world.ambianceAssets,
            id: sound.id,
          );
    return PlaySoundSemantics(
      soundChannel: widget.projectContext.game.interfaceSounds,
      assetReference: assetReference?.reference,
      gain: sound?.gain ?? widget.projectContext.world.soundOptions.defaultGain,
      looping: true,
      child: Builder(
        builder: (final context) => ListTile(
          autofocus: widget.autofocus,
          title: Text(widget.zoneObject.name),
          subtitle: Text('${coordinates.x}, ${coordinates.y}'),
          onTap: () async {
            PlaySoundSemantics.of(context)?.stop();
            await pushWidget(
              context: context,
              builder: (final context) => EditZoneObject(
                projectContext: widget.projectContext,
                zone: widget.zone,
                zoneObject: widget.zoneObject,
                onDone: widget.onDone,
              ),
            );
            widget.onDone();
            setState(() {});
          },
        ),
      ),
    );
  }
}
