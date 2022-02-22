import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/custom_message/custom_message_list_tile.dart';
import '../../widgets/get_coordinates.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/number_list_tile.dart';
import '../../widgets/tabbed_scaffold.dart';
import '../../widgets/text_list_tile.dart';
import '../box/coordinates_list_tile.dart';
import '../box/edit_box.dart';
import '../box/select_box.dart';
import '../box/select_box_corner.dart';
import '../reverb/reverb_list_tile.dart';
import '../sound/sound_list_tile.dart';
import '../terrain/select_terrain.dart';
import '../terrain/terrain_list_tile.dart';

const _helpIntent = HelpIntent();
const _createBoxIntent = CreateBoxIntent();

/// A widget for editing its [zone].
class EditZone extends StatefulWidget {
  /// Create an instance.
  const EditZone({
    required this.projectContext,
    required this.zone,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The zone to edit.
  final Zone zone;

  /// Create state for this widget.
  @override
  _EditZoneState createState() => _EditZoneState();
}

/// State for [EditZone].
class _EditZoneState extends State<EditZone> {
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
    _currentBox = _level.getBox();
  }

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    return Cancel(
      child: TabbedScaffold(
        tabs: [
          TabbedScaffoldTab(
            title: 'Zone Settings',
            icon: const Icon(Icons.settings_display_outlined),
            builder: getSettingsListView,
            actions: [
              ElevatedButton(
                onPressed: () {
                  final id = widget.zone.id;
                  confirm(
                    context: context,
                    message: 'Are you sure you want to delete the '
                        '${widget.zone.name} zone?',
                    title: 'Confirm Delete',
                    yesCallback: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      world.zones.removeWhere((element) => element.id == id);
                      widget.projectContext.save();
                    },
                  );
                },
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
                  onPressed: Actions.handler<HelpIntent>(context, _helpIntent),
                  child: const Icon(
                    Icons.help_center_outlined,
                    semanticLabel: 'Keyboard Shortcuts',
                  ),
                )
              ],
            ),
          TabbedScaffoldTab(
            title: 'Boxes',
            icon: const Icon(Icons.map_outlined),
            builder: getBoxesListView,
          ),
        ],
      ),
    );
  }

  /// Save the project context, and call[setState].
  void save() {
    widget.projectContext.save();
    setState(() {});
  }

  /// Stop the music playing and dispose of the focus node..
  @override
  void dispose() {
    super.dispose();
    _level.onPop(0.5);
  }

  /// Get the zone settings list view.
  ListView getSettingsListView(BuildContext context) {
    final world = widget.projectContext.world;
    final music = widget.zone.music;
    return ListView(
      children: [
        TextListTile(
          value: widget.zone.name,
          onChanged: (value) {
            widget.zone.name = value;
            widget.projectContext.save();
            setState(() {});
          },
          header: 'Name',
          autofocus: true,
          validator: (value) => validateNonEmptyValue(value: value),
        ),
        SoundListTile(
          projectContext: widget.projectContext,
          value: music,
          onDone: (value) {
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
        ListTile(
          title: const Text('Default Terrain'),
          subtitle: Text(
            widget.projectContext.world
                .getTerrain(widget.zone.defaultTerrainId)
                .name,
          ),
          onTap: () => pushWidget(
            context: context,
            builder: (context) => SelectTerrain(
              onDone: (value) {
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
          onChanged: (value) {
            Navigator.pop(context);
            widget.zone.turnAmount = value.floor();
            save();
          },
          min: 1,
          max: 360,
          title: 'Turn Amount',
        ),
        CheckboxListTile(
          title: const Text('Top-down Map Visible'),
          value: widget.zone.topDownMap,
          onChanged: (value) {
            widget.zone.topDownMap = !widget.zone.topDownMap;
            widget.projectContext.save();
            setState(() {});
          },
        ),
        CustomMessageListTile(
          projectContext: widget.projectContext,
          customMessage: widget.zone.edgeMessage,
          title: 'Edge Of Zone Message',
        ),
      ],
    );
  }

  /// Get the boxes list view.
  Widget getBoxesListView(BuildContext context) {
    if (widget.zone.boxes.isEmpty) {
      return const CenterText(text: 'There are currently no boxes.');
    }
    final startCoordinates = <String, Point<int>>{};
    final endCoordinates = <String, Point<int>>{};
    final boxes = List<Box>.from(widget.zone.boxes, growable: false)
      ..sort(
        (a, b) {
          final aStart = startCoordinates[a.id] ??
              widget.zone.getAbsoluteCoordinates(a.start);
          startCoordinates[a.id] = aStart;
          final aEnd =
              endCoordinates[a.id] ?? widget.zone.getAbsoluteCoordinates(a.end);
          endCoordinates[a.id] = aEnd;
          final bStart = startCoordinates[b.id] ??
              widget.zone.getAbsoluteCoordinates(b.start);
          startCoordinates[b.id] = bStart;
          final bEnd =
              endCoordinates[b.id] ?? widget.zone.getAbsoluteCoordinates(b.end);
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
    return ListView.builder(
      itemBuilder: (context, index) {
        final box = boxes[index];
        final start = startCoordinates[box.id]!;
        final end = endCoordinates[box.id]!;
        return ListTile(
          autofocus: index == 0,
          title: Text(box.name),
          subtitle: Text('${start.x},${start.y} --- ${end.x},${end.y}'),
          onTap: () async {
            await pushWidget(
              context: context,
              builder: (context) => EditBox(
                projectContext: widget.projectContext,
                zone: widget.zone,
                box: box,
              ),
            );
            resetLevel();
            save();
          },
        );
      },
      itemCount: boxes.length,
    );
  }

  /// Get the WYSIWYG editor.
  Widget getCanvas(BuildContext context) {
    var x = _level.coordinates.x;
    var y = _level.coordinates.y;
    final moveAction = CallbackAction<MoveIntent>(
      onInvoke: (intent) {
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
      onInvoke: (intent) => switchBox(-1),
    );
    final nextBoxAction = CallbackAction<NextBoxIntent>(
      onInvoke: (intent) => switchBox(1),
    );
    final createBoxAction = CallbackAction<CreateBoxIntent>(
      onInvoke: (intent) => pushWidget(
        context: context,
        builder: (context) => SelectBox(
          boxes: widget.zone.boxes,
          onDone: (box) => pushWidget(
            context: context,
            builder: (context) => SelectBoxCorner(
              onDone: (corner) async {
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
                  builder: (context) => EditBox(
                    projectContext: widget.projectContext,
                    zone: widget.zone,
                    box: newBox,
                  ),
                );
                resetLevel();
                save();
              },
            ),
          ),
        ),
      ),
    );
    final box = _currentBox;
    return WithKeyboardShortcuts(
      child: Shortcuts(
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
                  builder: (context) => GetCoordinates(
                    value: Point(x.floor(), y.floor()),
                    onDone: (value) {
                      Navigator.pop(context);
                      _level.coordinates = Point(
                        value.x.toDouble(),
                        value.y.toDouble(),
                      );
                      setState(() {});
                    },
                    title: 'Focus Coordinates',
                    validator: (value) {
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
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.arrowUp, control: true):
              MoveIntent(
            MoveDirections.north,
          ),
          SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
              MoveIntent(
            MoveDirections.east,
          ),
          SingleActivator(LogicalKeyboardKey.arrowDown, control: true):
              MoveIntent(
            MoveDirections.south,
          ),
          SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
              MoveIntent(
            MoveDirections.west,
          ),
          CreateBoxIntent.hotkey: _createBoxIntent,
          PreviousBoxIntent.hotkey: PreviousBoxIntent(),
          NextBoxIntent.hotkey: NextBoxIntent(),
        },
      ),
      keyboardShortcuts: const [
        KeyboardShortcut(
            description: 'Create new box.', keyName: 'N', control: true),
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
    );
  }

  /// Get a list tile for the given [box].
  List<Widget> getBoxListTiles({
    required BuildContext context,
    required Box? box,
  }) {
    if (box == null) {
      return [
        ListTile(
          title: const Text('There is no box at these coordinates.'),
          onTap: () {},
        ),
      ];
    }
    final world = widget.projectContext.world;
    return [
      TextListTile(
        value: box.name,
        onChanged: (value) {
          box.name = value;
          save();
        },
        header: 'Box Name',
        labelText: 'Name',
        validator: (value) => validateNonEmptyValue(value: value),
      ),
      CoordinatesListTile(
        projectContext: widget.projectContext,
        zone: widget.zone,
        box: box,
        value: box.start,
        onChanged: () => setState(resetLevel),
        title: 'Start Coordinates',
      ),
      CoordinatesListTile(
        projectContext: widget.projectContext,
        zone: widget.zone,
        box: box,
        value: box.end,
        onChanged: () => setState(resetLevel),
        title: 'End Coordinates',
      ),
      TerrainListTile(
        onDone: (value) {
          Navigator.pop(context);
          box.terrainId = value.id;
          save();
        },
        terrains: world.terrains,
        currentTerrainId: box.terrainId,
      ),
      ReverbListTile(
        projectContext: widget.projectContext,
        onDone: (value) {
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
        onChanged: (value) {
          box.enclosed = value == null;
          save();
        },
        title: const Text('Soundproof Box'),
      ),
      CustomMessageListTile(
        projectContext: widget.projectContext,
        customMessage: box.enterMessage,
        title: 'Enter Message',
      ),
      CustomMessageListTile(
        projectContext: widget.projectContext,
        customMessage: box.leaveMessage,
        title: 'Leave Message',
      ),
    ];
  }

  /// Recreate the zone level.
  void resetLevel() {
    final coordinates = _level.coordinates;
    _level.onPop(null);
    _level = ZoneLevel(
      worldContext: widget.projectContext.worldContext,
      zone: widget.zone,
    )..onPush();
    final size = _level.size;
    _level.coordinates = Point(
      min(coordinates.x, size.x - 1).toDouble(),
      min(coordinates.y, size.y - 1).toDouble(),
    );
  }

  /// Switch boxes.
  void switchBox(int direction) {
    final box = _currentBox;
    int index;
    if (box == null) {
      index = 0;
    } else {
      index = widget.zone.boxes.indexWhere((element) => element.id == box.id);
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
}
