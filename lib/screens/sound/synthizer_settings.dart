import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/select_item.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing synthizer settings.
class SynthizerSettings extends StatefulWidget {
  /// Create an instance.
  const SynthizerSettings({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  SynthizerSettingsState createState() => SynthizerSettingsState();
}

/// State for [SynthizerSettings].
class SynthizerSettingsState extends State<SynthizerSettings> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final options = widget.projectContext.world.soundOptions;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Synthizer Settings'),
        ),
        body: ListView(
          children: [
            ListTile(
              autofocus: true,
              title: const Text('Log Level'),
              subtitle: Text(options.synthizerLogLevel?.name ?? 'Not set'),
              onTap: () => pushWidget(
                context: context,
                builder: (context) => SelectItem<LogLevel?>(
                  onDone: (value) {
                    Navigator.pop(context);
                    options.synthizerLogLevel = value;
                    save();
                  },
                  values: const [null, ...LogLevel.values],
                  getItemWidget: (value) => Text(
                    value == null ? 'Clear' : value.name,
                  ),
                  value: options.synthizerLogLevel,
                  title: 'Synthizer Log Level',
                ),
              ),
            ),
            ListTile(
              title: const Text('Logging Backend'),
              subtitle:
                  Text(options.synthizerLoggingBackend?.name ?? 'Not set'),
              onTap: () => pushWidget(
                context: context,
                builder: (context) => SelectItem<LoggingBackend?>(
                  onDone: (value) {
                    Navigator.pop(context);
                    options.synthizerLoggingBackend = value;
                    save();
                  },
                  values: const [null, ...LoggingBackend.values],
                  getItemWidget: (value) => Text(
                    value == null ? 'Clear' : value.name,
                  ),
                  title: 'Synthizer Logging Backend',
                  value: options.synthizerLoggingBackend,
                ),
              ),
            ),
            TextListTile(
              value: options.libsndfilePathLinux,
              onChanged: (value) {
                options.libsndfilePathLinux = value;
                save();
              },
              header: 'Linux Libsndfile Path',
              labelText: 'Path',
              validator: (value) => validateNonEmptyValue(value: value),
            ),
            TextListTile(
              value: options.libsndfilePathMac,
              onChanged: (value) {
                options.libsndfilePathMac = value;
                save();
              },
              header: 'Mac OS Libsndfile Path',
              labelText: 'Path',
              validator: (value) => validateNonEmptyValue(value: value),
            ),
            TextListTile(
              value: options.libsndfilePathWindows,
              onChanged: (value) {
                options.libsndfilePathWindows = value;
                save();
              },
              header: 'Windows Libsndfile Path',
              labelText: 'Path',
              validator: (value) => validateNonEmptyValue(value: value),
            )
          ],
        ),
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
