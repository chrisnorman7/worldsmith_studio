import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/box/coordinates_list_tile.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/command/call_command_list_tile.dart';
import '../../widgets/get_coordinates.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/number_list_tile.dart';
import '../../widgets/play_sound_semantics.dart';
import '../../widgets/push_widget_list_tile.dart';
import '../../widgets/reverb/reverb_list_tile.dart';
import '../../widgets/searchable_list_view.dart';
import '../../widgets/select_item.dart';
import '../../widgets/sound/fade_time_list_tile.dart';
import '../../widgets/sound/gain_list_tile.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/tabbed_scaffold.dart';
import '../../widgets/terrain/terrain_list_tile.dart';
import '../../widgets/text_list_tile.dart';
import '../../widgets/zone_object/zone_object_list_tile.dart';
import '../ambiance/edit_ambiances.dart';
import '../box/edit_box.dart';
import '../box/select_box.dart';
import '../box/select_box_corner.dart';
import '../npc/edit_zone_npc.dart';
import '../terrain/select_terrain.dart';
import '../zone_object/edit_zone_object.dart';
import 'edit_location_marker.dart';

const _helpIntent = HelpIntent();
const _createBoxIntent = CreateBoxIntent();
const _createZoneObjectIntent = CreateZoneObjectIntent();

/// A widget for editing its [zone].
class EditZone extends StatefulWidget {
  /// Create an instance.
  const EditZone({
    required this.projectContext,
    required this.zone,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The zone to edit.
  final Zone zone;

  /// Create state for this widget.
  @override
  EditZoneState createState() => EditZoneState();
}

/// State for [EditZone].
class EditZoneState extends State<EditZone> {
  late ZoneLevel _level;
  Box? _currentBox;

  /// Initialise stuff.
  @override
  void initState() {
    super.initState();
    if (widget.zone.boxes.isEmpty) {
      widget.zone.boxes.add(
        Box(
          id: newId(),
          name: 'First Box',
          start: Coordinates(0, 0),
          end: Coordinates(10, 10),
          terrainId: widget.projectContext.world.terrains.first.id,
        ),
      );
      widget.projectContext.save();
    }
    _level = ZoneLevel(
      worldContext: widget.projectContext.worldContext,
      zone: widget.zone,
    )..onPush();
    _level.currentWalkingOptions = _level.currentTerrain.fastWalk;
    _currentBox = _level.getBox();
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) => Cancel(
        child: TabbedScaffold(
          tabs: [
            TabbedScaffoldTab(
              title: 'Zone Settings',
              icon: const Icon(Icons.settings_display_outlined),
              builder: getSettingsListView,
              actions: [
                ElevatedButton(
                  onPressed: () => deleteZone(context),
                  child: deleteIcon,
                )
              ],
            ),
            if (widget.zone.boxes.isNotEmpty)
              TabbedScaffoldTab(
                title: 'Canvas',
                icon: const Icon(Icons.brush_outlined),
                builder: getCanvas,
                actions: [
                  ElevatedButton(
                    onPressed:
                        Actions.handler<HelpIntent>(context, _helpIntent),
                    child: const Icon(
                      Icons.help_center_outlined,
                      semanticLabel: 'Keyboard Shortcuts',
                    ),
                  )
                ],
              ),
            TabbedScaffoldTab(
              title: 'Objects',
              icon: const Icon(Icons.local_post_office_outlined),
              builder: getObjectsListView,
              floatingActionButton: FloatingActionButton(
                onPressed: () => createZoneObject(context),
                autofocus: widget.zone.objects.isEmpty,
                tooltip: 'Add Object',
                child: createIcon,
              ),
            ),
            TabbedScaffoldTab(
              title: "NPC's",
              icon: const Icon(Icons.people_alt_outlined),
              builder: getNpcList,
              floatingActionButton: FloatingActionButton(
                autofocus: widget.zone.npcs.isEmpty,
                child: createIcon,
                onPressed: () {
                  final npcs = widget.projectContext.world.npcs;
                  if (npcs.isEmpty) {
                    showError(
                      context: context,
                      message: "There are no NPC's you can add to this zone.",
                    );
                  } else {
                    final availableNpcs = npcs
                        .where(
                          (final npc) => widget.zone.npcs
                              .where(
                                (final zoneNpc) => zoneNpc.npcId == npc.id,
                              )
                              .isEmpty,
                        )
                        .toList();
                    if (availableNpcs.isEmpty) {
                      showError(
                        context: context,
                        message: "There are no NPC's to add.",
                      );
                    } else {
                      pushWidget(
                        context: context,
                        builder: (final context) => SelectItem<Npc>(
                          onDone: (final value) {
                            Navigator.pop(context);
                            final zoneNpc = ZoneNpc(
                              npcId: value.id,
                              initialCoordinates: Coordinates(0, 0),
                            );
                            widget.zone.npcs.add(zoneNpc);
                            widget.projectContext.save();
                          },
                          values: availableNpcs,
                          getItemWidget: (final npc) => Text(npc.name),
                          title: 'Select NPC',
                        ),
                      );
                    }
                  }
                },
                tooltip: 'Select NPC',
              ),
            ),
            TabbedScaffoldTab(
              title: 'Boxes',
              icon: const Icon(Icons.map_outlined),
              builder: getBoxesListView,
            ),
            TabbedScaffoldTab(
              title: 'Location Markers',
              icon: const Icon(Icons.location_pin),
              builder: (final context) => CallbackShortcuts(
                bindings: {
                  CreateProjectIntent.hotkey: () => addLocationMarker(context)
                },
                child: getLocationMarkersList(context),
              ),
              floatingActionButton: FloatingActionButton(
                autofocus: widget.zone.locationMarkers.isEmpty,
                onPressed: () => addLocationMarker(context),
                tooltip: 'Add Location Marker',
                child: createIcon,
              ),
            )
          ],
        ),
      );

  /// Save the project context, and call[setState].
  void save() {
    widget.projectContext.save();
    setState(() {});
    resetLevel();
  }

  /// Stop the music playing and dispose of the focus node..
  @override
  void dispose() {
    super.dispose();
    _level.onPop(0.5);
  }

  /// Get the zone settings list view.
  ListView getSettingsListView(final BuildContext context) {
    final world = widget.projectContext.world;
    final music = widget.zone.music;
    return ListView(
      children: [
        TextListTile(
          value: widget.zone.name,
          onChanged: (final value) {
            widget.zone.name = value;
            widget.projectContext.save();
            setState(() {});
          },
          header: 'Name',
          autofocus: true,
          validator: (final value) => validateNonEmptyValue(value: value),
        ),
        SoundListTile(
          projectContext: widget.projectContext,
          value: music,
          onDone: (final value) {
            widget.zone.music = value;
            widget.projectContext.save();
            setState(() {});
          },
          assetStore: world.musicAssetStore,
          defaultGain: world.soundOptions.defaultGain,
          looping: true,
          nullable: true,
          title: 'Zone Music',
          playSound: false,
        ),
        FadeTimeListTile(
          value: widget.zone.musicFadeTime,
          onChanged: (final value) {
            widget.zone.musicFadeTime = value;
            save();
          },
          title: 'Music Fade Time',
        ),
        GainListTile(
          gain: widget.zone.musicFadeGain,
          onChange: (final value) {
            widget.projectContext.playActivateSound(gain: value);
            widget.zone.musicFadeGain = value;
            save();
          },
          title: 'Minimum Music Gain',
        ),
        ListTile(
          title: const Text('Ambiances'),
          subtitle: Text(widget.zone.ambiances.length.toString()),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (final context) => EditAmbiances(
                projectContext: widget.projectContext,
                ambiances: widget.zone.ambiances,
                title: 'Zone Ambiances',
              ),
            );
            setState(resetLevel);
          },
        ),
        FadeTimeListTile(
          value: widget.zone.ambianceFadeTime,
          onChanged: (final value) {
            widget.zone.ambianceFadeTime = value;
            save();
          },
          title: 'Ambiance Fade Time',
        ),
        GainListTile(
          gain: widget.zone.ambianceFadeGain,
          onChange: (final value) {
            widget.projectContext.playActivateSound(gain: value);
            widget.zone.ambianceFadeGain = value;
            save();
          },
          title: 'Minimum Ambiance Gain',
        ),
        ListTile(
          title: const Text('Default Terrain'),
          subtitle: Text(
            widget.projectContext.world
                .getTerrain(widget.zone.defaultTerrainId)
                .name,
          ),
          onTap: () => pushWidget(
            context: context,
            builder: (final context) => SelectTerrain(
              onDone: (final value) {
                Navigator.pop(context);
                widget.zone.defaultTerrainId = value.id;
                widget.projectContext.save();
                setState(() {});
              },
              currentTerrainId: widget.zone.defaultTerrainId,
              title: 'Default Terrain',
              terrains: widget.projectContext.world.terrains,
            ),
          ),
        ),
        NumberListTile(
          value: widget.zone.turnAmount.toDouble(),
          onChanged: (final value) {
            Navigator.pop(context);
            widget.zone.turnAmount = value.floor();
            save();
          },
          min: 1,
          max: 360,
          title: 'Turn Amount',
        ),
        CheckboxListTile(
          title: Text(
            widget.zone.topDownMap
                ? 'Disable Top-Down Map'
                : 'Enable Top-Down Map',
          ),
          value: widget.zone.topDownMap,
          onChanged: (final value) {
            widget.zone.topDownMap = !widget.zone.topDownMap;
            widget.projectContext.save();
            setState(() {});
          },
        ),
        CallCommandListTile(
          projectContext: widget.projectContext,
          callCommand: widget.zone.edgeCommand,
          onChanged: (final value) {
            widget.zone.edgeCommand = value;
            save();
          },
          title: 'Edge Command',
        )
      ],
    );
  }

  /// Get the boxes list view.
  Widget getBoxesListView(final BuildContext context) {
    if (widget.zone.boxes.isEmpty) {
      return const CenterText(text: 'There are currently no boxes.');
    }
    final startCoordinates = <String, Point<int>>{};
    final endCoordinates = <String, Point<int>>{};
    final List<Box> boxes;
    if (widget.zone.boxes.length == 1) {
      final box = widget.zone.boxes.first;
      boxes = [box];
      startCoordinates[box.id] = widget.zone.getAbsoluteCoordinates(box.start);
      endCoordinates[box.id] = widget.zone.getAbsoluteCoordinates(box.end);
    } else {
      boxes = List<Box>.from(widget.zone.boxes, growable: false)
        ..sort(
          (final a, final b) {
            final aStart = startCoordinates[a.id] ??
                widget.zone.getAbsoluteCoordinates(a.start);
            startCoordinates[a.id] = aStart;
            final aEnd = endCoordinates[a.id] ??
                widget.zone.getAbsoluteCoordinates(a.end);
            endCoordinates[a.id] = aEnd;
            final bStart = startCoordinates[b.id] ??
                widget.zone.getAbsoluteCoordinates(b.start);
            startCoordinates[b.id] = bStart;
            final bEnd = endCoordinates[b.id] ??
                widget.zone.getAbsoluteCoordinates(b.end);
            endCoordinates[b.id] = bEnd;
            if (aStart.x == bStart.x) {
              if (aStart.y == bStart.y) {
                if (aEnd.x == bEnd.x) {
                  if (aEnd.y == bEnd.y) {
                    return 0;
                  }
                  return aEnd.y.compareTo(bEnd.y);
                }
                return aEnd.x.compareTo(bEnd.x);
              }
              return aStart.y.compareTo(bStart.y);
            }
            return aStart.x.compareTo(bStart.x);
          },
        );
    }
    final children = <SearchableListTile>[];
    for (var i = 0; i < boxes.length; i++) {
      final box = boxes[i];
      final start = startCoordinates[box.id]!;
      final end = endCoordinates[box.id]!;
      children.add(
        SearchableListTile(
          searchString: box.name,
          child: ListTile(
            autofocus: i == 0,
            title: Text(box.name),
            subtitle: Text('${start.x},${start.y} --- ${end.x},${end.y}'),
            onTap: () async {
              await pushWidget(
                context: context,
                builder: (final context) => EditBox(
                  projectContext: widget.projectContext,
                  zone: widget.zone,
                  box: box,
                  onDone: save,
                ),
              );
              save();
            },
          ),
        ),
      );
    }
    return SearchableListView(children: children);
  }

  /// Get the WYSIWYG editor.
  Widget getCanvas(final BuildContext context) {
    var x = _level.coordinates.x;
    var y = _level.coordinates.y;
    final moveAction = CallbackAction<MoveIntent>(
      onInvoke: (final intent) {
        switch (intent.direction) {
          case MoveDirections.north:
            y++;
            break;
          case MoveDirections.east:
            x++;
            break;
          case MoveDirections.south:
            y--;
            break;
          case MoveDirections.west:
            x--;
            break;
        }
        _currentBox = _level.moveTo(
          destination: Point(x, y),
          updateLastWalked: false,
        );
        setState(() {});
        return null;
      },
    );
    final previousBoxAction = CallbackAction<PreviousBoxIntent>(
      onInvoke: (final intent) => switchBox(-1),
    );
    final nextBoxAction = CallbackAction<NextBoxIntent>(
      onInvoke: (final intent) => switchBox(1),
    );
    final createBoxAction = CallbackAction<CreateBoxIntent>(
      onInvoke: (final intent) => pushWidget(
        context: context,
        builder: (final context) => SelectBox(
          zone: widget.zone,
          onDone: (final box) => pushWidget(
            context: context,
            builder: (final context) => SelectBoxCorner(
              onDone: (final corner) async {
                Navigator.pop(context);
                Navigator.pop(context);
                final clamp = CoordinateClamp(boxId: box.id, corner: corner);
                final start = Coordinates(0, 0, clamp: clamp);
                final end = Coordinates(0, 0, clamp: clamp);
                final newBox = Box(
                  id: newId(),
                  name: 'Untitled Box',
                  start: start,
                  end: end,
                  terrainId: widget.projectContext.world.terrains.first.id,
                );
                widget.zone.boxes.add(newBox);
                await pushWidget(
                  context: context,
                  builder: (final context) => EditBox(
                    projectContext: widget.projectContext,
                    zone: widget.zone,
                    box: newBox,
                    onDone: save,
                  ),
                );
                save();
              },
            ),
          ),
        ),
      ),
    );
    final box = _currentBox;
    return WithKeyboardShortcuts(
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Create new box.',
          keyName: 'N',
          control: true,
        ),
        KeyboardShortcut(
          description: 'Move north, east, south, or west.',
          keyName: 'Arrow keys',
          control: true,
        ),
        KeyboardShortcut(
          description: 'Increase and decrease x coordinate.',
          keyName: 'Left and Right Arrows',
          alt: true,
        ),
        KeyboardShortcut(
          description: 'Increase and decrease y coordinate.',
          keyName: 'Up or Down Arrows',
          alt: true,
        ),
        KeyboardShortcut(
          description: 'Move to the previous box.',
          keyName: 'comma (,)',
          control: true,
        ),
        KeyboardShortcut(
          description: 'Move to the next box.',
          keyName: 'Period (.)',
          control: true,
        ),
        KeyboardShortcut(
          description: 'Show keyboard shortcuts.',
          keyName: 'slash (/)',
          control: true,
        ),
      ],
      child: Shortcuts(
        shortcuts: {
          SingleActivator(
            LogicalKeyboardKey.arrowUp,
            control: !Platform.isMacOS,
            meta: Platform.isMacOS,
          ): const MoveIntent(
            MoveDirections.north,
          ),
          SingleActivator(
            LogicalKeyboardKey.arrowRight,
            control: !Platform.isMacOS,
            meta: Platform.isMacOS,
          ): const MoveIntent(
            MoveDirections.east,
          ),
          SingleActivator(
            LogicalKeyboardKey.arrowDown,
            control: !Platform.isMacOS,
            meta: Platform.isMacOS,
          ): const MoveIntent(
            MoveDirections.south,
          ),
          SingleActivator(
            LogicalKeyboardKey.arrowLeft,
            control: !Platform.isMacOS,
            meta: Platform.isMacOS,
          ): const MoveIntent(
            MoveDirections.west,
          ),
          CreateBoxIntent.hotkey: _createBoxIntent,
          PreviousBoxIntent.hotkey: const PreviousBoxIntent(),
          NextBoxIntent.hotkey: const NextBoxIntent(),
        },
        child: Actions(
          actions: {
            MoveIntent: moveAction,
            CreateBoxIntent: createBoxAction,
            PreviousBoxIntent: previousBoxAction,
            NextBoxIntent: nextBoxAction,
          },
          child: ListView(
            children: [
              ListTile(
                autofocus: true,
                title: const Text('Coordinates'),
                subtitle: Text('${x.floor()}, ${y.floor()}'),
                onTap: () => pushWidget(
                  context: context,
                  builder: (final context) => GetCoordinates(
                    value: Point(x.floor(), y.floor()),
                    onDone: (final value) {
                      Navigator.pop(context);
                      _level.coordinates = Point(
                        value.x.toDouble(),
                        value.y.toDouble(),
                      );
                      setState(() {});
                    },
                    title: 'Focus Coordinates',
                    validator: (final value) {
                      if (value == null) {
                        return 'You must provide a value.';
                      }
                      final size = _level.size;
                      if (value.x >= size.x) {
                        return 'x coordinate too high.';
                      } else if (value.y >= size.y) {
                        return 'y coordinate too high.';
                      } else if (value.x < 0) {
                        return 'x coordinate too low';
                      } else if (value.y < 0) {
                        return 'y coordinate too low.';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              ...getBoxListTiles(context: context, box: box)
            ],
          ),
        ),
      ),
    );
  }

  /// Get a list tile for the given [box].
  List<Widget> getBoxListTiles({
    required final BuildContext context,
    required final Box? box,
  }) {
    if (box == null) {
      return [
        ListTile(
          title: const Text('There is no box at these coordinates.'),
          onTap: () => switchBox(1),
        ),
      ];
    }
    final world = widget.projectContext.world;
    return [
      TextListTile(
        value: box.name,
        onChanged: (final value) {
          box.name = value;
          save();
        },
        header: 'Box Name',
        labelText: 'Name',
        validator: (final value) => validateNonEmptyValue(value: value),
      ),
      CoordinatesListTile(
        projectContext: widget.projectContext,
        zone: widget.zone,
        box: box,
        value: box.start,
        onChanged: () => save,
        title: 'Start Coordinates',
      ),
      CoordinatesListTile(
        projectContext: widget.projectContext,
        zone: widget.zone,
        box: box,
        value: box.end,
        onChanged: save,
        title: 'End Coordinates',
      ),
      TerrainListTile(
        projectContext: widget.projectContext,
        onDone: (final value) {
          Navigator.pop(context);
          box.terrainId = value.id;
          save();
        },
        terrains: world.terrains,
        currentTerrainId: box.terrainId,
      ),
      ReverbListTile(
        projectContext: widget.projectContext,
        onDone: (final value) {
          Navigator.pop(context);
          box.reverbId = value?.id;
          save();
        },
        reverbPresets: world.reverbs,
        currentReverbId: box.reverbId,
        nullable: true,
      ),
      CheckboxListTile(
        value: box.enclosed,
        onChanged: (final value) {
          box.enclosed = value == null;
          save();
        },
        title: const Text('Soundproof Box'),
      ),
    ];
  }

  /// Create a new object.
  Future<void> createZoneObject(final BuildContext context) async {
    final object = ZoneObject(id: newId(), name: 'Untitled Object');
    widget.zone.objects.add(object);
    widget.projectContext.save();
    await pushWidget(
      context: context,
      builder: (final context) => EditZoneObject(
        projectContext: widget.projectContext,
        zone: widget.zone,
        zoneObject: object,
        onDone: () => setState(() {}),
      ),
    );
    setState(() {});
    return;
  }

  /// Get the list of objects.
  Widget getObjectsListView(final BuildContext context) {
    final createZoneObjectAction = CallbackAction<CreateZoneObjectIntent>(
      onInvoke: (final intent) => createZoneObject(context),
    );
    final objects = widget.zone.objects;
    final Widget child;
    if (objects.isEmpty) {
      child = const CenterText(text: 'There are no objects in this zone.');
    } else {
      final children = <SearchableListTile>[];
      for (var i = 0; i < objects.length; i++) {
        final object = objects[i];
        children.add(
          SearchableListTile(
            searchString: object.name,
            child: ZoneObjectListTile(
              projectContext: widget.projectContext,
              zone: widget.zone,
              zoneObject: object,
              onDone: () => setState(resetLevel),
              autofocus: i == 0,
            ),
          ),
        );
      }
      child = SearchableListView(children: children);
    }
    return Shortcuts(
      shortcuts: {CreateZoneObjectIntent.hotkey: _createZoneObjectIntent},
      child: Actions(
        actions: {CreateZoneObjectIntent: createZoneObjectAction},
        child: child,
      ),
    );
  }

  /// Recreate the zone level.
  void resetLevel() {
    final coordinates = _level.coordinates;
    _level.onPop(null);
    _level = ZoneLevel(
      worldContext: widget.projectContext.worldContext,
      zone: widget.zone,
    )..onPush();
    _level.currentWalkingOptions = _level.currentTerrain.fastWalk;
    final size = _level.size;
    _level.coordinates = Point(
      min(coordinates.x, size.x - 1).toDouble(),
      min(coordinates.y, size.y - 1).toDouble(),
    );
  }

  /// Switch boxes.
  void switchBox(final int direction) {
    final box = _currentBox;
    int index;
    if (box == null) {
      index = 0;
    } else {
      index =
          widget.zone.boxes.indexWhere((final element) => element.id == box.id);
    }
    index++;
    if (index >= widget.zone.boxes.length) {
      index = 0;
    }
    final newBox = widget.zone.boxes[index];
    final coordinates = widget.zone.getAbsoluteCoordinates(newBox.start);
    _currentBox = _level.moveTo(
      destination: Point(coordinates.x.toDouble(), coordinates.y.toDouble()),
    );
    setState(() {});
  }

  /// Delete the current zone.
  void deleteZone(final BuildContext context) {
    final world = widget.projectContext.world;
    final id = widget.zone.id;
    for (final category in world.commandCategories) {
      for (final command in category.commands) {
        if (command.zoneTeleport?.zoneId == id) {
          return showError(
            context: context,
            message: 'You cannot delete the target zone of the ${command.name} '
                'command from the ${category.name} category.',
          );
        }
      }
    }
    confirm(
      context: context,
      message: 'Are you sure you want to delete the ${widget.zone.name} zone?',
      title: 'Confirm Delete',
      yesCallback: () {
        Navigator.pop(context);
        Navigator.pop(context);
        world.zones.removeWhere((final element) => element.id == id);
        widget.projectContext.save();
      },
    );
  }

  /// Create a new location marker.
  Future<void> addLocationMarker(final BuildContext context) async {
    final marker = LocationMarker(
      id: newId(),
      message: CustomMessage(text: 'Untitled Marker'),
      coordinates: Coordinates(0, 0),
    );
    widget.zone.locationMarkers.add(marker);
    widget.projectContext.save();
    await pushWidget(
      context: context,
      builder: (final context) => EditLocationMarker(
        projectContext: widget.projectContext,
        zone: widget.zone,
        locationMarker: marker,
      ),
    );
    save();
  }

  /// Get the list of location markers for the current zone.
  Widget getLocationMarkersList(final BuildContext context) {
    final markers = widget.zone.locationMarkers;
    if (markers.isEmpty) {
      return const CenterText(text: 'There are no location markers.');
    }
    final children = <SearchableListTile>[];
    for (var i = 0; i < markers.length; i++) {
      final marker = markers[i];
      final message = marker.message;
      final sound = message.sound;
      final assetReference = sound == null
          ? null
          : widget.projectContext.worldContext.getCustomSound(sound);
      final coordinates = widget.zone.getAbsoluteCoordinates(
        marker.coordinates,
      );
      children.add(
        SearchableListTile(
          searchString: marker.message.text ?? '',
          child: PlaySoundSemantics(
            soundChannel: widget.projectContext.game.interfaceSounds,
            assetReference: assetReference,
            child: ListTile(
              autofocus: i == 0,
              title: Text(message.text ?? 'Untitled Marker'),
              subtitle: Text('${coordinates.x},${coordinates.y}'),
              onTap: () async {
                await pushWidget(
                  context: context,
                  builder: (final context) => EditLocationMarker(
                    projectContext: widget.projectContext,
                    zone: widget.zone,
                    locationMarker: marker,
                  ),
                );
                save();
              },
            ),
          ),
        ),
      );
    }
    return SearchableListView(children: children);
  }

  /// Get the NPC list for the current zone.
  Widget getNpcList(final BuildContext context) {
    final npcs = widget.zone.npcs;
    if (npcs.isEmpty) {
      return const CenterText(text: "No NPC's have been added to this zone.");
    }
    return BuiltSearchableListView(
      items: npcs,
      builder: (final context, final index) {
        final zoneNpc = npcs[index];
        final npcId = zoneNpc.npcId;
        final npc = widget.projectContext.world.getNpc(npcId);
        return SearchableListTile(
          searchString: npc.name,
          child: PushWidgetListTile(
            title: npc.name,
            builder: (final context) => EditZoneNpc(
              projectContext: widget.projectContext,
              zone: widget.zone,
              zoneNpc: zoneNpc,
            ),
            autofocus: index == 0,
            onSetState: resetLevel,
          ),
        );
      },
    );
  }
}
