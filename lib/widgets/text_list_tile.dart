import 'package:flutter/material.dart';

import '../util.dart';
import 'get_text.dart';

/// A list tile that displays and allows the editing of some text.
class TextListTile extends StatelessWidget {
  /// Create an instance.
  const TextListTile({
    required this.value,
    required this.onChanged,
    required this.header,
    this.actions = const [],
    this.title,
    this.labelText,
    this.validator,
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

  /// The title of the list tile.
  final String header;

  /// The current value.
  final String value;

  /// The function to be called when the value changes.
  final ValueChanged<String> onChanged;

  /// The actions for the resulting [GetText] widget.
  final List<Widget> actions;

  /// The title of the [GetText] widget.
  final String? title;

  /// The label text for the [GetText] widget.
  final String? labelText;

  /// The validator to use.
  final FormFieldValidator<String?>? validator;

  /// Whether the resulting [ListTile] should be autofocused.
  final bool autofocus;
  @override
  Widget build(BuildContext context) => ListTile(
        autofocus: autofocus,
        title: Text(header),
        subtitle: Text(value),
        onTap: () => pushWidget(
          context: context,
          builder: (context) => GetText(
            onDone: (value) {
              Navigator.pop(context);
              onChanged(value);
            },
            labelText: labelText ?? title ?? header,
            text: value,
            actions: actions,
            title: title ?? header,
            validator: validator,
          ),
        ),
      );
}
