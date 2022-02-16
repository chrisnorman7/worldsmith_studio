import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/text_list_tile.dart';
import '../sound/sound_list_tile.dart';

/// A widget for editing the given [credit].
class EditCredit extends StatefulWidget {
  /// Create an instance.
  const EditCredit({
    required this.projectContext,
    required this.credit,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The credit to edit.
  final WorldCredit credit;

  /// Create state for this widget.
  @override
  _EditCreditState createState() => _EditCreditState();
}

/// State for [EditCredit].
class _EditCreditState extends State<EditCredit> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final world = widget.projectContext.world;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () {
                world.credits.removeWhere(
                  (element) => element.id == widget.credit.id,
                );
                widget.projectContext.save();
                Navigator.pop(context);
              },
              child: deleteIcon,
            )
          ],
          title: const Text('Edit Credit'),
        ),
        body: ListView(
          children: [
            TextListTile(
              value: widget.credit.title,
              onChanged: (value) {
                widget.credit.title = value;
                save();
              },
              header: 'Title',
              autofocus: true,
              title: 'Credit Title',
              validator: (value) => validateNonEmptyValue(value: value),
            ),
            TextListTile(
              value: widget.credit.url ?? '',
              onChanged: (value) {
                widget.credit.url = value.isEmpty ? null : value;
                save();
              },
              header: 'Url',
              title: 'Credit URL',
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: widget.credit.sound,
              onDone: (value) {
                widget.credit.sound = value;
                save();
              },
              assetStore: world.creditsAssetStore,
              defaultGain: world.soundOptions.defaultGain,
              nullable: true,
            )
          ],
        ),
      ),
    );
  }

  /// Save the project context and set state.
  void save() {
    widget.projectContext.save();
    setState(() {});
  }
}
