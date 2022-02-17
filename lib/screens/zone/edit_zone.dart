import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:worldsmith/util.dart';
import 'package:worldsmith/worldsmith.dart';
import 'package:ziggurat/ziggurat.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/center_text.dart';
import '../../widgets/get_coordinates.dart';
import '../../widgets/keyboard_shortcuts_list.dart';
import '../../widgets/tabbed_scaffold.dart';
import '../../widgets/text_list_tile.dart';
import '../sound/music_player.dart';
import '../sound/sound_list_tile.dart';
import '../terrain/select_terrain.dart';

const _helpIntent = HelpIntent();

/// The keyboard shortcuts for the canvas view.
const canvasKeyboardShortcuts = [
  KeyboardShortcut(
    description: 'Show keyboard shortcuts',
    keyName: 'slash (/)',
    control: true,
  ),
  KeyboardShortcut(
    description: 'Move around in the level',
    keyName: 'Arrow keys',
    control: true,
  )
];

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
  MusicPlayer? _musicPlayer;
  late FocusNode _focusNode;
  late ZoneLevel _level;

  /// Initialise stuff.
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
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
    );
  }

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final musicPlayer = _musicPlayer;
    final music = widget.zone.music;
    if (music == null) {
      _musicPlayer?.stop();
      _musicPlayer = null;
    } else {
      final assetReference = widget.projectContext.getRelativeAssetReference(
        getAssetReferenceReference(
          assets: world.musicAssets,
          id: music.id,
        )!
            .reference,
      );
      if (musicPlayer == null) {
        _musicPlayer = MusicPlayer(
          channel: widget.projectContext.game.ambianceSounds,
          assetReference: assetReference,
          gain: music.gain,
          fadeBuilder: () => 0.5,
        )..play();
      } else {
        musicPlayer
          ..assetReference = assetReference
          ..gain = music.gain;
      }
    }
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

  /// Stop the music playing and dispose of the focus node..
  @override
  void dispose() {
    super.dispose();
    _musicPlayer?.stop();
    _musicPlayer = null;
    _focusNode.dispose();
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
        CheckboxListTile(
          title: const Text('Top-down Map Visible'),
          value: widget.zone.topDownMap,
          onChanged: (value) {
            widget.zone.topDownMap = !widget.zone.topDownMap;
            widget.projectContext.save();
            setState(() {});
          },
        ),
      ],
    );
  }

  /// Get the boxes list view.
  Widget getBoxesListView(BuildContext context) {
    if (widget.zone.boxes.isEmpty) {
      return const CenterText(text: 'There are currently no boxes.');
    }
    return ListView.builder(
      itemBuilder: (context, index) {
        final box = widget.zone.boxes[index];
        return ListTile(
          title: Text(box.name),
          onTap: () {},
        );
      },
      itemCount: widget.zone.boxes.length,
    );
  }

  /// Get the WYSIWYG editor.
  Widget getCanvas(BuildContext context) {
    final helpAction = CallbackAction<HelpIntent>(
      onInvoke: (intent) => pushWidget(
        context: context,
        builder: (context) => const KeyboardShortcuts(
          keyboardShortcuts: canvasKeyboardShortcuts,
        ),
      ),
    );
    final x = _level.coordinates.x;
    final y = _level.coordinates.y;
    final moveAction = CallbackAction<MoveIntent>(
      onInvoke: (intent) {
        _level.heading = intent.heading;
        final terrain = _level.getTerrain();
        final options = WalkingOptions(
          interval: 0,
          distance: 1.0,
          sound: terrain.fastWalk.sound,
        );
        final oldBox = _level.getBox();
        final destination = coordinatesInDirection(
          _level.coordinates,
          _level.heading.toDouble(),
          1.0,
        );
        final newBox = _level.getBox(destination);
        if (newBox != oldBox) {
          // Boxes are different.
          final String text;
          if (newBox == null) {
            _level.affectedInterfaceSounds.setReverb(null);
            if (oldBox != null) {
              text = 'Leaving ${oldBox.name}.';
            } else {
              text = 'Both boxes are null, new box was tested first.';
            }
          } else {
            _level.affectedInterfaceSounds.setReverb(_level.getReverb(newBox));
            if (oldBox == null) {
              text = 'Entering ${newBox.name}.';
            } else {
              text = 'Both boxes are null, old box was tested first.';
            }
          }
          showSnackBar(context: context, message: text);
        }
        _level.affectedInterfaceSounds.playSound(
          widget.projectContext.getRelativeAssetReference(
            getAssetReferenceReference(
              assets: widget.projectContext.world.terrainAssets,
              id: options.sound.id,
            )!
                .reference,
          ),
          gain: options.sound.gain,
        );
        _level.coordinates = destination;
        setState(() {});
        return null;
      },
    );
    final box = _level.getBox();
    return Shortcuts(
      child: Actions(
        actions: {
          MoveIntent: moveAction,
          HelpIntent: helpAction,
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
            box == null
                ? const ListTile(
                    title: Text('Add Box'),
                  )
                : getBoxListTile(context, box)
          ],
        ),
      ),
      shortcuts: const {
        HelpIntent.hotkey: _helpIntent,
        SingleActivator(LogicalKeyboardKey.arrowUp, control: true): MoveIntent(
          0,
        ),
        SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
            MoveIntent(
          90,
        ),
        SingleActivator(LogicalKeyboardKey.arrowDown, control: true):
            MoveIntent(
          180,
        ),
        SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
            MoveIntent(
          270,
        )
      },
    );
  }

  /// Get a list tile for the given [box].
  Widget getBoxListTile(BuildContext context, Box box) => ListTile(
        title: Text(box.name),
      );
}
