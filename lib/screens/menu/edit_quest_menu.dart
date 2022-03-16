import 'package:flutter/material.dart';

import '../../project_context.dart';
import '../../validators.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing the quest menu options.
class EditQuestMenu extends StatefulWidget {
  /// Create an instance.
  const EditQuestMenu({
    required this.projectContext,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  _EditQuestMenuState createState() => _EditQuestMenuState();
}

/// State for [EditQuestMenu].
class _EditQuestMenuState extends State<EditQuestMenu> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final options = widget.projectContext.world.questMenuOptions;
    return Scaffold(
      appBar: AppBar(
        title: Text(options.title),
      ),
      body: ListView(
        children: [
          TextListTile(
            value: options.title,
            onChanged: (value) {
              options.title = value;
              save();
            },
            header: 'Title',
            autofocus: true,
            validator: (value) => validateNonEmptyValue(value: value),
          ),
          TextListTile(
            value: options.noQuestsMessage,
            onChanged: (value) {
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
