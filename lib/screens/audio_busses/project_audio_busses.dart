import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import 'edit_audio_bus.dart';

/// A widget for editing audio busses.
class ProjectAudioBusses extends StatefulWidget {
  /// Create an instance.
  const ProjectAudioBusses({
    required this.projectContext,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  ProjectAudioBussesState createState() => ProjectAudioBussesState();
}

/// State for [ProjectAudioBusses].
class ProjectAudioBussesState extends State<ProjectAudioBusses> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final busses = world.audioBusses;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Audio Busses'),
        ),
        body: ListView.builder(
          itemBuilder: (final context, final index) {
            final bus = busses[index];
            return ListTile(
              autofocus: index == 0,
              title: Text(bus.name),
              subtitle: Text(
                '${bus.panningType.name} (${bus.x}, ${bus.y}, ${bus.z})',
              ),
              onTap: () async {
                await pushWidget(
                  context: context,
                  builder: (final context) => EditAudioBus(
                    projectContext: widget.projectContext,
                    audioBus: bus,
                  ),
                );
              },
            );
          },
          itemCount: busses.length,
        ),
        floatingActionButton: FloatingActionButton(
          autofocus: busses.isEmpty,
          onPressed: () async {
            final bus = AudioBus(id: newId(), name: 'Untitled Audio Bus');
            world.audioBusses.add(bus);
            widget.projectContext.save();
            await pushWidget(
              context: context,
              builder: (final context) => EditAudioBus(
                projectContext: widget.projectContext,
                audioBus: bus,
              ),
            );
            setState(() {});
          },
          tooltip: 'Add Audio Bus',
          child: createIcon,
        ),
      ),
    );
  }
}
