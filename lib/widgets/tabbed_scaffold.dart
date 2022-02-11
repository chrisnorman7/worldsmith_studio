import 'package:flutter/material.dart';

/// A tab for a [TabbedScaffold].
class TabbedScaffoldTab {
  /// Create an instance.
  const TabbedScaffoldTab({
    required this.title,
    required this.icon,
    required this.child,
    this.actions,
    this.floatingActionButton,
  });

  /// The title of the scaffold.
  final String title;

  /// The icon to use for the [BottomNavigationBarItem] that shows this tab.
  final Widget icon;

  /// The child to use.
  final Widget child;

  /// The actions to use for the app bar.
  final List<Widget>? actions;

  /// The floating action button to use.
  final FloatingActionButton? floatingActionButton;
}

/// A scaffold with multiple tabs.
class TabbedScaffold extends StatefulWidget {
  /// Create an instance.
  const TabbedScaffold({
    required this.tabs,
    Key? key,
  }) : super(key: key);

  /// The tabs to use.
  final List<TabbedScaffoldTab> tabs;

  /// Create state for this widget.
  @override
  _TabbedScaffoldState createState() => _TabbedScaffoldState();
}

/// State for [TabbedScaffold].
class _TabbedScaffoldState extends State<TabbedScaffold> {
  late int _index;

  /// Set the initial index.
  @override
  void initState() {
    super.initState();
    _index = 0;
  }

  /// Build a widget.
  @override
  Widget build(BuildContext context) {
    final tab = widget.tabs[_index];
    return Scaffold(
      appBar: AppBar(
        actions: tab.actions,
        title: Text(tab.title),
      ),
      body: tab.child,
      floatingActionButton: tab.floatingActionButton,
      bottomNavigationBar: BottomNavigationBar(
        items: widget.tabs
            .map(
              (e) => BottomNavigationBarItem(
                icon: e.icon,
                label: e.title,
              ),
            )
            .toList(),
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
      ),
    );
  }
}
