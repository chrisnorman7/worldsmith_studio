import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../intents.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/custom_message/custom_message_list_tile.dart';
import '../../widgets/custom_message/edit_custom_message.dart';
import '../../widgets/reverb/reverb_list_tile.dart';
import '../../widgets/tabbed_scaffold.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing a scene.
class EditScene extends StatefulWidget {
  /// Create an instance.
  const EditScene({
    required this.projectContext,
    required this.scene,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The scene to edit.
  final Scene scene;

  /// Create state for this widget.
  @override
  _EditSceneState createState() => _EditSceneState();
}

/// State for [EditScene].
class _EditSceneState extends State<EditScene> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    final scene = widget.scene;
    final sections = scene.sections;
    return Cancel(
      child: TabbedScaffold(
        tabs: [
          TabbedScaffoldTab(
            title: 'Settings',
            icon: const Icon(Icons.settings),
            builder: (context) => ListView(
              children: [
                TextListTile(
                  value: scene.name,
                  onChanged: (value) {
                    scene.name = value;
                    save();
                  },
                  header: 'Name',
                  autofocus: true,
                  validator: (value) => validateNonEmptyValue(value: value),
                ),
                ReverbListTile(
                  projectContext: widget.projectContext,
                  onDone: (value) {
                    scene.reverbId = value?.id;
                    save();
                  },
                  reverbPresets: world.reverbs,
                  currentReverbId: scene.reverbId,
                  nullable: true,
                )
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  final id = scene.id;
                  for (final category in world.commandCategories) {
                    for (final command in category.commands) {
                      if (command.showScene?.sceneId == id) {
                        return showError(
                          context: context,
                          message: 'This scene is used by the ${command.name} '
                              'command of the ${category.name} category.',
                        );
                      }
                    }
                  }
                  confirm(
                    context: context,
                    message: 'Are you sure you want to delete the '
                        '${scene.name} scene?',
                    title: 'Delete Scene',
                    yesCallback: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      world.scenes.removeWhere(
                        (element) => element.id == id,
                      );
                      widget.projectContext.save();
                    },
                  );
                },
                child: const Icon(
                  Icons.delete_outline,
                  semanticLabel: 'Delete Scene',
                ),
              )
            ],
          ),
          TabbedScaffoldTab(
            title: 'Sections',
            icon: const Icon(Icons.pages_outlined),
            builder: (context) => ListView.builder(
              itemBuilder: (context, index) {
                final section = sections[index];
                return CallbackShortcuts(
                  bindings: {
                    MoveUpIntent.hotkey: () {
                      if (index > 0) {
                        sections
                          ..removeAt(index)
                          ..insert(index - 1, section);
                        save();
                      }
                    },
                    MoveDownIntent.hotkey: () {
                      sections.removeAt(index);
                      if (index >= sections.length) {
                        sections.add(section);
                      } else {
                        sections.insert(index + 1, section);
                      }
                      save();
                    }
                  },
                  child: CustomMessageListTile(
                    projectContext: widget.projectContext,
                    customMessage: section.message,
                    title: 'Section ${index + 1}',
                    autofocus: index == 0,
                  ),
                );
              },
              itemCount: sections.length,
            ),
            floatingActionButton: FloatingActionButton(
              autofocus: sections.isEmpty,
              child: createIcon,
              onPressed: () async {
                final section = SceneSection(message: CustomMessage());
                sections.add(section);
                widget.projectContext.save();
                await pushWidget(
                  context: context,
                  builder: (context) => EditCustomMessage(
                    projectContext: widget.projectContext,
                    customMessage: section.message,
                  ),
                );
                setState(() {});
              },
            ),
          )
        ],
      ),
    );
  }

  /// Save the project.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
