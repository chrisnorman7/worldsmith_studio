import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../validators.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing the quest menu options.
class EditQuestMenu extends StatefulWidget {
  /// Create an instance.
  const EditQuestMenu({
    required this.projectContext,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  EditQuestMenuState createState() => EditQuestMenuState();
}

/// State for [EditQuestMenu].
class EditQuestMenuState extends State<EditQuestMenu> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final options = widget.projectContext.world.questMenuOptions;
    return Scaffold(
      appBar: AppBar(
        title: Text(options.title),
      ),
      body: ListView(
        children: [
          TextListTile(
            value: options.title,
            onChanged: (final value) {
              options.title = value;
              save();
            },
            header: 'Title',
            autofocus: true,
            validator: (final value) => validateNonEmptyValue(value: value),
          ),
          TextListTile(
            value: options.noQuestsMessage,
            onChanged: (final value) {
              options.noQuestsMessage = value;
              save();
            },
            header: 'No Quests Message',
          ),
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
