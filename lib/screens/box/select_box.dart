import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

/// A widget for selecting a box from a list of [boxes].
class SelectBox extends StatelessWidget {
  /// Create an instance.
  const SelectBox({
    required this.boxes,
    required this.onDone,
    this.currentBoxId,
    this.title = 'Select Box',
    Key? key,
  }) : super(key: key);

  /// The boxes to choose from.
  final List<Box> boxes;

  /// The function to call with the selected box.
  final ValueChanged<Box> onDone;

  /// The ID of the currently-selected box.
  final String? currentBoxId;

  /// The title of the resulting [Scaffold].
  final String title;

  @override
  Widget build(BuildContext context) {
    Box? currentBox;
    if (currentBoxId != null) {
      currentBox = boxes.firstWhere(
        (element) => element.id == currentBoxId,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final box = boxes[index];
          return ListTile(
            autofocus:
                currentBox == null ? index == 0 : box.id == currentBox.id,
            title: Text(box.name),
            onTap: () => onDone(box),
          );
        },
        itemCount: boxes.length,
      ),
    );
  }
}
