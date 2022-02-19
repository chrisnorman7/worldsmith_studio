import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

/// A widget for selecting a new box corner.
class SelectBoxCorner extends StatelessWidget {
  /// Create an instance.
  const SelectBoxCorner({
    required this.onDone,
    this.value,
    Key? key,
  }) : super(key: key);

  /// The function to be called with the new corner.
  final ValueChanged<BoxCorner> onDone;

  /// The current corner.
  final BoxCorner? value;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Choose Box Corner'),
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            final corner = BoxCorner.values[index];
            return ListTile(
              autofocus: (value == null && index == 0) || corner == value,
              selected: corner == value,
              title: Text(corner.name),
              onTap: () => onDone(corner),
            );
          },
          itemCount: BoxCorner.values.length,
        ),
      );
}
