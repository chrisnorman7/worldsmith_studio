import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A text widget that can be tapped or otherwise activated with the enter or
/// space bar keys.
class Clickable extends StatelessWidget {
  /// Create an instance.
  const Clickable({
    required this.child,
    required this.onActivate,
    super.key,
  });

  /// The child widget to use.
  final Widget child;

  /// The function to call when this widget is activated.
  final VoidCallback onActivate;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.space): onActivate,
          const SingleActivator(LogicalKeyboardKey.enter): onActivate,
        },
        child: GestureDetector(
          onTap: onActivate,
          child: child,
        ),
      );
}
