import 'package:flutter/material.dart';

import '../util.dart';

/// A widget that will push a widget then set its state.
class PushWidgetListTile extends StatefulWidget {
  /// Create an instance.
  const PushWidgetListTile({
    required this.title,
    required this.builder,
    this.subtitle,
    this.autofocus = false,
    final Key? key,
  }) : super(key: key);

  /// The title for this widget.
  final String title;

  /// The widget builder to use.
  final WidgetBuilder builder;

  /// The subtitle for this widget.
  ///
  /// If this value is `null`, then no `subtitle` widget will be created.
  final String? subtitle;

  /// Whether this widget should be autofocused.
  final bool autofocus;

  /// Create state for this widget.
  @override
  PushWidgetListTileState createState() => PushWidgetListTileState();
}

/// State for [PushWidgetListTile].
class PushWidgetListTileState extends State<PushWidgetListTile> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final subtitle = widget.subtitle;
    return ListTile(
      autofocus: widget.autofocus,
      title: Text(widget.title),
      subtitle: subtitle == null ? null : Text(subtitle),
      onTap: () async {
        await pushWidget(context: context, builder: widget.builder);
        setState(() {});
      },
    );
  }
}
