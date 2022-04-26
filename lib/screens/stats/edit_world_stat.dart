// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/number_list_tile.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing the given [stat].
class EditWorldStat extends StatefulWidget {
  /// Create an instance.
  const EditWorldStat({
    required this.projectContext,
    required this.stat,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// The stat to edit.
  final WorldStat stat;

  /// Create state for this widget.
  @override
  EditWorldStatState createState() => EditWorldStatState();
}

/// State for [EditWorldStat].
class EditWorldStatState extends State<EditWorldStat> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) => Cancel(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Edit Stat'),
          ),
          body: ListView(
            children: [
              TextListTile(
                value: widget.stat.name,
                onChanged: (final value) {
                  widget.stat.name = value;
                  save();
                },
                header: 'Name',
                autofocus: true,
                validator: (final value) => validateNonEmptyValue(value: value),
              ),
              TextListTile(
                value: widget.stat.description,
                onChanged: (final value) {
                  widget.stat.description = value;
                  save();
                },
                header: 'Description',
                validator: (final value) => validateNonEmptyValue(value: value),
              ),
              NumberListTile(
                value: widget.stat.defaultValue.toDouble(),
                onChanged: (final value) {
                  widget.stat.defaultValue = value.floor();
                  save();
                },
                modifier: 5,
                title: 'Default Value',
                subtitle: '${widget.stat.defaultValue}',
              )
            ],
          ),
        ),
      );

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
