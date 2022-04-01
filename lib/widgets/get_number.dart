/// Provides the [GetNumber] class.
import 'package:flutter/material.dart';

import 'cancel.dart';

/// A widget for getting a number.
class GetNumber extends StatefulWidget {
  /// Create an instance.
  const GetNumber({
    required this.value,
    required this.onDone,
    this.min,
    this.max,
    this.actions = const [],
    this.title = 'Enter Value',
    this.labelText = 'New value',
    final Key? key,
  }) : super(key: key);

  /// The initial value.
  final double value;

  /// What to do with the resulting number.
  final ValueChanged<double> onDone;

  /// The actions for the resulting [AppBar].
  final List<Widget> actions;

  /// The title for the resulting scaffold.
  final String title;

  /// The label for the resulting text field.
  final String labelText;

  /// The minimum value.
  final double? min;

  /// The maximum value.
  final double? max;

  /// Create state for this widget.
  @override
  GetNumberState createState() => GetNumberState();
}

/// State for [GetNumber].
class GetNumberState extends State<GetNumber> {
  late final TextEditingController _textEditingController;
  late final GlobalKey<FormState> _formKey;

  /// Initialise things.
  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _textEditingController = TextEditingController(
      text: widget.value.toString(),
    )..selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.value.toString().length,
      );
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
            child: Center(
              child: TextFormField(
                autofocus: true,
                controller: _textEditingController,
                decoration: InputDecoration(
                  labelText: widget.labelText,
                ),
                onFieldSubmitted: (final value) => submitForm(context),
                validator: validate,
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => submitForm(context),
            tooltip: 'Done',
            child: const Icon(Icons.done),
          ),
        ),
      );

  /// Dispose of the controller.
  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  /// Validate the entered value.
  String? validate(final String? value) {
    if (value == null || value.isEmpty) {
      return 'You must enter a value';
    }
    final n = double.tryParse(value);
    if (n == null) {
      return 'Invalid value';
    }
    final min = widget.min;
    if (min != null && n < min) {
      return 'Value must be no lower than $min';
    }
    final max = widget.max;
    if (max != null && n > max) {
      return 'Value must be no more than $max';
    }
    return null;
  }

  /// Submit the form.
  void submitForm(final BuildContext context) {
    if (_formKey.currentState?.validate() ?? true) {
      widget.onDone(double.parse(_textEditingController.text));
    }
  }
}
