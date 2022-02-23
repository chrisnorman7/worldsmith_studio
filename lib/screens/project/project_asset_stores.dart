import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../asset_store/asset_store_list_tile.dart';

/// A widget for showing asset stores.
class ProjectAssetStores extends StatefulWidget {
  /// Create an instance.
  const ProjectAssetStores({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _ProjectAssetStoresState createState() => _ProjectAssetStoresState();
}

/// State for [ProjectAssetStores].
class _ProjectAssetStoresState extends State<ProjectAssetStores> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    return ListView(
      children: [
        AssetStoreListTile(
          autofocus: true,
          afterOnTap: () => setState(() {}),
          assetStore: world.equipmentAssetStore,
          canDelete: (reference) => null,
          projectContext: widget.projectContext,
        ),
        AssetStoreListTile(
          afterOnTap: () => setState(() {}),
          assetStore: world.terrainAssetStore,
          canDelete: (reference) {
            final id = reference.variableName;
            for (final zone in world.zones) {
              if (zone.defaultTerrainId == id) {
                return 'This asset is used as the default terrain for the '
                    '${zone.name} zone.';
              }
            }
            for (final terrain in world.terrains) {
              if (terrain.fastWalk.sound.id == id) {
                return 'This asset is used by the ${terrain.name} fast walk.';
              } else if (terrain.slowWalk.sound.id == id) {
                return 'This asset is used by the ${terrain.name} slow walk.';
              }
            }
            return null;
          },
          projectContext: widget.projectContext,
        ),
        AssetStoreListTile(
          afterOnTap: () => setState(() {}),
          assetStore: world.musicAssetStore,
          canDelete: (reference) {
            final id = reference.variableName;
            if (world.mainMenuOptions.music?.id == id) {
              return 'You cannot delete the main music for the game.';
            }
            if (world.creditsMenuOptions.music?.id == id) {
              return 'You cannot delete the credits menu music.';
            }
            for (final zone in world.zones) {
              if (zone.music?.id == id) {
                return 'You cannot delete the music for the ${zone.name} zone.';
              }
            }
            return null;
          },
          projectContext: widget.projectContext,
        ),
        AssetStoreListTile(
          projectContext: widget.projectContext,
          assetStore: world.ambianceAssetStore,
          afterOnTap: () => setState(() {}),
          canDelete: (asset) {
            for (final zone in world.zones) {
              for (final object in zone.objects) {
                if (object.ambiance?.id == asset.variableName) {
                  return 'You cannot delete the ambiance for the '
                      '${object.name} object in the ${zone.name} zone.';
                }
              }
            }
            return null;
          },
        ),
        AssetStoreListTile(
          afterOnTap: () => setState(() {}),
          assetStore: world.interfaceSoundsAssetStore,
          canDelete: (reference) {
            final id = reference.variableName;
            if (world.soundOptions.menuActivateSound?.id == id) {
              return 'You cannot delete the menu activate sound.';
            }
            if (world.soundOptions.menuMoveSound?.id == id) {
              return 'You cannot delete the menu move sound.';
            }
            for (final reverb in world.reverbs) {
              if (reverb.sound?.id == id) {
                return 'You cannot delete the test sound for the '
                    '${reverb.reverbPreset.name} reverb.';
              }
            }
            return null;
          },
          projectContext: widget.projectContext,
        ),
        AssetStoreListTile(
          afterOnTap: () => setState(() {}),
          assetStore: world.creditsAssetStore,
          canDelete: (reference) {
            for (final credit in world.credits) {
              final id = reference.variableName;
              if (credit.sound?.id == id) {
                return 'You cannot delete the sound for the ${credit.title} '
                    'credit.';
              }
            }
            return null;
          },
          projectContext: widget.projectContext,
        ),
      ],
    );
  }
}
