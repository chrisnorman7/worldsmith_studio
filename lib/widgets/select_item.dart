import 'package:flutter/material.dart';

import 'cancel.dart';

/// A widget for selecting something from a list of [values].
class SelectItem<T> extends StatelessWidget {
  /// Create an instance.
  const SelectItem({
    required this.onDone,
    required this.values,
    this.title = 'Select Item',
    this.value,
    this.getDescription,
    Key? key,
  }) : super(key: key);

  /// The function to call with the resulting value.
  final ValueChanged<T> onDone;

  /// The possible values to choose from.
  final List<T> values;

  /// The function to be used to return a textual representation of values.
  final String Function(T value)? getDescription;

  /// The title of the resulting [Scaffold].
  final String title;

  /// The current value.
  final T? value;

  /// Create the widget.
  @override
  Widget build(BuildContext context) => Cancel(
        child: Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: ListView.builder(
              itemBuilder: (context, index) {
                final element = values[index];
                final f = getDescription;
                final String description;
                if (f == null) {
                  description = element.toString();
                } else {
                  description = f(element);
                }
                return ListTile(
                  autofocus: (value == null && index == 0) || element == value,
                  selected: element == value,
                  title: Text(description),
                  onTap: () => onDone(element),
                );
              },
              itemCount: values.length,
            )),
      );
}
