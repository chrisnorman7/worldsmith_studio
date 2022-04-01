import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing a direction.
class EditDirection extends StatefulWidget {
  /// Create an instance.
  const EditDirection({
    required this.projectContext,
    required this.name,
    required this.degrees,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The name of this direction.
  final String name;

  /// The degrees where this direction appears.
  final double degrees;

  /// Create state for this widget.
  @override
  EditDirectionState createState() => EditDirectionState();
}

/// State for [EditDirection].
class EditDirectionState extends State<EditDirection> {
  late String _name;
  late double _degrees;

  /// Initialise values.
  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _degrees = widget.degrees;
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () => confirm(
                context: context,
                message:
                    'Are you sure you want to delete the $_name direction?',
                title: 'Delete Direction',
                yesCallback: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  world.directions.removeWhere(
                    (final key, final value) =>
                        key == _name && value == _degrees,
                  );
                  widget.projectContext.save();
                },
              ),
              child: deleteIcon,
            )
          ],
          title: const Text('Edit Direction'),
        ),
        body: ListView(
          children: [
            TextListTile(
              value: _name,
              onChanged: (final value) => save(name: value),
              header: 'Direction Name',
              autofocus: true,
              labelText: 'Name',
              validator: (final value) => validateNonEmptyValue(value: value),
            ),
            ListTile(
              title: const Text('Degrees'),
              subtitle: Slider(
                onChanged: (final value) => save(degrees: value * 360),
                value: _degrees / 360.0,
                label: '${_degrees.floor()} °',
                divisions: 360,
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Save this direction.
  void save({
    String? name,
    double? degrees,
  }) {
    name ??= _name;
    degrees ??= _degrees;
    final world = widget.projectContext.world;
    world.directions.removeWhere(
      (final key, final value) => key == _name && value == _degrees,
    );
    world.directions[name] = degrees;
    widget.projectContext.save();
    setState(() {
      _name = name ?? _name;
      _degrees = degrees ?? _degrees;
    });
  }
}
