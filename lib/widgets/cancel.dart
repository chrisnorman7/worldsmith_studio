/// Provides the [Cancel] class.
import 'package:flutter/material.dart';

import '../../intents.dart';

/// A widget that can be cancelled with the escape key.
class Cancel extends StatelessWidget {
  /// Create an instance.
  const Cancel({required this.child, Key? key}) : super(key: key);

  /// The child to use.
  final Widget child;

  /// Build the widget.
  @override
  Widget build(BuildContext context) => Shortcuts(
        shortcuts: const {
          CancelIntent.hotkey: CancelIntent(),
        },
        child: Actions(
          actions: {
            CancelIntent: CallbackAction(
              onInvoke: (intent) => Navigator.pop(context),
            ),
          },
          child: child,
        ),
      );
}
