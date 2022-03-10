import 'package:flutter/material.dart';

import '../../intents.dart';
import '../../util.dart';
import '../get_number.dart';

const _increaseIntent = IncreaseIntent();
const _decreaseIntent = DecreaseIntent();

/// A widget for editing fade times.
class FadeTimeListTile extends StatelessWidget {
  /// Create an instance.
  const FadeTimeListTile({
    required this.value,
    required this.onChanged,
    this.title = 'Fade Time',
    Key? key,
  }) : super(key: key);

  /// The current fade time.
  final double? value;

  /// The function to be called when the fade time changes.
  final ValueChanged<double?> onChanged;

  /// The title of the resulting [ListTile].
  final String title;

  /// Build the widget.
  @override
  Widget build(BuildContext context) {
    final increaseAction = CallbackAction<IncreaseIntent>(
      onInvoke: (intent) => onChanged((value ?? 0.0) + 1.0),
    );
    final decreaseAction = CallbackAction<DecreaseIntent>(
      onInvoke: (intent) {
        final i = value;
        if (i == 1.0 || i == null) {
          onChanged(null);
        } else {
          onChanged(i - 1.0);
        }
        return null;
      },
    );
    return Shortcuts(
      child: Actions(
        actions: {
          IncreaseIntent: increaseAction,
          DecreaseIntent: decreaseAction
        },
        child: ListTile(
          title: Text(title),
          subtitle: Text('${value ?? "Not set"}'),
          onTap: () => pushWidget(
            context: context,
            builder: (context) => GetNumber(
              value: value ?? 0.0,
              onDone: (value) {
                Navigator.pop(context);
                if (value == 0.0) {
                  onChanged(null);
                } else {
                  onChanged(value);
                }
              },
              labelText: 'Fade Time',
              min: 0.0,
              title: 'Fade Time',
              actions: [
                ElevatedButton(
                  onPressed: () => onChanged(null),
                  child: const Icon(
                    Icons.clear_outlined,
                    semanticLabel: 'Clear Fade Time',
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      shortcuts: const {
        IncreaseIntent.hotkey: _increaseIntent,
        DecreaseIntent.hotkey: _decreaseIntent
      },
    );
  }
}
