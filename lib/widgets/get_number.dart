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
    this.title = 'Enter Value',
    this.labelText = 'New value',
    Key? key,
  }) : super(key: key);

  /// The initial value.
  final double value;

  /// What to do with the resulting number.
  final ValueChanged<double> onDone;

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
  _GetNumberState createState() => _GetNumberState();
}

/// State for [GetNumber].
class _GetNumberState extends State<GetNumber> {
  late final TextEditingController _textEditingController;
  late final GlobalKey<FormState> _formKey;

  /// Initialise things.
  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _textEditingController = TextEditingController(
      text: widget.value.toString(),
    );
  }

  /// Build a widget.
  @override
  Widget build(BuildContext context) => Cancel(
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Form(
            child: Center(
              child: TextFormField(
                autofocus: true,
                controller: _textEditingController,
                decoration: InputDecoration(
                  labelText: widget.labelText,
                ),
                onFieldSubmitted: (value) => submitForm(context),
                validator: validate,
              ),
            ),
            key: _formKey,
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.done),
            onPressed: () => submitForm(context),
            tooltip: 'Done',
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
  String? validate(String? value) {
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
  void submitForm(BuildContext context) {
    if (_formKey.currentState?.validate() == true) {
      widget.onDone(double.parse(_textEditingController.text));
    }
  }
}
