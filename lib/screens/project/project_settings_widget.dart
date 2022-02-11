import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:ziggurat/sound.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/get_text.dart';

/// A widget for customising the main settings for the given [projectContext].
class ProjectSettingsWidget extends StatefulWidget {
  /// Create an instance.
  const ProjectSettingsWidget({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _ProjectSettingsWidgetState createState() => _ProjectSettingsWidgetState();
}

/// State for [ProjectSettingsWidget].
class _ProjectSettingsWidgetState extends State<ProjectSettingsWidget> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) => ListView(
        children: [
          ListTile(
            autofocus: true,
            title: const Text('Rename World'),
            subtitle: Text(widget.projectContext.world.title),
            onTap: () async {
              await pushWidget(
                context: context,
                builder: (context) => GetText(
                  onDone: (value) {
                    Navigator.pop(context);
                    widget.projectContext.world.title = value;
                    widget.projectContext.save();
                  },
                  labelText: 'World Name',
                  text: widget.projectContext.world.title,
                  title: 'Rename World',
                  validator: (value) => validateNonEmptyValue(value: value),
                ),
              );
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('Default Panning Strategy'),
            subtitle: Text(
              path.extension(
                widget.projectContext.world.soundOptions.defaultPannerStrategy
                    .toString(),
              ),
            ),
            onTap: () {
              final soundOptions = widget.projectContext.world.soundOptions;
              var index = soundOptions.defaultPannerStrategy.index + 1;
              if (index >= DefaultPannerStrategy.values.length) {
                index = 0;
              }
              setState(() {
                widget.projectContext.world.soundOptions.defaultPannerStrategy =
                    DefaultPannerStrategy.values[index];
              });
            },
          )
        ],
      );
}
