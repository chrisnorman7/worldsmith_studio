import 'package:flutter/material.dart';

import 'cancel.dart';

/// A widget for getting text.
class GetText extends StatefulWidget {
  /// Create an instance.
  const GetText({
    required this.onDone,
    this.validator,
    this.text,
    this.title = 'Enter Text',
    this.actions = const [],
    this.labelText = 'Text',
    this.icon = const Icon(Icons.done_rounded),
    this.tooltip = 'Done',
    super.key,
  });

  /// What to do with the resulting text.
  final ValueChanged<String> onDone;

  /// The validator to use for the form field.
  final FormFieldValidator<String>? validator;

  /// The current text.
  final String? text;

  /// The title of the resulting scaffold.
  final String title;

  /// The label for the resulting form field.
  final String labelText;

  /// The actions that will be present in the resulting app bar.
  final List<Widget> actions;

  /// The icon for the resulting floating action button.
  final Widget? icon;

  /// THe tooltip for the resulting floating action button.
  final String tooltip;

  /// Create state for this widget.
  @override
  GetTextState createState() => GetTextState();
}

/// State for [GetText].
class GetTextState extends State<GetText> {
  late final TextEditingController _controller;
  late final GlobalKey<FormState> _formKey;

  /// Initialise the controller.
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.text ?? '',
    );
    final textLength = widget.text?.length ?? 0;
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: textLength,
    );
    _formKey = GlobalKey<FormState>();
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) => Cancel(
        child: Scaffold(
          appBar: AppBar(
            actions: widget.actions,
            title: Text(widget.title),
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  autofocus: true,
                  controller: _controller,
                  decoration: InputDecoration(labelText: widget.labelText),
                  onFieldSubmitted: (final value) => onSubmit(),
                  validator: widget.validator,
                )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: onSubmit,
            tooltip: widget.tooltip,
            child: widget.icon,
          ),
        ),
      );

  /// Submit the form.
  void onSubmit() {
    if (_formKey.currentState?.validate() ?? true) {
      widget.onDone(_controller.text);
    }
  }

  /// Dispose of the controller.
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
