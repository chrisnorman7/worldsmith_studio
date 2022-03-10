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
    this.getItemWidget,
    Key? key,
  }) : super(key: key);

  /// The function to call with the resulting value.
  final ValueChanged<T> onDone;

  /// The possible values to choose from.
  final List<T> values;

  /// The function to be used to get a suitable widget for displaying an item.
  final Widget Function(T value)? getItemWidget;

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
              final item = values[index];
              final getWidget = getItemWidget;
              return ListTile(
                autofocus: (value == null && index == 0) || item == value,
                selected: item == value,
                title:
                    getWidget == null ? Text(item.toString()) : getWidget(item),
                onTap: () => onDone(item),
              );
            },
            itemCount: values.length,
          ),
        ),
      );
}
