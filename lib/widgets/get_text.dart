/// Provides the [GetText] class.
import 'package:flutter/material.dart';

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
    Key? key,
  }) : super(key: key);

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
  _GetTextState createState() => _GetTextState();
}

/// State for [GetText].
class _GetTextState extends State<GetText> {
  late final TextEditingController _controller;
  late final GlobalKey<FormState> _formKey;

  /// Initialise the controller.
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text ?? '');
    _formKey = GlobalKey<FormState>();
  }

  /// Build a widget.
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: widget.actions,
          title: Text(widget.title),
        ),
        body: Form(
          child: Column(
            children: [
              TextFormField(
                autofocus: true,
                controller: _controller,
                decoration: InputDecoration(labelText: widget.labelText),
                onFieldSubmitted: (value) => onSubmit(),
                validator: widget.validator,
              )
            ],
          ),
          key: _formKey,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onSubmit,
          child: widget.icon,
          tooltip: widget.tooltip,
        ),
      );

  /// Submit the form.
  void onSubmit() {
    if (_formKey.currentState?.validate() == true) {
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
