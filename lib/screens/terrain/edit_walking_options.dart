import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../project_context.dart';

/// A widget for editing the given [walkingOptions].
class EditWalkingOptions extends StatefulWidget {
  /// Create an instance.
  const EditWalkingOptions({
    required this.projectContext,
    required this.walkingOptions,
    Key? key,
  }) : super(key: key);

  /// The project context to use.
  final ProjectContext projectContext;

  /// The options to configure.
  final WalkingOptions walkingOptions;

  /// Create state for this widget.
  @override
  _EditWalkingOptionsState createState() => _EditWalkingOptionsState();
}

/// State for [EditWalkingOptions].
class _EditWalkingOptionsState extends State<EditWalkingOptions> {
  /// Build a widget.
  @override
  Widget build(BuildContext context) => const Center(child: Text('text'));
}
