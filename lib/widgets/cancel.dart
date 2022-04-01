/// Provides the [Cancel] class.
import 'package:flutter/material.dart';

import '../../intents.dart';

/// A widget that can be cancelled with the escape key.
class Cancel extends StatelessWidget {
  /// Create an instance.
  const Cancel({required this.child, final Key? key}) : super(key: key);

  /// The child to use.
  final Widget child;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => Shortcuts(
        shortcuts: const {
          CancelIntent.hotkey: CancelIntent(),
        },
        child: Actions(
          actions: {
            CancelIntent: CallbackAction(
              onInvoke: (final intent) => Navigator.pop(context),
            ),
          },
          child: child,
        ),
      );
}
