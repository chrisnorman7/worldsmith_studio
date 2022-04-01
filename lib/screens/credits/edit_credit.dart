import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../validators.dart';
import '../../widgets/cancel.dart';
import '../../widgets/sound/sound_list_tile.dart';
import '../../widgets/text_list_tile.dart';

/// A widget for editing the given [credit].
class EditCredit extends StatefulWidget {
  /// Create an instance.
  const EditCredit({
    required this.projectContext,
    required this.credit,
    final Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The credit to edit.
  final WorldCredit credit;

  /// Create state for this widget.
  @override
  EditCreditState createState() => EditCreditState();
}

/// State for [EditCredit].
class EditCreditState extends State<EditCredit> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final url = widget.credit.url;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () => confirm(
                context: context,
                message: 'Are you sure you want to delete this credit?',
                title: 'Delete Credit',
                yesCallback: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  world.credits.removeWhere(
                    (final element) => element.id == widget.credit.id,
                  );
                  widget.projectContext.save();
                },
              ),
              child: deleteIcon,
            ),
            ElevatedButton(
              onPressed: url == null ? null : () => launch(url),
              child: const Icon(
                Icons.open_in_browser_outlined,
                semanticLabel: 'Test URL',
              ),
            )
          ],
          title: const Text('Edit Credit'),
        ),
        body: ListView(
          children: [
            TextListTile(
              value: widget.credit.title,
              onChanged: (final value) {
                widget.credit.title = value;
                save();
              },
              header: 'Title',
              autofocus: true,
              title: 'Credit Title',
              validator: (final value) => validateNonEmptyValue(value: value),
            ),
            TextListTile(
              value: widget.credit.url ?? '',
              onChanged: (final value) {
                widget.credit.url = value.isEmpty ? null : value;
                save();
              },
              header: 'Url',
              title: 'Credit URL',
            ),
            SoundListTile(
              projectContext: widget.projectContext,
              value: widget.credit.sound,
              onDone: (final value) {
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
