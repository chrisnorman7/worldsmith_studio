import 'package:flutter/material.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/play_sound_semantics.dart';
import 'edit_zone_object.dart';

/// A widget which shows a [zoneObject].
class ZoneObjectListTile extends StatefulWidget {
  /// Create an instance.
  const ZoneObjectListTile({
    required this.projectContext,
    required this.zone,
    required this.zoneObject,
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The zone where [zoneObject] is located.
  final Zone zone;

  /// THe zone object to edit.
  final ZoneObject zoneObject;

  /// Whether or not the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// Create state for this widget.
  @override
  _ZoneObjectListTileState createState() => _ZoneObjectListTileState();
}

/// State for [ZoneObjectListTile].
class _ZoneObjectListTileState extends State<ZoneObjectListTile> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
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
      child: Builder(
        builder: (context) => ListTile(
          autofocus: widget.autofocus,
          title: Text(widget.zoneObject.name),
          subtitle: Text('${coordinates.x}x ${coordinates.y}'),
          onTap: () async {
            PlaySoundSemantics.of(context)?.stop();
            await pushWidget(
              context: context,
              builder: (context) => EditZoneObject(
                projectContext: widget.projectContext,
                zone: widget.zone,
                zoneObject: widget.zoneObject,
              ),
            );
            setState(() {});
          },
        ),
      ),
      soundChannel: widget.projectContext.game.interfaceSounds,
      assetReference: assetReference?.reference,
      gain: sound?.gain ?? widget.projectContext.world.soundOptions.defaultGain,
      looping: true,
    );
  }
}
